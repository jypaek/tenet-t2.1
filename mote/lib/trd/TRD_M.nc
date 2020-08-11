/*
* "Copyright (c) 2006 University of Southern California.
* All rights reserved.
*
* Permission to use, copy, modify, and distribute this software and its
* documentation for any purpose, without fee, and without written
* agreement is hereby granted, provided that the above copyright
* notice, the following two paragraphs and the author appear in all
* copies of this software.
*
* IN NO EVENT SHALL THE UNIVERSITY OF SOUTHERN CALIFORNIA BE LIABLE TO
* ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
* DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
* DOCUMENTATION, EVEN IF THE UNIVERSITY OF SOUTHERN CALIFORNIA HAS BEEN
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* THE UNIVERSITY OF SOUTHERN CALIFORNIA SPECIFICALLY DISCLAIMS ANY
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE
* PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
* SOUTHERN CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE,
* SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
*
*/

/**
 * TRD (Tiered Reliable Dissemination) module.
 *
 * TRD is a generic dissemination protocol that reliably delivers
 * packets to all nodes that runs TRD.
 * This module takes care of sending and receiving all TRD related
 * packets via the link-layer (NewQueuedSend/GenericComm).
 * TRD_State module maintains states so that it can decide when and
 * what to disseminated and receive.
 *
 * Embedded Networks Laboratory, University of Southern California
 * @date Nov/19/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/


#include "trd.h"
#include "trd_seqno.h"
#include "trd_checksum.h"
#include "trd_seqno.c"
#include "trd_checksum.c"

module TRD_M {
    provides {
        interface TRD;
    #ifdef TRD_SEND_ENABLED
        interface TRD_Send;
    #endif
    }
    uses {
        interface TRD_State;

        interface Receive as ReceiveTRD;
        interface Receive as ReceiveControl;

        interface AMSend as SendTRD;
        interface AMSend as SendControl;

        interface SplitControl as AMControl;
        interface Boot;

    #ifdef T2LPL
        interface LowPowerListening;
    #endif
    }
}
implementation {

    message_t myMsg;
    bool sendBusy = FALSE;
    
    event void Boot.booted() {
        call AMControl.start();
    }
    event void AMControl.startDone(error_t err) {
        // we assume that AM has been successfully started
    }
    event void AMControl.stopDone(error_t err) {}

#ifdef TRD_SEND_ENABLED
/**
 * Currently, it is customized for Tenet: disseminations are initiated
 * only at the masters, and the motes only receive and forward packets.
 * (This is why TRD_Send interface is undefined to be excluded.)
 **/
    command error_t TRD_Send.send(message_t* msg, uint8_t length) {
        TRD_Msg *rMsg = (TRD_Msg *)msg->data;
        if (length > TOSH_DATA_LENGTH - offsetof(TRD_Msg, data))
            return FAIL;
        if (sendBusy)
            return FAIL;
        rMsg->length = length;
        length += offsetof(TRD_Msg, data);
        rMsg->metadata.origin = TOS_NODE_ID;
        rMsg->metadata.seqno = call TRD_State.getNextSeqno();
        rMsg->metadata.age = 1; // new age
        rMsg->sender = TOS_NODE_ID;
        rMsg->checksum = 0;
        rMsg->checksum = trd_calculate_checksum(rMsg);
        
    #ifdef T2LPL
        call LowPowerListening.setRxSleepInterval(msg, T2LPL)
    #endif

        if (call SendTRD.send(AM_BROADCAST_ADDR, msg, length) == SUCCESS) {
            call TRD_State.newMsg(rMsg);
            sendBusy = TRUE;
        } else
            return FAIL;
        return SUCCESS;
    }

    command void* TRD_Send.getBuffer(message_t* msg, uint8_t *length) {
        TRD_Msg *rMsg;
        *length = TOSH_DATA_LENGTH - offsetof(TRD_Msg, data);
        if (msg == NULL)
            return NULL;
        rMsg = (TRD_Msg *)msg->data;
        return (void *)rMsg->data;  
    }
#endif
    
    /**
     * Received a TRD_Msg (dissemination packet).
     * If it is a newMsg, signal it to above layer (app).
     **/
    event message_t* ReceiveTRD.receive(message_t* msg, void* payload, uint8_t len) {
        TRD_Msg *rMsg = (TRD_Msg *)payload;

        if (len != (offsetof(TRD_Msg, data) + rMsg->length))
            return msg;
        if (trd_checksum_check(rMsg) < 0) // check check sum
            return msg;
            
        // if new message,
        if (call TRD_State.newMsg(rMsg) == TRUE) {
            signal TRD.receive((uint16_t)rMsg->metadata.origin, (uint8_t *)rMsg->data, rMsg->length);
        }
        return msg;
    }

    /**
     * Received a TRD_ControlMsg (either summary or request).
     **/
    event message_t* ReceiveControl.receive(message_t* msg, void* payload, uint8_t len) {
        TRD_ControlMsg *cmsg = (TRD_ControlMsg *)payload;
        
        if (len < offsetof(TRD_ControlMsg, metadata))
            return msg;
        if (trd_control_checksum_check(cmsg) < 0)
            return msg;
            
        if (cmsg->control_type == TRD_CONTROL_SUMMARY)
            call TRD_State.summaryReceived((TRD_SummaryMsg *)cmsg);
        else if (cmsg->control_type == TRD_CONTROL_REQUEST)
            call TRD_State.requestReceived((TRD_RequestMsg *)cmsg);
        return msg;
    }

    event void SendTRD.sendDone(message_t* msg, error_t error) {
        sendBusy = FALSE;
    #ifdef TRD_SEND_ENABLED
        if (msg != &myMsg) {
            call TRD_State.printTableEntry();
            signal TRD_Send.sendDone(msg, error);
        }
    #endif
    }
    event void SendControl.sendDone(message_t* msg, error_t error) {
        sendBusy = FALSE;
    }

    error_t send_control_msg(TRD_ControlMsg *cmsg, uint8_t len, uint16_t toAddr) {
        uint8_t *payload;

        if (sendBusy)
            return FAIL;

        cmsg->unused = 0x00;
        cmsg->checksum = 0;
        cmsg->checksum = trd_control_calculate_checksum(cmsg);
        // memcpy must be done after setting all values 
        payload = (uint8_t *)call SendControl.getPayload(&myMsg, len);
        memcpy(payload, (uint8_t *)cmsg, len);

    #ifdef T2LPL
        call LowPowerListening.setRxSleepInterval(&myMsg, T2LPL);
    #endif
        if (call SendControl.send(toAddr, &myMsg, len) == SUCCESS) {
            sendBusy = TRUE;
            return SUCCESS;
        }
        dbg("TRD_M", "radio busy: \n");
        return FAIL;
    }

    event error_t TRD_State.sendSummaryRequest(
                                  TRD_SummaryMsg *smsg, uint8_t len) {
        smsg->control_type = TRD_CONTROL_SUMMARY;
        dbg("TRD_M", "sending SUMMARY: \n");
        return send_control_msg((TRD_ControlMsg *)smsg, len, AM_BROADCAST_ADDR);
    }

    event error_t TRD_State.sendRequestRequest(
                                TRD_RequestMsg *qmsg, uint8_t len, uint16_t toAddr) {
        qmsg->control_type = TRD_CONTROL_REQUEST;
        dbg("TRD_M", "sending REQUEST: \n");
        return send_control_msg((TRD_ControlMsg *)qmsg, len, toAddr);
    }

    event error_t TRD_State.rebroadcastRequest(TRD_Msg *rmsg, uint8_t len) {
        uint8_t *payload;

        if (sendBusy)
            return FAIL;

        rmsg->sender = TOS_NODE_ID;
        rmsg->checksum = 0;
        rmsg->checksum = trd_calculate_checksum(rmsg);
        payload = (uint8_t *)call SendTRD.getPayload(&myMsg, len);
        memcpy(payload, (uint8_t *)rmsg, len);
   
        dbg("TRD_M", "REBROADCAST: --- (%d:%d)\n", 
                       rmsg->metadata.origin, rmsg->metadata.seqno);
    #ifdef T2LPL
        call LowPowerListening.setRxSleepInterval(&myMsg, T2LPL);
    #endif
        if (call SendTRD.send(AM_BROADCAST_ADDR, &myMsg, len) == SUCCESS) {
            sendBusy = TRUE;
            return SUCCESS;
        }
        dbg("TRD_M", "radio busy: \n");
        return FAIL;
    }

#ifdef TRD_SEND_ENABLED
    default event error_t TRD_Send.sendDone(message_t* msg, error_t success) {
        return SUCCESS;
    }
#endif
    default event void TRD.receive(uint16_t sender, uint8_t* payload, uint16_t paylen) {}
}


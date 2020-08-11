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
 * BestEffortTransport: Simple end-to-end ACK based Reliable Transport Protocol.
 *
 * A fixed number of end-to-end retransmissions will be performed based on
 * end-to-end acknowledgement. No windowing, and hence a bit slow.
 *
 * END-TO-END ACK is not working in T2 version of Tenet yet!!!!!
 *
 * Embedded Networks Laboratory, University of Southern California
 * @date Nov/19/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/


#include "packettransport.h"
#include "tr_checksum.h"
#include "tr_checksum.c"

module BestEffortTransportP {
    provides {
        interface TransportSend as Send;
        interface Init;
    }
    uses {
        interface AMSend as RoutingSend;
        interface CollectionPacket as RoutingPacket;
        interface TrPacket;
    }
}

implementation {

    message_t mybuf;
    uint16_t mySeqNo;
    bool sending;

    command error_t Init.init() {
        mySeqNo = 1;
        sending = FALSE;
        return SUCCESS;
    }

    event void RoutingSend.sendDone(message_t* msg, error_t success) {
        void* payload = call RoutingSend.getPayload(msg, TR_DATA_LENGTH);
        TransportMsg *tmsg = (TransportMsg *) payload;

        if (!sending) return;

        if (tmsg->flag == PTR_FLAG_NOACK_SEND)
            signal Send.sendDone(tmsg->tid, payload, success);
            
        sending = FALSE;
    }

    command error_t Send.send(uint16_t tid, uint16_t addr, 
                                    uint8_t length, void *data) {
        TransportMsg *tmsg;
        
        if (length > (call RoutingSend.maxPayloadLength() - TR_HDR_LEN))
            return FAIL;
        if (sending)
            return FAIL;
        tmsg = (TransportMsg*) call RoutingSend.getPayload(&mybuf, TR_DATA_LENGTH);

        call TrPacket.setHeader(tmsg, tid, mySeqNo++, PTR_FLAG_NOACK_SEND, 0);
        memcpy(tmsg->data, data, length);
        // set checksum after setting header and copying payload
        tmsg->checksum = tr_calculate_checksum(tmsg, length);

        if (mySeqNo == 0) mySeqNo = 1;

        if (call RoutingSend.send(addr, &mybuf, length + TR_HDR_LEN) != SUCCESS) {
            return FAIL;
        }
        sending = TRUE;
        return SUCCESS;
    }

    command uint8_t Send.maxPayloadLength() {
        return (call RoutingSend.maxPayloadLength() - TR_HDR_LEN);
    }

    default event void Send.sendDone(uint16_t tid, void *data, error_t succ) { }
}


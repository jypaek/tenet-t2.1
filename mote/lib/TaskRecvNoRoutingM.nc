/*
* "Copyright (c) 2006~2007 University of Southern California.
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
 * Pass the task received via link-layer (GenericComm.ReceiveMsg)
 * to the TaskInstaller through TaskRecv interface.
 *
 * We have this module to let the task installer have a common interface
 * (TaskRecv) regardless of the underlying communication method used
 * (either TRD, or GenericComm) to receive the tasking packet.
 *
 * @author Ben Greenstein
 * @author Jeongyeup Paek
 * Embedded Networks Laboratory, University of Southern California
 * @modified 2/5/2007
 **/
 
module TaskRecvNoRoutingM {
    provides {
        interface TaskRecv;
    }
    uses {
        interface Receive;
        interface Boot;
        interface SplitControl as RadioControl;
    }
}
implementation {

    event message_t* Receive.receive(message_t* m, void* payload, uint8_t len) {
        link_hdr_t *linkHdr;
        uint16_t length;
        if (m && len >= offsetof(link_hdr_t, data)){
            linkHdr = (link_hdr_t *)payload;
            length = len - offsetof(link_hdr_t, data);
            signal TaskRecv.receive(linkHdr->data, length, linkHdr->tid, linkHdr->src);
        }
        return m;
    }

    event void Boot.booted() {
        call RadioControl.start();
    }
    event void RadioControl.startDone(error_t err) { }
    event void RadioControl.stopDone(error_t err) { }
}


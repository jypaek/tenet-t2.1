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
 * @author Jeongyeup Paek
 * @modified Apr/1/2008
 **/


#include "transport.h"

configuration BestEffortTransportC {
    provides {
        interface TransportSend as Send;
    }
}
implementation {
    components  MainC
                , BestEffortTransportP as TransportP
                , TrPacketM
                ;

    MainC.SoftwareInit -> TransportP;

    Send = TransportP.Send;

    components CollectionC as Collector,
               new CollectionSenderC(PROTOCOL_PACKET_TRANSPORT);
    TransportP.RoutingSend -> CollectionSenderC.AMSend;
    TransportP.RoutingPacket -> Collector.CollectionPacket;

    TransportP.TrPacket -> TrPacketM;

}


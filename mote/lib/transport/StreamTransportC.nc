/*
* "Copyright (c) 2006~2009 University of Southern California.
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
 * StreamTransport: NACK based end-to-end reliable transport protocol.
 *
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * Embedded Networks Laboratory, University of Southern California
 * @modified Feb/27/2009
 **/


#include "transport.h"
#include "streamtransport.h"

configuration StreamTransportC {
    provides {
        interface ConnectionSend as Send;
    }
}
implementation {
    components MainC
                , StreamTransportM
                , StrLoggerC as Logger
                , TrPacketM
                ;

    MainC.SoftwareInit -> StreamTransportM;
    Send = StreamTransportM;

    components CollectionC as Collector,
               new CollectionSenderC(PROTOCOL_STREAM_TRANSPORT);
    StreamTransportM.RoutingSend -> CollectionSenderC.AMSend;
    StreamTransportM.RoutingReceive -> Collector.Receive[PROTOCOL_STREAM_TRANSPORT];
    StreamTransportM.RoutingPacket -> Collector.CollectionPacket;

    StreamTransportM.LoggerInit -> Logger.Init;
    StreamTransportM.PktLogger -> Logger.PktLogger;

    StreamTransportM.TrPacket -> TrPacketM;

    components new TimerMilliC() as RetryTimer;
    StreamTransportM.RetryTimer -> RetryTimer;
    components new TimerMilliC() as SubTimer;
    StreamTransportM.SubTimer -> SubTimer;
#ifdef STR_2_CON
    components new TimerMilliC() as SubTimer2;
    StreamTransportM.SubTimer2 -> SubTimer2;
#endif
}


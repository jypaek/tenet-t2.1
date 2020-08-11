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
 * Configuration for RCRT (Rate-controlled Reliable Transport protocol)
 *
 * - centralized rate adaptation
 * - end-2-end reliable loss recovery
 * - centralized/end-2-end rate allocation
 *
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * Embedded Networks Laboratory, University of Southern California
 * @modified Feb/27/2009
 **/


#include "transport.h"
#include "rcrtransport.h"

configuration RcrTransportC {
    provides {
        interface RcrtSend as Send;
    }
}
implementation {
    components MainC
                , RcrTransportM 
                , RtrLoggerC as Logger
                , TrPacketM
                ;

    MainC.SoftwareInit -> RcrTransportM;
    Send = RcrTransportM;

    components CollectionC as Collector,
               new CollectionSenderC(PROTOCOL_RCR_TRANSPORT);
    RcrTransportM.RoutingSend -> CollectionSenderC.AMSend;
    RcrTransportM.RoutingReceive -> Collector.Receive[PROTOCOL_RCR_TRANSPORT];
    RcrTransportM.RoutingPacket -> Collector.CollectionPacket;

    RcrTransportM.LoggerInit -> Logger.Init;
    RcrTransportM.PktLogger -> Logger.PktLogger;

    RcrTransportM.TrPacket -> TrPacketM;

    components LocalTimeMilliC;
    RcrTransportM.LocalTime -> LocalTimeMilliC;

    components new TimerMilliC() as RetryTimer;
    RcrTransportM.RetryTimer -> RetryTimer;
    components new TimerMilliC() as RateControlTimer;
    RcrTransportM.RateControlTimer -> RateControlTimer;
    components new TimerMilliC() as SubTimer;
    RcrTransportM.SubTimer -> SubTimer;
#ifdef RCRT_2_CON
    components new TimerMilliC() as RateControlTimer2;
    RcrTransportM.RateControlTimer2 -> RateControlTimer2;
    components new TimerMilliC() as SubTimer2;
    RcrTransportM.SubTimer2 -> SubTimer2;
#endif
}


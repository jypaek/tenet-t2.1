/*
* "Copyright (c) 2006-2007 University of Southern California.
* All rights reserved.
*
* Permission to use, copy, modify, and distribute this software and its
* documentation for any purpose, without fee, and without written
* agreement is hereby granted, provided that the above copyright
* notice, the following two paragraphs and the author appear in all
* copies of this software.
*
* IN NO EVENT SHALL THE UNIVERITY OF SOUTHERN CALIFORNIA BE LIABLE TO
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
 * This is the configuration file for Tenet mote binary
 * @author Everyone
 **/

/**
 * List of INCLUDE Tasklet definitions are in 'tasklets.h'
 **/
#include "tasklets.h"
#include "element_map.h"

configuration Tenet {
}
implementation {
  components MainC;

  components LedsC
            , MemoryM
            , TaskLib
            , TaskInstallerC as Install
            , TenetScheduler as Scheduler
            , ActiveMessageC
            , ErrorHandler
            , LocalTimeMilliC
            , LocalTimeC         // internally includes LocalTime32khzC
            ;


  /* Beginning of Tasklet wiring */

#ifdef ONE_HOP_TASKING
  components SendTest as SendPkt;
  components new AMSenderC(0x08) as TestSender; 
  components DummyRouteControlP as CollectionC;
  SendPkt.AMSend                            -> TestSender;
  SendPkt.RadioControl                      -> ActiveMessageC;
#else
  components SendPkt;
  components PacketTransportC;
  components BestEffortTransportC as TransportC;
  components CollectionC;
  SendPkt.Send                              -> PacketTransportC.Send;
  SendPkt.SendBE                            -> TransportC.Send;
  SendPkt.RoutingControl                    -> CollectionC;
  SendPkt.RouteControl                      -> CollectionC;
#endif
  Install.Element_u[ELEMENT_SENDPKT]        -> SendPkt.Element;
  SendPkt.Init                              <- MainC.SoftwareInit;
  SendPkt.TenetTask                         -> TaskLib;
  SendPkt.TaskError                         -> ErrorHandler;
  SendPkt.Memory                            -> MemoryM;
  SendPkt.Schedule                          -> Scheduler;
  SendPkt.List                              -> TaskLib;
  SendPkt.Boot                              -> MainC;
  SendPkt.RadioControl                      -> ActiveMessageC;

#ifdef GLOBAL_TIME
  components TimeSyncC, GlobalAlarmC;
#endif

#ifdef INCLUDE_ISSUE
  components Issue;
  Install.Element_u[ELEMENT_ISSUE]          -> Issue.Element;
  Issue.Init                                <- MainC.SoftwareInit;
  Issue.TenetTask                           -> TaskLib;
  Issue.Memory                              -> MemoryM;
  Issue.Schedule                            -> Scheduler;
  Issue.TaskError                           -> ErrorHandler;
  Issue.List                                -> TaskLib;
  components new TimerMilliC() as IssueTimer;
  Issue.IssueTimer                          -> IssueTimer;
  Issue.LocalTime                           -> LocalTimeMilliC;
#ifdef GLOBAL_TIME
  Issue.GlobalTime                          -> TimeSyncC;
  Issue.AbsoluteTimer                       -> GlobalAlarmC;
#endif
#endif

#ifdef INCLUDE_ACTUATE
  components Actuate;
  Install.Element_u[ELEMENT_ACTUATE]        -> Actuate.Element;
  Actuate.TenetTask                         -> TaskLib;
  Actuate.TaskError                         -> ErrorHandler;
  Actuate.Memory                            -> MemoryM;
  Actuate.Leds                              -> LedsC;
#endif

#ifdef INCLUDE_COUNT
  components Count;
  Install.Element_u[ELEMENT_COUNT]          -> Count.Element;
  Count.TenetTask                           -> TaskLib;
  Count.Memory                              -> MemoryM;
#endif

#ifdef INCLUDE_REBOOT
  components Reboot;
  Install.Element_u[ELEMENT_REBOOT]         -> Reboot.Element;
  Reboot.TenetTask                          -> TaskLib;
  Reboot.Memory                             -> MemoryM;
#endif

#ifdef INCLUDE_GET
  components Get;
  Install.Element_u[ELEMENT_GET]            -> Get.Element;
  Get.TenetTask                             -> TaskLib;
  Get.TaskError                             -> ErrorHandler;
  Get.Memory                                -> MemoryM;
  Get.Leds                                  -> LedsC;
  Get.LocalTimeMilli                        -> LocalTimeMilliC;
  Get.LocalTime32khz                        -> LocalTimeC;
  //Get.LocalTimeInfo                         -> LocalTimeC;
  Get.RouteControl                          -> CollectionC;
#ifdef GLOBAL_TIME
  Get.GlobalTime                            -> TimeSyncC;
#endif
#if defined(PLATFORM_TELOSB) || defined(PLATFORM_MICAZ) || defined(PLATFORM_IMOTE2)
  components CC2420ControlC;
  Get.CC2420Config                          -> CC2420ControlC;
#endif
#endif

#ifdef INCLUDE_LOGICAL
  components Logical;
  Install.Element_u[ELEMENT_LOGICAL]        -> Logical.Element;
  Logical.TenetTask                         -> TaskLib;
  Logical.TaskError                         -> ErrorHandler;
  Logical.Memory                            -> MemoryM;
#endif

#ifdef INCLUDE_ARITH
  components Arith;
  Install.Element_u[ELEMENT_ARITH]          -> Arith.Element;
  Arith.TenetTask                           -> TaskLib;
  Arith.TaskError                           -> ErrorHandler;
  Arith.Memory                              -> MemoryM;
#endif

#ifdef INCLUDE_COMPARISON
  components Comparison;
  Install.Element_u[ELEMENT_COMPARISON]     -> Comparison.Element;
  Comparison.TenetTask                      -> TaskLib;
  Comparison.TaskError                      -> ErrorHandler;
  Comparison.Memory                         -> MemoryM;
#endif

#ifdef INCLUDE_STATS
  components Stats;
  Install.Element_u[ELEMENT_STATS]          -> Stats.Element;
  Stats.TenetTask                           -> TaskLib;
  Stats.TaskError                           -> ErrorHandler;
  Stats.Memory                              -> MemoryM;
#endif

#ifdef INCLUDE_RLE
  components RunLengthEncoding as RLE;
  Install.Element_u[ELEMENT_RLE]            -> RLE.Element;
  RLE.TenetTask                             -> TaskLib;
  RLE.TaskError                             -> ErrorHandler;
  RLE.Memory                                -> MemoryM;
#endif

#ifdef INCLUDE_PACKBITS
  components PackBitsRle as PackBits;
  Install.Element_u[ELEMENT_PACKBITS]       -> PackBits.Element;
  PackBits.TenetTask                        -> TaskLib;
  PackBits.TaskError                        -> ErrorHandler;
  PackBits.Memory                           -> MemoryM;
#endif

#ifdef INCLUDE_VECTOR
  components Vector;
  Install.Element_u[ELEMENT_VECTOR]          -> Vector.Element;
  Vector.TenetTask                           -> TaskLib;
  Vector.TaskError                           -> ErrorHandler;
  Vector.Memory                              -> MemoryM;
#endif

// NOTE: SimpleSample and Sample cannot co-exist
#ifdef INCLUDE_SIMPLESAMPLE
  components SimpleSampleC as Sample;
  Install.Element_u[ELEMENT_SIMPLESAMPLE]   -> Sample.Element;
  Sample.Init                               <- MainC.SoftwareInit;
  Sample.TenetTask                          -> TaskLib;
  Sample.TaskError                          -> ErrorHandler;
  Sample.Memory                             -> MemoryM;
  Sample.Schedule                           -> Scheduler;
  Sample.List                               -> TaskLib;
#else
#ifdef INCLUDE_SAMPLE
  components SampleC as Sample;
  Install.Element_u[ELEMENT_SAMPLE]         -> Sample.Element;
  Sample.Init                               <- MainC.SoftwareInit;
  Sample.TenetTask                          -> TaskLib;
  Sample.TaskError                          -> ErrorHandler;
  Sample.Memory                             -> MemoryM;
  Sample.Schedule                           -> Scheduler;
  Sample.List                               -> TaskLib;
  Sample.LocalTime                          -> LocalTimeMilliC;
#endif
#endif

#ifdef INCLUDE_VOLTAGE
  components Voltage;
  components new VoltageC();
  Install.Element_u[ELEMENT_VOLTAGE]        -> Voltage.Element;
  Voltage.Init                              <- MainC.SoftwareInit;
  Voltage.TenetTask                         -> TaskLib;
  Voltage.Memory                            -> MemoryM;
  Voltage.Schedule                          -> Scheduler;
  Voltage.List                              -> TaskLib;
  Voltage.Read                              -> VoltageC;
#endif

#ifdef INCLUDE_PACK
  components Pack;
  Install.Element_u[ELEMENT_PACK]           -> Pack.Element;
  Pack.TenetTask                            -> TaskLib;
  Pack.TaskError                            -> ErrorHandler;
  Pack.Memory                               -> MemoryM;
#endif

#ifdef INCLUDE_DELETEATTRIBUTEIF
  components DeleteAttributeIf;
  Install.Element_u[ELEMENT_DELETEATTRIBUTEIF] -> DeleteAttributeIf.Element;
  DeleteAttributeIf.TenetTask               -> TaskLib;
  DeleteAttributeIf.TaskError               -> ErrorHandler;
  DeleteAttributeIf.Memory                  -> MemoryM;
#endif

#ifdef INCLUDE_DELETEACTIVETASKIF
  components DeleteActiveTaskIf;
  Install.Element_u[ELEMENT_DELETEACTIVETASKIF] -> DeleteActiveTaskIf.Element;
  DeleteActiveTaskIf.TenetTask              -> TaskLib;
  DeleteActiveTaskIf.TaskError              -> ErrorHandler;
  DeleteActiveTaskIf.Memory                 -> MemoryM;
#endif

#ifdef INCLUDE_DELETETASKIF
  components DeleteTaskIf;
  Install.Element_u[ELEMENT_DELETETASKIF]   -> DeleteTaskIf.Element;
  DeleteTaskIf.TenetTask                    -> TaskLib;
  DeleteTaskIf.TaskError                    -> ErrorHandler;
  DeleteTaskIf.Memory                       -> MemoryM;
#endif

#ifdef INCLUDE_SENDRCRT
  components SendRcrt, RcrTransportC;
  Install.Element_u[ELEMENT_SENDRCRT]       -> SendRcrt.Element;
  SendRcrt.Init                             <- MainC.SoftwareInit;
  SendRcrt.TenetTask                        -> TaskLib;
  SendRcrt.TaskError                        -> ErrorHandler;
  SendRcrt.Memory                           -> MemoryM;
  SendRcrt.Schedule                         -> Scheduler;
  SendRcrt.List                             -> TaskLib;
  SendRcrt.Send                             -> RcrTransportC;
  SendRcrt.RouteControl                     -> CollectionC;
#endif

#ifdef INCLUDE_SENDSTR
  components SendSTR, StreamTransportC;
  Install.Element_u[ELEMENT_SENDSTR]        -> SendSTR.Element;
  SendSTR.Init                              <- MainC.SoftwareInit;
  SendSTR.TenetTask                         -> TaskLib;
  SendSTR.TaskError                         -> ErrorHandler;
  SendSTR.Memory                            -> MemoryM;
  SendSTR.Schedule                          -> Scheduler;
  SendSTR.List                              -> TaskLib;
  SendSTR.Send                              -> StreamTransportC;
  SendSTR.RouteControl                      -> CollectionC;
#endif


  /* End of Tasklet wiring */


  /* Beginning of non-tasklet wirings */

  /** 
   * Task/Tasklet Error Handler
   **/
  ErrorHandler.TenetTask      -> TaskLib;
  ErrorHandler.TaskDelete     -> Install;
  ErrorHandler.Send           -> SendPkt.SneakSend;

  /** 
   * Tenet Task Library/Installer/Scheduler
   **/
  Scheduler.Boot              -> MainC;
  Scheduler.TenetTask         -> TaskLib;
  Scheduler.TaskDelete        -> Install;
  Scheduler.List              -> TaskLib;
  Scheduler.Leds              -> LedsC;
  Install.Init                <- MainC.SoftwareInit;
  TaskLib.Memory              -> MemoryM;
  Install.TenetTask           -> TaskLib;
  Install.List                -> TaskLib;
  Install.TaskError           -> ErrorHandler;
  Install.Schedule            -> Scheduler;

#ifdef ONE_HOP_TASKING // receive task in 1-hop via GenericComm
  components TaskRecvNoRoutingM;
  components new AMReceiverC(0x07) as TestReceiver; 
  Install.Boot                    -> MainC;
  Install.TaskRecv                -> TaskRecvNoRoutingM;
  TaskRecvNoRoutingM.Receive      -> TestReceiver;
  TaskRecvNoRoutingM.RadioControl -> ActiveMessageC;
  TaskRecvNoRoutingM.Boot         -> MainC;
#else
  components TaskRecvTRD;
  components TRD_TransportC;
  Install.TaskRecv                -> TaskRecvTRD;
  TaskRecvTRD.TRD_Transport       -> TRD_TransportC;
#endif


}


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
 * Configuration file for TRD state informations.
 *
 * TRD is a generic dissemination protocol that reliably delivers
 * packets to all nodes that runs TRD.
 * TRD_State module maintains states so that it can decide when and
 * what to disseminated and receive.
 *
 * @author Jeongyeup Paek
 * Embedded Networks Laboratory, University of Southern California
 * @modified 8/21/2006
 **/


configuration TRD_StateC {
    provides interface TRD_State;
}
implementation {

    components MainC
             , TRD_StateM   // actual module that maintains the state info.
             , TRD_LoggerC  // logger that writes TRD packets into the flash
             , TRD_TimerC   // implementation of trickle timer
             , LocalTimeMilliC
             , new TimerMilliC() as AgingTimer
             ;

    MainC.SoftwareInit -> TRD_StateM;
    TRD_State = TRD_StateM;
    TRD_StateM.Boot -> MainC;

    TRD_StateM.TimerControl -> TRD_TimerC;
    TRD_StateM.LoggerInit -> TRD_LoggerC;

    TRD_StateM.TRD_Timer -> TRD_TimerC;
    TRD_StateM.TRD_Logger -> TRD_LoggerC;

    TRD_StateM.AgingTimer -> AgingTimer;
    TRD_StateM.LocalTime -> LocalTimeMilliC;
}


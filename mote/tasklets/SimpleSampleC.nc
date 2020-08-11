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
 * Configuration file of tasklet SimpleSample.
 * SimpleSample is a tasklet that reads the sensor,
 * one sample from one channel at a time
 * It does the wiring for different platforms.
 *
 * @author Jeongyeup Paek
 * @modified 7/28/2007
 **/

configuration SimpleSampleC {
    provides {
        interface Init;
        interface Element;
    }
    uses {
        interface TenetTask;
        interface List;
        interface Schedule;
        interface Memory;
        interface TaskError;
    }
}
implementation {
  components SimpleSample
        #ifdef PLATFORM_TELOSB
           , new Msp430InternalVoltageC() as VoltageC
           , new Msp430InternalTemperatureC() as TempC
           , new HamamatsuS10871TsrC() as TsrC
           , new HamamatsuS1087ParC() as ParC
           , new SensirionSht11C() as TempHumidC
        #endif
           , SamplePlatform
           ;

    /* provided interfaces */
    Init       = SimpleSample;
    Element    = SimpleSample;

    /* used interfaces */
    TenetTask  = SimpleSample;
    List       = SimpleSample;
    Schedule   = SimpleSample;
    Memory     = SimpleSample;
    TaskError  = SimpleSample;

    /* internal interfaces */
    SimpleSample.ADC      -> SamplePlatform;
#ifdef PLATFORM_TELOSB
    SamplePlatform.InternalTemperature -> TempC;
    SamplePlatform.InternalVoltage  -> VoltageC;
    SamplePlatform.Tsr -> TsrC;
    SamplePlatform.Par -> ParC;
    SamplePlatform.Temperature -> TempHumidC.Temperature;
    SamplePlatform.Humidity -> TempHumidC.Humidity;
#endif

}


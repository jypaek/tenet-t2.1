/**
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
 **/ 

/**
 * Get
 *
 * - This tasklet gets the values of system variables, defined by value, 
 *   and assigns them to attr. Depending on value, attr may be a scalar 
 *   or a vector. 
 *
 *  1 (ROUTING_PARENT)
 *  2 (GLOBAL_TIME) 
 *  3 (LOCAL_TIME) 
 *  4 (MEMORY_STATS) 
 *  5 (NUM_TASKS)
 *  6 (NUM_ACTIVE_TASKS)
 *  7 (CHILDREN)
 *  8 (NEIGHBORS)
 *  9 (LEDS)
 * 10 (RF_POWER)
 * 11 (RF_CHANNEL)
 * 12 (IS_TIMESYNC)
 * 13 (TOS_LOCAL_ADDRESS)
 * 14 (GLOBAL_TIME_MS)
 * 15 (LOCAL_TIME_MS)
 * 16 (ROUTING_PARENT_LINKQUALITY)
 * 17 (PLATFORM)
 * 18 (CLOCL_FREQ)
 * 19 (ROUTING_MASTER)
 * 20 (ROUTING_HOPCOUNT)
 * 21 (ROUTING_PARENT_RSSI)
 *
 * @author Ki-Young Jang
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * Embedded Networks Laboratory, University of Southern California
 * @modified Feb/27/2009
 **/

#include "tenet_task.h"

module Get {
    provides {
        interface Element;
    }
    uses {
        interface TenetTask;
        interface TaskError;
        interface Memory;
    #ifdef GLOBAL_TIME
        interface GlobalTime<TMilli>;
    #endif
        interface LocalTime<TMilli> as LocalTimeMilli;
        interface LocalTime<T32khz> as LocalTime32khz;
        //interface LocalTimeInfo;
        interface Leds;
        interface RouteControl;
    #if defined(PLATFORM_TELOSB) || defined(PLATFORM_MICAZ) || defined(PLATFORM_IMOTE2)
        interface CC2420Config;
    #endif
    }
}
implementation {

    typedef struct get_element_s {
        element_t e;
        tag_t type;
        uint16_t value;
    } __attribute__((packed)) get_element_t;

    void get_suicide(task_t *t, element_t *e) {} // nothing to do

    sched_action_t get_run(active_task_t *active_task, element_t *e) {
        get_element_t* ge = (get_element_t *)e;
    #ifdef GLOBAL_TIME
        uint32_t data32 = 0;
    #endif
        nx_uint16_t nxdata16;
        nx_uint32_t nxdata32;
        uint8_t isData32 = 0;
        nxdata16 = 0;
        nxdata32 = 0;

        switch ( ge->value )
        {
            case GET_TOS_LOCAL_ADDRESS:
                nxdata16 = TOS_NODE_ID;
                break;
            case GET_PLATFORM:
            #ifdef PLATFORM_TELOSB
                nxdata16 = TELOSB;
            #elif PLATFORM_MICAZ
                nxdata16 = MICAZ;
            #elif PLATFORM_IMOTE2
                nxdata16 = IMOTE2;
            #elif PLATFORM_MICA2
                nxdata16 = MICA2;
            #elif PLATFORM_MICA2DOT
                nxdata16 = MICA2DOT;
            #endif
                break;
            case GET_NUM_TASKS:
                nxdata16 = call TenetTask.get_task_count();
                break;
            case GET_NUM_ACTIVE_TASKS:
                nxdata16 = call TenetTask.get_active_task_count();
                break;
            case GET_LEDS:
                atomic {
                    nxdata16 = (nx_uint16_t)call Leds.get();
                }
                break;
            case GET_LOCAL_TIME:
                nxdata32 = call LocalTime32khz.get();
                isData32 = 1;
                break;
            case GET_LOCAL_TIME_MS:
                nxdata32 = call LocalTimeMilli.get();
                isData32 = 1;
                break;
            case GET_CLOCK_FREQ:
                nxdata16 = 32768U;   // T32KHz
                //nxdata16 = (uint16_t)call LocalTimeInfo.getClockFreq();
                break;
            case GET_RF_POWER:
            #if defined(PLATFORM_TELOSB) || defined(PLATFORM_MICAZ) || defined(PLATFORM_IMOTE2)
                nxdata16 = CC2420_DEF_RFPOWER;
            #endif
                break;
            case GET_RF_CHANNEL:
            #if defined(PLATFORM_TELOSB) || defined(PLATFORM_MICAZ) || defined(PLATFORM_IMOTE2)
                nxdata16 = call CC2420Config.getChannel();
            #endif
                break;
            case GET_IS_TIMESYNC:
            #ifdef GLOBAL_TIME
                if (call GlobalTime.getGlobalTime(&data32) == SUCCESS)
                    nxdata16 = 1;
            #endif
                break;
            case GET_GLOBAL_TIME:   // in T2/tos/lib/ftsp, GlobalTime is always MS.
            case GET_GLOBAL_TIME_MS:
            #ifdef GLOBAL_TIME
                call GlobalTime.getGlobalTime(&data32);
                nxdata32 = data32;  // nx conversion happens automatically here
                isData32 = 1;
            #endif
                break;
            case GET_ROUTING_PARENT:
                nxdata16 = call RouteControl.getParent();
                break;
            case GET_ROUTING_HOPCOUNT:
                nxdata16 = call RouteControl.getDepth();
                break;
            case GET_ROUTING_PARENT_LINKQUALITY:
                nxdata16 = call RouteControl.getQuality();
                break;
            case GET_ROUTING_PARENT_RSSI:
                nxdata16 = (uint16_t)call RouteControl.getLinkRssi();
                break;
            case GET_ROUTING_MASTER:
                nxdata16 = 0xffff;
                break;
            default:
                call TaskError.kill(active_task->t, ERR_INVALID_OPERATION, ELEMENT_GET, active_task->element_index);
                return SCHED_TERMINATE;
                break;
        }
        if (isData32 == 1) {
            call TenetTask.data_push(active_task,
                    call TenetTask.data_new_copy(ge->type, sizeof(uint32_t), &nxdata32));
        } else {
            call TenetTask.data_push(active_task,
                    call TenetTask.data_new_copy(ge->type, sizeof(uint16_t), &nxdata16));
        }
        return SCHED_NEXT;
    }

    command element_t *Element.construct(task_t *t, void *data, uint16_t length) {
        get_element_t *e;
        get_params_t *p;
        if (data == NULL || length < sizeof(get_params_t)) {
            return NULL;
        }
        if ((e = (get_element_t *)call Memory.malloc(sizeof(get_element_t))) == NULL) {
            return NULL;
        }
        p = (get_params_t *)data;
        call TenetTask.element_construct(t, (element_t *)e,
                ELEMENT_GET, get_run,
                get_suicide);
        e->type = p->type;
        e->value = p->value;
        return (element_t *)e;
    } 

#if defined(PLATFORM_TELOSB) || defined(PLATFORM_MICAZ) || defined(PLATFORM_IMOTE2)
    event void CC2420Config.syncDone( error_t error ) {}
#endif
}

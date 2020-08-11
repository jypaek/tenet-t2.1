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
 */

/**
 * Actuate(chan, argtype, value)
 *
 * - This tasklet actuates a particular channel. 
 *   The action taken depends on the value of the chan attribute. 
 *   Value is a literal constant if argtype is 0 (ARGTYPE_CONSTANT), 
 *   else Value is the name of a scalar variable.
 *
 *   Currently defined values of this attribute are:
 *   - 0 (LED)        : the action is the set the LEDs. 
 *   - 1 (RF_POWER)   : set the transmit RF power value.
 *   - 2 (SOUNDER)    : turn on/off the sounder on micasb (for mica2/micaz)
 *   - 3 (LED TOGGLE) : the action is the toggles the LEDs. 
 *
 * @author Marcos Vieira
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * @modified Feb/27/2009
 **/


#include "tenet_task.h"

module Actuate{
    provides {
        interface Element;
    }
    uses {
        interface Leds;
        interface TenetTask;
        interface Memory;
        interface TaskError;
    }
}
implementation {

    typedef struct actuate_element_s {
        element_t e;
        uint8_t chan;
        uint8_t argtype;
        tag_t arg1;  /* an attribute name, or a constant, depending on 'argtype' */
    } __attribute__((packed)) actuate_element_t;

    void actuate_suicide(task_t *t, element_t *e) { }

    sched_action_t actuate_run(active_task_t *active_task, element_t *e) {
        actuate_element_t *ae = (actuate_element_t *)e;
        data_t *t;
        nx_uint16_t *dataptr;
        nx_uint16_t data;

        if (ae->argtype == ARGTYPE_CONSTANT) { // argument is a constant
            data = ae->arg1;
        
        } else { /* ARGTYPE_ATTRIBUTE *///otherwise read from attribute
            if ((t = call TenetTask.data_get_by_type(active_task, ae->arg1)) == NULL) {
                call TaskError.kill(active_task->t, ERR_INVALID_ATTRIBUTE, ELEMENT_ACTUATE, ae->arg1);
                return SCHED_TERMINATE;
            }
            dataptr = (nx_uint16_t*)t->attr.value;
            data = dataptr[0];
        }    

        switch (ae->chan) {
            case ACTUATE_LEDS:
                call Leds.set((uint8_t)data);
                break;
            case ACTUATE_LEDS_TOGGLE:
                if (((uint8_t)data) & 0x01)
                    call Leds.led0Toggle();
                if (((uint8_t)data) & 0x02)
                    call Leds.led1Toggle();
                if (((uint8_t)data) & 0x04)
                    call Leds.led2Toggle();
                break;
            default:
                call TaskError.kill(active_task->t, ERR_INVALID_OPERATION, ELEMENT_ACTUATE, active_task->element_index);
                return SCHED_TERMINATE;
        }
        return SCHED_NEXT;
    }

    command element_t *Element.construct(task_t *t, void *data, uint16_t length) {
        actuate_element_t *e;
        actuate_params_t *p = (actuate_params_t *)data;

        if (data == NULL || length < sizeof(actuate_params_t))
            return NULL;
        if ((e = (actuate_element_t *)call Memory.malloc(sizeof(actuate_element_t))) == NULL)
            return NULL;

        call TenetTask.element_construct(t, (element_t *)e,
                    ELEMENT_ACTUATE, actuate_run, actuate_suicide);

        e->chan = p->chan;
        e->argtype = p->argtype;
        e->arg1 = p->arg1;
        
        return (element_t *)e;
    }

}


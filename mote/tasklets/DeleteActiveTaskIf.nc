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
 * deleteactivetaskif(arg, argtype)
 *
 * This tasklet deletes just the current instance of this task if
 * one of these two conditions is true:
 * argtype is 1 and value of attribute identified by arg is non-zero
 * OR
 * argtype is not 1 and arg is non-zero.
 * 
 * @author Omprakash Gnawali
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * @modified Feb/27/2009
 **/

#include "tenet_task.h"

module DeleteActiveTaskIf {
    provides {
        interface Element;
    }
    uses {
        interface TenetTask;
        interface Memory;
        interface TaskError;
    }
}
implementation {

    typedef struct deleteActiveTaskIf_element_s {
        element_t e;
        nxtag_t arg;
        uint8_t argtype;
        uint8_t pad;
    } deleteActiveTaskIf_element_t;

    void deleteActiveTaskIf_suicide(task_t *t, element_t *e) {} // nothing to do

    sched_action_t deleteActiveTaskIf_run(active_task_t *active_task, element_t *e) {
        deleteActiveTaskIf_element_t *de = (deleteActiveTaskIf_element_t *)e;
        data_t *d = NULL;
        nx_uint16_t *arg = NULL;

        if (de->argtype == ARGTYPE_ATTRIBUTE) {
            if ((d = call TenetTask.data_get_by_type(active_task, de->arg)) != NULL) {
                arg = (nx_uint16_t *)d->attr.value;
            }
        } else {
            arg = &de->arg;
        }

        if (!arg) {
            call TaskError.kill(active_task->t, ERR_INVALID_ATTRIBUTE, 
                                ELEMENT_DELETEACTIVETASKIF, de->arg);
            return SCHED_TERMINATE;
        }

        if (*arg != FALSE) {
            return SCHED_TERMINATE;
        }

        return SCHED_NEXT;
    }

    command element_t *Element.construct(task_t *t, void *data, uint16_t length) {
        deleteActiveTaskIf_element_t *e;
        deleteActiveTaskIf_params_t *p = (deleteActiveTaskIf_params_t *)data;

        if (data == NULL || length < sizeof(deleteActiveTaskIf_params_t))
            return NULL;
        if ((e = (deleteActiveTaskIf_element_t *)
                    call Memory.malloc(sizeof(deleteActiveTaskIf_element_t))) == NULL)
            return NULL;

        call TenetTask.element_construct(t, (element_t *)e,
                ELEMENT_DELETEACTIVETASKIF, deleteActiveTaskIf_run,
                deleteActiveTaskIf_suicide);

        e->arg = p->arg;
        e->argtype = p->argtype;
        return (element_t *)e;
    }

}


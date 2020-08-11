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
 * Platform independent sampling for one channel at rates <= 10Hz.
 *
 * @author Jeongyeup Paek
 * Embedded Networks Laboratory, University of Southern California
 * @modified 7/28/2007
 **/

#include "tenet_task.h"

module SimpleSample {
    provides {
        interface Init;
        interface Element;
    }
    uses {
        interface SampleADC as ADC;
        interface Schedule;
        interface List;
        interface TenetTask;
        interface Memory;
        interface TaskError;
    }
}
implementation {

    typedef struct simpleSample_element_s {
        element_t e;
        tag_t outputName;
        uint8_t channel;
        uint8_t pad;
    } __attribute__((packed)) simpleSample_element_t;

    sched_action_t sample_run(active_task_t *active_task, element_t *e);

    list_t m_list;
    norace nx_uint16_t m_data;
    norace bool m_adc_busy;
    active_task_t *m_pending_atask;
    uint8_t m_task_count = 0;           /* number of tasks using this tasklet */

    task void fetch_now();
    task void handle_data();

    /* remove active tasks (whose task matches t) in the waiting list */
    list_action_t remove_task(void *item, void *meta) {
        active_task_t *at = (active_task_t *)item;
        task_t *t = (task_t *)meta;
        if (at->t == t) {
            at->t->block_cloning = FALSE;
            call TenetTask.active_task_delete(at);
            return LIST_REMOVE;
        }
        return LIST_CONT;
    }

    void sample_suicide(task_t *t, element_t *e) {
        if ((m_pending_atask != NULL) && (m_pending_atask->t == t)) {
            m_pending_atask->t->block_cloning = FALSE;
            call TenetTask.active_task_delete(m_pending_atask);
            m_pending_atask = NULL;
        }
        call List.iterate(&m_list, remove_task, t);
        if (--m_task_count == 0)    // if # of tasks using this tasklet is zero
            call ADC.stop();        // turn ADC off
    }

    command element_t *Element.construct(task_t *t, void *data, uint16_t length) {
        simpleSample_element_t *e;
        simpleSample_params_t *p;
        if (data == NULL || length < sizeof(simpleSample_params_t)) {
            return NULL;
        }
        if ((e = (simpleSample_element_t *)call Memory.malloc(sizeof(simpleSample_element_t))) == NULL) {
            return NULL;
        }
        p = (simpleSample_params_t *)data;
        call TenetTask.element_construct(t, (element_t *)e,
                ELEMENT_SIMPLESAMPLE,
                sample_run,
                sample_suicide);

        /* there are some problems on micasb/micaz for temperature sensing*/
        /* refer to tinyos-1.x/tos/platform/micaz/README */
        /* we are not doing channel checking here.... someone should??? */
        e->channel = p->channel;
        e->outputName = p->outputName;
        if (++m_task_count == 1)    // if # of tasks using this tasklet was zero
            call ADC.start();       // turn on ADC now
        return (element_t *)e;
    }

    sched_action_t sample_run(active_task_t *active_task, element_t *e) {
        simpleSample_element_t *se;
        if ((se = (simpleSample_element_t *)call TenetTask.element_this(active_task)) == NULL) {
            return SCHED_NEXT;
        }
        
        // push active task into 'to-process' queue.
        if (!call List.push(&m_list, active_task)) {
            call TaskError.kill(active_task->t, ERR_QUEUE_OVERFLOW, 
                                ELEMENT_SIMPLESAMPLE, active_task->element_index);
            return SCHED_TERMINATE;
        }

        if (!m_adc_busy) {      // adc_idle, we are not waiting for ADC.getDone
            post fetch_now();
        }
        active_task->t->block_cloning = TRUE;
        return SCHED_STOP;
    }

    task void fetch_now() {
        simpleSample_element_t *se;
        active_task_t *at;

        if ((call List.empty(&m_list)) || (m_pending_atask != NULL))
            return;

        if ((at = (active_task_t *)call List.pop(&m_list)) != NULL) {
            se = (simpleSample_element_t *)call TenetTask.element_this(at);
            m_adc_busy = TRUE;
            m_pending_atask = at;
            if (call ADC.getData(se->channel) == FAIL) {
                m_data = 0;
                post handle_data();
            }
        }
    }
   
    task void handle_data() {
        simpleSample_element_t *se;
        
        if ((m_pending_atask == NULL) || // this must be an error!!
            ((se = (simpleSample_element_t *)call TenetTask.element_this(m_pending_atask)) == NULL)) {
            post fetch_now();
            return;
        }

        call TenetTask.data_push(m_pending_atask,
                call TenetTask.data_new_copy(se->outputName, sizeof(uint16_t), &m_data));

        call List.remove(&m_list, m_pending_atask);
        m_pending_atask->t->block_cloning = FALSE;
        call Schedule.next(m_pending_atask); // schedule the original active task
        m_pending_atask = NULL;

        post fetch_now();
    }

    event void ADC.dataReady(error_t err, uint16_t data) {
        m_adc_busy = FALSE;
        if (err == SUCCESS) {
            m_data = data;
            post handle_data();
        } else {
            if (m_pending_atask == NULL) { // this must be an bug!!
                post fetch_now();
                return;
            }
            call TaskError.report(m_pending_atask->t, ERR_SENSOR_ERROR, 
                    ELEMENT_SIMPLESAMPLE, m_pending_atask->element_index);
            m_pending_atask->t->block_cloning = FALSE;
            call TenetTask.active_task_delete(m_pending_atask);
            m_pending_atask = NULL;
            post fetch_now();
        }
    }

    command error_t Init.init() {
        call List.init(&m_list);
        call ADC.init();
        m_adc_busy = FALSE;
        return SUCCESS;
    }
}


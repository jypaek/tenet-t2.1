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
 * Platform independent sampling for one ADC channel at rates <= 10Hz.
 * - API: 'Sample(interval, num_samples, ADC, TAG))
 *
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * @author Marcos Vieira
 * @author August Joki
 *
 * @modified Feb/27/2009
 **/

#include "tenet_task.h"

module Sample {
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
        interface Timer<TMilli>;
        interface LocalTime<TMilli>;
    }
}
implementation {

    typedef struct sample_element_s {
        element_t e;
        uint32_t interval;  // sampling interval. (recommend > 10ms)
        uint16_t count;
        tag_t outputName;
        uint8_t channel;
        uint8_t repeat;     // repeat?
        nx_uint16_t *data;
    } __attribute__((packed)) sample_element_t;

    typedef struct sample_item_s {
        active_task_t *active_task;
        uint32_t expire_offset_ms;
        uint16_t count;
    } sample_item_t;


    list_t m_list;                      /* list of active tasks currently waiting for ADC */
    norace nx_uint16_t m_data;
    norace bool m_adc_busy = FALSE;     /* ADC busy, if between get and getDone */
    sample_item_t *m_pending_item = NULL;   /* active task currently accessing ADC */
    uint8_t m_task_count = 0;           /* number of tasks using this tasklet */

    uint32_t m_list_time = 0;
    uint32_t m_next_offset = 0;

    task void handle_data();


/*************************************************************************/
    /**
     * remove_task
     * - remove active tasks (whose task matches t) in the waiting list 
     * - called only from 'suicide'
     **/
    list_action_t remove_task(void *item, void *meta) {
        task_t *t = (task_t *)meta;
        sample_item_t *si = (sample_item_t *)item;

        if (si->active_task->t == t) {
            si->active_task->t->block_cloning = FALSE;
            call TenetTask.active_task_delete(si->active_task);
            si->active_task = NULL;
            if (m_pending_item == si)
                m_pending_item = NULL;
            call Memory.free(si);
            return LIST_REMOVE;
        }
        return LIST_CONT;
    }

    void sample_suicide(task_t *t, element_t *e) {
        sample_element_t *se = (sample_element_t *)e;
        call Memory.free(se->data);
        call List.iterate(&m_list, remove_task, t);
        if (--m_task_count == 0)    // if # of tasks using this tasklet is zero
            call ADC.stop();        // turn ADC off
    }

/*************************************************************************/
    /**
     * - for each item(task) waiting in the list, 
     *   update the time left till the next sample time
     * - called only from 'update_remaining_times'
     **/
    list_action_t update_offset(void *item, void *meta) {
        // *meta is the 'offset' amount of time that has passed since last update.
        sample_item_t *si = (sample_item_t *)item;
        uint32_t curr_offset = *(uint32_t *)meta;
        if (si->expire_offset_ms < curr_offset) /* time to fetch ADC */
            si->expire_offset_ms = 0;
        else                                    /* not yet */
            si->expire_offset_ms -= curr_offset;
        #ifdef PLATFORM_MICAZ
        if (si->expire_offset_ms < 3)   // timer problem in micaz
            si->expire_offset_ms = 0;   // cannot fire 1 or 2 ms
        #endif
        return LIST_CONT;
    }

    /* update remaining times for all the active tasks in the waiting list */
    void update_remaining_times() {
        uint32_t curr_time, offset_ms;
        curr_time = call LocalTime.get();      // current time in ticks
        offset_ms = curr_time - m_list_time;    // time passed since last update
        call List.iterate(&m_list, update_offset, &offset_ms);
        m_list_time = curr_time;                // update the last update time
    }

/*************************************************************************/
    /**
     * - compare time-left-till-next-sampling of all waiting items, 
     *   and find the next item (and it's remaing time) to fetch ADC for.
     * - called only from 'get_next_item'
     **/
    list_action_t compare_time(void *item, void *meta) {
        sample_item_t *si = (sample_item_t *)item;

        if (si->expire_offset_ms == 0) {
            m_pending_item = si;  // this item
            return LIST_BREAK;
        }
        if (m_next_offset == 0 || si->expire_offset_ms < m_next_offset) { 
            m_pending_item = si;
            m_next_offset = si->expire_offset_ms;
        }
        return LIST_CONT;
    }

/*************************************************************************/

    void get_next_item() {  // get or wait for next item (set timer for next item)
        if (!call List.empty(&m_list)) {    // there are tasks waiting to sample
            update_remaining_times();
            m_next_offset = 0;              // init next fetch time
            call List.iterate(&m_list, compare_time, NULL); // find next fetch time

            if (m_pending_item->expire_offset_ms == 0)  { // now!!
                sample_element_t *se = (sample_element_t *)call TenetTask.element_this(m_pending_item->active_task);
                if (call ADC.getData(se->channel) == SUCCESS) {
                    m_adc_busy = TRUE;
                } else {
                    m_data = 0;
                    post handle_data();
                }
            }
            else                                        // not now.
                call Timer.startOneShot(m_next_offset);
        }
    }

/*************************************************************************/

    sched_action_t sample_run(active_task_t *active_task, element_t *e) {
        sample_element_t *se = (sample_element_t *)e;
        sample_item_t *si;

        if ((si = (sample_item_t *)call Memory.malloc(sizeof(sample_item_t))) == NULL) {
            call TaskError.report(active_task->t, ERR_MALLOC_FAILURE, 
                                  ELEMENT_SAMPLE, active_task->element_index);
            return SCHED_NEXT;
        }
        
        // no two active task from the same task can be queued here.
        call List.iterate(&m_list, remove_task, active_task->t); 
        
        call Timer.stop();          // now is the new reference point
        update_remaining_times();   // update next fetch time of all other waiting tasks

        si->active_task = active_task;
        si->expire_offset_ms = 0;       /* fetch now!! */
        si->count = 0;

        // push active task into 'to-process' queue.
        if (!call List.push(&m_list, si)) {
            call TaskError.kill(active_task->t, ERR_QUEUE_OVERFLOW, 
                                ELEMENT_SAMPLE, active_task->element_index);
            return SCHED_TERMINATE;
        }

        if (!m_adc_busy) {          // adc_idle, we are not waiting for ADC.getDone
            m_pending_item = si;    // this item
            if (call ADC.getData(se->channel) == SUCCESS) {
                m_adc_busy = TRUE;
            } else {
                m_data = 0;
                post handle_data();
            }
        }
        active_task->t->block_cloning = TRUE;
        return SCHED_STOP;
    }

/*************************************************************************/

    command element_t *Element.construct(task_t *t, void *data, uint16_t length) {
        sample_element_t *e;
        sample_params_t *p = (sample_params_t *)data;

        if (data == NULL || length < sizeof(sample_params_t)) {
            return NULL;
        }
        if (call ADC.validChannel(p->channel) == FALSE) {
            call TaskError.report(t, ERR_INVALID_TASK_PARAMETER, ELEMENT_SAMPLE, p->channel);
            return NULL;
        }
        if ((e = (sample_element_t *)call Memory.malloc(sizeof(sample_element_t))) == NULL) {
            return NULL;
        }
        if ((e->data = (nx_uint16_t *)call Memory.malloc(sizeof(uint16_t)*p->count)) == NULL) {
            call Memory.free(e);
            return NULL;
        }

        call TenetTask.element_construct(t, (element_t *)e,
                ELEMENT_SAMPLE,
                sample_run,
                sample_suicide);

        e->interval = p->interval;      // in millisec. used for repeating if > 0
        e->channel = p->channel;
        e->outputName = p->outputName;
        e->count = p->count;
        e->repeat = p->repeat;

        if (++m_task_count == 1)    // if # of tasks using this tasklet was zero
            call ADC.start();       // turn on ADC now
        return (element_t *)e;
    }

/*************************************************************************/

    task void handle_data() {
        sample_element_t *se;
        active_task_t *at = NULL;
        active_task_t *a_clone = NULL;
        
        if (m_pending_item == NULL) {
            get_next_item();
            return;
        }

        at = m_pending_item->active_task;
        se = (sample_element_t *)call TenetTask.element_this(at);

        (se->data)[m_pending_item->count] = m_data;
        m_pending_item->count += 1;
        m_pending_item->expire_offset_ms = se->interval;

        if (m_pending_item->count == se->count) { // data full

            if (se->repeat) { // clone before copying data
                // What if we are cloning too fast? 
                // check (block_cloning? sendbusy? num_atask?) --> resource_busy?
                a_clone = call TenetTask.active_task_clone(at);
                if (a_clone == NULL) {
                    call TaskError.report(at->t, ERR_MALLOC_FAILURE, 
                                          ELEMENT_SAMPLE, at->element_index);
                } else {
                    m_pending_item->active_task = a_clone; // switch active task
                    m_pending_item->count = 0;
                }
            }
            else { //don't need item anymore
                m_pending_item->active_task->t->block_cloning = FALSE;
                call List.remove(&m_list, m_pending_item);
                m_pending_item->active_task = NULL;
                call Memory.free(m_pending_item);
                m_pending_item = NULL;
            }

            call TenetTask.data_push(at, call TenetTask.data_new_copy(se->outputName,
                                     sizeof(uint16_t)*se->count, se->data));
            call Schedule.next(at); // schedule the original active task
        }
        get_next_item();
    }

/*************************************************************************/

    event void Timer.fired() {
        update_remaining_times();
        get_next_item();
    }

    event void ADC.dataReady(error_t err, uint16_t data) {
        m_adc_busy = FALSE;
        if (err == SUCCESS) {
            m_data = data;
            post handle_data();
        } else {
            if (m_pending_item != NULL) {
                active_task_t *at = m_pending_item->active_task;
                call TaskError.kill(at->t, ERR_SENSOR_ERROR, ELEMENT_SAMPLE, at->element_index);
            }
            get_next_item();
        }
    }

/*************************************************************************/
    command error_t Init.init() {
        call List.init(&m_list);
        call ADC.init();
        m_adc_busy = FALSE;
        return SUCCESS;
    }

}


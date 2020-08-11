/**
 * Tenet Task Interface
 *
 * Interface for tasklet creation, deletion, manipulation of
 * bag of attributes, status inquiry, etc.
 *
 **/

#include "tenet_task.h"

interface TenetTask {

  /* get task type, tid, and source */

  command uint32_t task_id(active_task_t *atask);
  command uint16_t get_tid(task_t *t);
  command uint16_t get_src(task_t *t);
  
  /* construct a new tasklet, get a handle to the tasklet */

  command void element_construct(task_t *t, element_t *e, 
                                 uint16_t id, run_t run, suicide_t suicide);
  command element_t *element_this(active_task_t *atask);
  

  /* crete, clone, delete active tasks */

  command active_task_t *active_task_new(task_t *t);
  command active_task_t *active_task_clone(active_task_t *atask);
  command void active_task_delete(active_task_t *active_task);
  
  /* manipulate the data in the bag of attributes */

  command data_t *data_new(tag_t type, uint16_t length, void * value);
  command data_t *data_new_copy(tag_t type, uint16_t length, void * value);
  command void data_delete(data_t *data);
  command data_t *data_get_by_type(active_task_t *active_task, tag_t type);
  command data_t *data_copy(data_t *data);
  command void data_push(active_task_t *at, data_t *d);
  command data_t *data_pop(active_task_t *at);
  command bool data_remove(active_task_t *active_task, data_t *d);
  command uint16_t data_serialize(active_task_t *at, uint8_t *dst, uint16_t dst_len);

  /* create/delete tasks */

  command task_t *task_new(uint8_t num_elements, uint32_t id);
  command void task_delete(task_t *t);

  /* Statistics */

  command uint16_t get_task_count();
  command uint16_t get_active_task_count();
}

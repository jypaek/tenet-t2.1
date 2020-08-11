/*
 * Translate a tasklet string into tasklet packet format (like binary format) 
 * for motes to understand it and be able to get the tasklet parameters.
 * Every created tasklet should have its construct. 
 *
 */
#include "element_construct.h"
#include "element_map.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "nx.h"

#ifdef DEBUG_ELEMENT
#define DEBUG_ELEMENT_CONSTRUCT 1
#endif


/* first function called by tp.c while constructing a task packet */
int construct_init(unsigned char* buf){
    int len;
    task_msg_t *taskMsg;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr,"creating INSTALL task\n");
#endif
    taskMsg = (task_msg_t *)(buf);
    taskMsg->type = TASK_INSTALL;

    len = sizeof(task_msg_t);

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, " task_msg_t length %d\n", len);
#endif
    return len;
}


/* This function set's the "num_element' field in the 
   INSTALL tasking packet after all elements are constructed */
int construct_finalize(unsigned char* buf, int num_elements){
    task_msg_t *taskMsg;

    taskMsg = (task_msg_t *)(buf);
    taskMsg->numElements = num_elements;

    return 0;
}


/* This function constructs a complete DELETE task packet */
int construct_delete(unsigned char* buf) {
    int len = sizeof(task_msg_t);
    task_msg_t *taskMsg;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr,"creating DELETE task\n");
#endif
    taskMsg = (task_msg_t *)(buf);
    taskMsg->type = TASK_DELETE;
    taskMsg->numElements = 0;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "task_msg_t length %d\n", len);
#endif
    return len;
}


/******** Below are constructors for default tasklets ********/

int construct_issue(unsigned char* buf, int len, int *num_elements,
		    uint32_t starttime, uint32_t period ,uint8_t abst) {
    attr_t *attr;
    issue_params_t *issue;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_ISSUE);
    attr->length = hxs(sizeof(issue_params_t));
    issue = (issue_params_t *)(attr->value);
    issue->starttime = hxl(starttime);
    issue->period = hxl(period);
    issue->abs = abst;

    len = sizeof(attr_t) + sizeof(issue_params_t); 
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + issue %u = length %d\n",
            sizeof(attr_t), sizeof(issue_params_t), len);
#endif
    return len;
}

int construct_count(unsigned char* buf, int len, int *num_elements, 
                    uint16_t tag, int16_t count, int16_t rate) {
    attr_t *attr;
    count_params_t *cnt;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_COUNT);
    attr->length = hxs(sizeof(count_params_t));
    cnt = (count_params_t *)(attr->value);
    cnt->type = hxs(tag);
    cnt->count = hxs((uint16_t)count);
    cnt->rate = hxs(rate);

    len = sizeof(attr_t) + sizeof(count_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + count %u = length %d\n",
            sizeof(attr_t), sizeof(count_params_t), len);
#endif
    return len;
}

int construct_get(unsigned char* buf, int len, int *num_elements, 
                  uint16_t tag, uint16_t value) {
    attr_t *attr;
    get_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_GET);
    attr->length = hxs(sizeof(get_params_t));
    n = (get_params_t *)(attr->value);
    n->type = hxs(tag);
    n->value = hxs(value);

    len = sizeof(attr_t) + sizeof(get_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + get %u = length %d\n",
            sizeof(attr_t), sizeof(get_params_t), len);
#endif
    return len;
}

int construct_actuate(unsigned char* buf, int len,int *num_elements,
                      uint8_t chan, uint8_t argtype, uint16_t arg1) {
  attr_t *attr;
  actuate_params_t *actuate;

  attr=(attr_t*)(buf+len);
  attr->type = hxs(ELEMENT_ACTUATE);
  attr->length = hxs(sizeof(actuate_params_t));
  actuate=(actuate_params_t *)(attr->value);
  actuate->chan = chan;
  actuate->argtype = argtype;
  actuate->arg1 = hxs(arg1);

  len=sizeof(attr_t)+sizeof(actuate_params_t);
  (*num_elements)++;

  #if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + actuate %u = length %d\n",
            sizeof(attr_t), sizeof(actuate_params_t), len);
  #endif

  return len;
}

int construct_reboot(unsigned char* buf, int len, int *num_elements) {
    attr_t *attr;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_REBOOT);
    attr->length = hxs(0);

    len = sizeof(attr_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + reboot %u = length %d\n",
            sizeof(attr_t), 0, len);
#endif
    return len;
}

int construct_logical(unsigned char* buf, int len,int *num_elements,
                      uint16_t result, uint16_t tag, uint8_t optype, 
                      uint8_t argtype, uint16_t arg1) {
    attr_t *attr;
    logical_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_LOGICAL);
    attr->length = hxs(sizeof(logical_params_t));
    n = (logical_params_t *)(attr->value);
    n->result = hxs(result);
    n->attr = hxs(tag);
    n->optype = optype;
    n->argtype = argtype;
    n->arg = hxs(arg1);

    len = sizeof(attr_t) + sizeof(logical_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + logical %u = length %d\n",
            sizeof(attr_t), sizeof(logical_params_t), len);
#endif
    return len;
}

int construct_bit(unsigned char* buf, int len, int *num_elements,
                  uint16_t result, uint16_t tag, uint8_t optype, 
                  uint8_t argtype, uint16_t arg1) {
    attr_t *attr;
    bit_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_BIT);
    attr->length = hxs(sizeof(bit_params_t));
    n = (bit_params_t *)(attr->value);
    n->result = hxs(result);
    n->attr = hxs(tag);
    n->optype = optype;
    n->argtype = argtype;
    n->arg = hxs(arg1);

    len = sizeof(attr_t) + sizeof(bit_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + bit %u = length %d\n",
            sizeof(attr_t), sizeof(bit_params_t), len);
#endif
    return len;
}

int construct_arith(unsigned char* buf, int len, int *num_elements,
                    uint16_t result, uint16_t tag, uint8_t optype, 
                    uint8_t argtype, uint16_t arg) {
    attr_t *attr;
    arith_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_ARITH);
    attr->length = hxs(sizeof(arith_params_t));
    n = (arith_params_t *)(attr->value);
    n->result = hxs(result);
    n->attr = hxs(tag);
    n->optype = optype;
    n->argtype = argtype;
    n->arg = hxs(arg);

    len = sizeof(attr_t) + sizeof(arith_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + arith %u = length %d\n",
            sizeof(attr_t), sizeof(arith_params_t), len);
#endif
    return len;
}

int construct_comparison(unsigned char* buf, int len, int *num_elements,
                         uint16_t result, uint16_t tag, uint8_t optype, 
                         uint8_t argtype, uint16_t arg) {
    attr_t *attr;
    comparison_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_COMPARISON);
    attr->length = hxs(sizeof(comparison_params_t));
    n = (comparison_params_t *)(attr->value);
    n->result = hxs(result);
    n->attr = hxs(tag);
    n->optype = optype;
    n->argtype = argtype;
    n->arg = hxs(arg);

    len = sizeof(attr_t) + sizeof(comparison_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + comparison %u = length %d\n",
            sizeof(attr_t), sizeof(comparison_params_t), len);
#endif
    return len;
}

int construct_stats(unsigned char* buf, int len, int *num_elements,
                    uint16_t result, uint16_t tag, uint16_t optype) {
    attr_t *attr;
    stats_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_STATS);
    attr->length = hxs(sizeof(stats_params_t));
    n = (stats_params_t *)(attr->value);
    n->result = hxs(result);
    n->attr = hxs(tag);
    n->optype = hxs(optype);

    len = sizeof(attr_t) + sizeof(stats_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + stats %u = length %d\n",
            sizeof(attr_t), sizeof(stats_params_t), len);
#endif
    return len;
}

int construct_storage(unsigned char* buf, int len, int *num_elements, 
                      uint16_t tagIn, uint16_t tagOut, uint8_t store) {
    attr_t *attr;
    storage_params_t *p;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_STORAGE);
    attr->length = hxs(sizeof(storage_params_t));
    p = (storage_params_t *)(attr->value);
    p->tagIn = hxs(tagIn);
    p->tagOut = hxs(tagOut);
    p->store = store;
    p->pad = 0;

    len = sizeof(attr_t) + sizeof(storage_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + storage %u = length %d\n",
            sizeof(attr_t), sizeof(storage_params_t), len);
#endif
    return len;
}

int construct_pack(unsigned char* buf, int len, int *num_elements,
                   uint16_t nAttr, uint16_t size, uint8_t block) {
    attr_t *attr;
    pack_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_PACK);
    attr->length = hxs(sizeof(pack_params_t));
    n = (pack_params_t *)(attr->value);
    n->attr = hxs(nAttr);
    n->size = hxs(size);
    n->block = block;

    len = sizeof(attr_t) + sizeof(pack_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + pack %u = length %d\n",
            sizeof(attr_t), sizeof(pack_params_t), len);
#endif
    return len;
}

int construct_attribute(unsigned char* buf, int len, int *num_elements,
                    uint16_t result, uint16_t nAttr, uint8_t optype) {
    attr_t *attr;
    attribute_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_ATTRIBUTE);
    attr->length = hxs(sizeof(attribute_params_t));
    n = (attribute_params_t *)(attr->value);
    n->result = hxs(result);
    n->attr = hxs(nAttr);
    n->optype = optype;

    len = sizeof(attr_t) + sizeof(attribute_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + attribute %u = length %d\n",
            sizeof(attr_t), sizeof(attribute_params_t), len);
#endif
    return len;
}


/******** send related tasklet constructors ********/

int construct_sendpkt(unsigned char* buf, int len, int *num_elements, uint8_t e2e_ack) {
    attr_t *attr;
    sendPkt_params_t *sp;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_SENDPKT);
    attr->length = hxs(sizeof(sendPkt_params_t));
    sp = (sendPkt_params_t *)(attr->value);
    sp->e2e_ack = e2e_ack;
    sp->unused = 0;

    len = sizeof(attr_t) + sizeof(sendPkt_params_t); 
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + sendpkt %u = length %d\n",
            sizeof(attr_t), sizeof(sendPkt_params_t), len);
#endif
    return len;
}

int construct_sendstr(unsigned char* buf, int len, int *num_elements) {
    attr_t *attr;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_SENDSTR);
    attr->length = hxs(0);

    len = sizeof(attr_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + sendstr %u = length %d\n",
            sizeof(attr_t), 0, len);
#endif
    return len;
}

int construct_sendrcrt(unsigned char* buf, int len, int *num_elements, uint16_t irate) {
    attr_t *attr;
    sendRcrt_params_t *sp;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_SENDRCRT);
    attr->length = hxs(sizeof(sendRcrt_params_t));
    sp = (sendRcrt_params_t *)(attr->value);
    sp->irate = irate;

    len = sizeof(attr_t) + sizeof(sendRcrt_params_t); 
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + sendrcrt %u = length %d\n",
            sizeof(attr_t), sizeof(sendRcrt_params_t), len);
#endif
    return len;
}

int construct_send(unsigned char* buf, int len, int *num_elements, uint16_t sendtype) {
    if (sendtype == 2)
        return construct_sendstr(buf, len, num_elements);
    else if (sendtype == 1)
        return construct_sendpkt(buf, len, num_elements, 1);
    else if (sendtype == 3)
        return construct_sendrcrt(buf, len, num_elements, 0);
    else
        return construct_sendpkt(buf, len, num_elements, 0);
}


/*** Delete (task/active_task/attribute) tasklet constructors ***/

int construct_deleteAttributeIf(unsigned char *buf, int len, int *num_elements,
                                uint16_t arg, uint8_t argtype, uint16_t tag, uint8_t deleteAll) {
    attr_t *attr;
    deleteAttributeIf_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_DELETEATTRIBUTEIF);
    attr->length = hxs(sizeof(deleteAttributeIf_params_t));
    n = (deleteAttributeIf_params_t *)(attr->value);
    n->arg = hxs(arg);
    n->tag = hxs(tag);
    n->argtype = argtype;
    n->deleteAll = deleteAll;
    len = sizeof(attr_t) + sizeof(deleteAttributeIf_params_t); 
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + deleteAttributeIf %u = length %d\n",
            sizeof(attr_t), sizeof(deleteAttributeIf_params_t), len);
#endif
    return len;
}


int construct_deleteActiveTaskIf(unsigned char *buf, int len, int *num_elements,
                                 uint16_t arg, uint8_t argtype) {
    attr_t *attr;
    deleteActiveTaskIf_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_DELETEACTIVETASKIF);
    attr->length = hxs(sizeof(deleteActiveTaskIf_params_t));
    n = (deleteActiveTaskIf_params_t *)(attr->value);
    n->arg = hxs(arg);
    n->argtype = argtype;
    n->pad = 0;
    len = sizeof(attr_t) + sizeof(deleteActiveTaskIf_params_t); 
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + deleteActiveTaskIf %u = length %d\n",
            sizeof(attr_t), sizeof(deleteActiveTaskIf_params_t), len);
#endif
    return len;
}

int construct_deleteTaskIf(unsigned char *buf, int len, int *num_elements,
                           uint16_t arg, uint8_t argtype) {
    attr_t *attr;
    deleteTaskIf_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_DELETETASKIF);
    attr->length = hxs(sizeof(deleteTaskIf_params_t));
    n = (deleteTaskIf_params_t *)(attr->value);
    n->arg = hxs(arg);
    n->argtype = argtype;
    n->pad = 0;
    len = sizeof(attr_t) + sizeof(deleteTaskIf_params_t); 
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + deleteTaskIf %u = length %d\n",
            sizeof(attr_t), sizeof(deleteTaskIf_params_t), len);
#endif
    return len;
}

int construct_voltage(unsigned char* buf, int len, int *num_elements, uint16_t out0) {
    attr_t *attr;
    voltage_params_t *s;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_VOLTAGE);
    attr->length = hxs(sizeof(voltage_params_t));
    s = (voltage_params_t *)(attr->value);
    s->outputName = hxs(out0);       // tag

    len = sizeof(attr_t) + sizeof(voltage_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + voltage %u  = length %d\n",
            sizeof(attr_t),  sizeof(voltage_params_t), len);
#endif
    return len;
}


/******** sampling related tasklet constructors ********/

int construct_simple_sample(unsigned char* buf, int len, int *num_elements,
                            uint8_t ch0, uint16_t out0) {
    attr_t *attr;
    simpleSample_params_t *sample;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_SIMPLESAMPLE);
    attr->length = hxs(sizeof(simpleSample_params_t));
    sample = (simpleSample_params_t *)(attr->value);
    sample->channel = ch0;
    sample->outputName = hxs(out0);

    len = sizeof(attr_t) + sizeof(simpleSample_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + sample %u  = length %d\n",
            sizeof(attr_t), paramsLength, len);
#endif
    return len;
}

int construct_sample(unsigned char* buf, int len, int *num_elements, 
                     uint32_t interval, uint16_t count, uint8_t repeat, 
                     uint8_t ch0, uint16_t out0) {
    attr_t *attr;
    sample_params_t *s;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_SAMPLE);
    attr->length = hxs(sizeof(sample_params_t));
    s = (sample_params_t *)(attr->value);
    s->interval = hxl(interval);     // ms, between samples
    s->count = hxs(count);           // # sample in an attr
    s->channel = ch0;           // ADC channel
    s->outputName = hxs(out0);       // tag
    s->repeat = repeat;         // repeat

    len = sizeof(attr_t) + sizeof(sample_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + sample %u  = length %d\n",
            sizeof(attr_t),  sizeof(sample_params_t), len);
#endif
    return len;
}

/******** constructors for telosb-dependant tasklets ********/
/*
int construct_fastsample(unsigned char* buf, int len, int *num_elements, int rate, int count, int numChannels,
        int ch0, int out0,
        int ch1, int out1,
        int ch2, int out2){
    attr_t *attr;
    fastSample_params_t *sample;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_FASTSAMPLE);
    attr->length = hxs(sizeof(fastSample_params_t));
    sample = (fastSample_params_t *)(attr->value);
    sample->rate =(sample_rate_t) rate;
    sample->count = count;
    sample->numChannels = numChannels;
    sample->channel[0] = ch0;
    sample->outputName[0]  = out0;
    sample->channel[1] = ch1;
    sample->outputName[1]  = out1;
    sample->channel[2] = ch2;
    sample->outputName[2]  = out2;

    len = sizeof(attr_t) + sizeof(fastSample_params_t); 
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + fastSample %u = length %d\n",
            sizeof(attr_t), sizeof(fastSample_params_t), len);
#endif
    return len;
}
*/
int construct_user_button(unsigned char* buf, int len, int *num_elements, int repeat) {
    attr_t *attr;
    userButton_params_t *userButton;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_USERBUTTON);
    attr->length = hxs(sizeof(userButton_params_t));
    userButton = (userButton_params_t *)(attr->value);
    userButton->repeat = (uint8_t)repeat;
    userButton->pad = 0x00;

    len = sizeof(attr_t) + sizeof(userButton_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + userButton %u = length %d\n",
            sizeof(attr_t), sizeof(userButton_params_t), len);
#endif
    return len;
}


/******** Below are constructors for tasklets under devel. ********/

int construct_memoryop(unsigned char* buf, int len, int *num_elements, int addr, int value, int op, int type) {
    attr_t *attr;
    memoryop_params_t *mem;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_MEMORYOP);
    attr->length = hxs(sizeof(memoryop_params_t));
    mem = (memoryop_params_t *)(attr->value);
    mem->addr = hxs(addr);
    mem->value = hxs(value);
    mem->op = op;
    mem->type = type;

    len = sizeof(attr_t) + sizeof(memoryop_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + mem %u = length %d\n",
            sizeof(attr_t), sizeof(memoryop_params_t), len);
#endif
    return len;
}

int construct_rle(unsigned char* buf, int len, int *num_elements,
                    uint16_t result, uint16_t arg, uint16_t thresh) {
    attr_t *attr;
    rle_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_RLE);
    attr->length = hxs(sizeof(rle_params_t));
    n = (rle_params_t *)(attr->value);
    n->result = hxs(result);
    n->attr = hxs(arg);
    n->thresh = hxs(thresh);

    len = sizeof(attr_t) + sizeof(rle_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + rle %u = length %d\n",
            sizeof(attr_t), sizeof(rle_params_t), len);
#endif
    return len;
}

int construct_packbits(unsigned char* buf, int len, int *num_elements,
                    uint16_t result, uint16_t arg, uint16_t thresh) {
    attr_t *attr;
    rle_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_PACKBITS);
    attr->length = hxs(sizeof(rle_params_t));
    n = (rle_params_t *)(attr->value);
    n->result = hxs(result);
    n->attr = hxs(arg);
    n->thresh = hxs(thresh);

    len = sizeof(attr_t) + sizeof(rle_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + packbits %u = length %d\n",
            sizeof(attr_t), sizeof(rle_params_t), len);
#endif
    return len;
}

int construct_vector(unsigned char* buf, int len, int *num_elements,
                    uint16_t result, uint16_t length, uint16_t pattern) {
    attr_t *attr;
    vector_params_t *n;

    attr = (attr_t *)(buf + len);
    attr->type = hxs(ELEMENT_VECTOR);
    attr->length = hxs(sizeof(vector_params_t));
    n = (vector_params_t *)(attr->value);
    n->attr = hxs(result);
    n->length = hxs(length);
    n->pattern = hxs(pattern);

    len = sizeof(attr_t) + sizeof(vector_params_t);
    (*num_elements)++;

#if defined(BUILDING_PC_SIDE) && defined(DEBUG_ELEMENT_CONSTRUCT)
    fprintf(stderr, "  attr %u + vector %u = length %d\n",
            sizeof(attr_t), sizeof(vector_params_t), len);
#endif
    return len;
}

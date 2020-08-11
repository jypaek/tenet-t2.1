/**
 * Tenet Tasklet data structures
 *
 * Each tasklet has a structure that defines the list of
 * parameters required to instantiate and run that tasklet. This
 * file also includes other constants and definitions used by
 * various tasklets.
 * 
 * @author Ben Greenstein
 **/


#ifndef _TENET_TASK_H_
#define _TENET_TASK_H_

#if defined(BUILDING_PC_SIDE)
#include <sys/types.h>
#include <stdint.h>
#include "nx.h"
#ifndef __cplusplus
#ifndef bool
typedef unsigned char bool;
#endif
#endif
#endif

enum {
    UNKNOWN_TYPE = 0,
    NULL_TYPE = 0, // TODO: make this a reserved type other than 0
    UNKNOWN_ID = 0,
    INSTALL_TASK = 1,
    TYPE_LEN_SZ = 4,
};
//#define TYPE_LEN_SZ (offsetof(attr_t,value))

typedef enum {
    LIST_REMOVE,
    LIST_BREAK,
    LIST_CONT
} list_action_t;

typedef enum {
    SCHED_STOP,
    SCHED_NEXT,
    SCHED_TERMINATE, /* terminate that active task */
    SCHED_TKILL,     /* terminate/kill the task from which that active task belong to */
} sched_action_t;

typedef list_action_t (*operator_fn_t)(void *item, void *meta);

/* all tag_t's should be unique */
typedef nx_uint16_t nxtag_t;
typedef uint16_t tag_t;

typedef nx_struct {
    nxtag_t type;
    nx_uint16_t length;
    nx_uint8_t value[0];
} attr_t;

typedef struct element_s element_t;
typedef struct active_task_s active_task_t;

typedef struct task_s {
    uint32_t id;
    uint8_t num_elements;
    uint8_t num_atasks;
    uint8_t block_cloning;
    uint8_t sendbusy;
    element_t **elements;
} task_t;

/* data_attr_t is an element in the 'data_t', linked-list of attributes */
typedef struct {
    nxtag_t type;
    nx_uint16_t length;
    void *value;
} data_attr_t;

/* 'data_t' is a linked-list of attributes associated with an active task */
typedef struct data_s {
    data_attr_t attr;
    uint16_t flags;
    struct data_s *next;
} data_t;

struct active_task_s {
    uint8_t element_index;
    uint8_t pad;
    data_t *data;
    task_t *t;
};

typedef sched_action_t (*run_t)(active_task_t *active_task, element_t *e);
typedef void (*suicide_t)(task_t *t, element_t *e);

struct element_s {
    uint16_t id;
    run_t run;
    suicide_t suicide;
};

typedef struct list_item_s {
  void *data;
  struct list_item_s *next;
} list_item_t;

typedef struct list_s {
  struct list_item_s *head;
  struct list_item_s *tail;
} list_t;


typedef nx_struct link_hdr_s {
  nx_uint16_t tid;
  nx_uint16_t src;
  nx_uint8_t data[0];
} __attribute__((packed)) link_hdr_t;

typedef enum {
  UNKNOWN = 0,
  TASK_INSTALL = 1,
  MODIFY = 2,
  TASK_DELETE = 3,
  RERUN = 4,
  DATA = 5  //originated from mote
} tenet_msg_type_t;

typedef nx_struct task_msg_s {
    nx_uint8_t type; // tenet_msg_type_t
    nx_uint8_t numElements;
    nx_uint8_t data[0];
} __attribute__((packed)) task_msg_t;


typedef enum {
    ERROR_ATTRIBUTE = 0x01
} reserved_attr_type_t;


typedef enum {
    ARGTYPE_CONSTANT = 0,
    ARGTYPE_ATTRIBUTE = 1
} argtype_t;

typedef enum {
    GET_ROUTING_PARENT = 1,
    GET_GLOBAL_TIME = 2,
    GET_LOCAL_TIME = 3,
    GET_MEMORY_STATS = 4, 
    GET_NUM_TASKS = 5,
    GET_NUM_ACTIVE_TASKS = 6,
    GET_ROUTING_CHILDREN = 7,
    GET_NEIGHBORS = 8,
    GET_LEDS = 9,
    GET_RF_POWER = 10,
    GET_RF_CHANNEL = 11,
    GET_IS_TIMESYNC = 12,
    GET_TOS_LOCAL_ADDRESS = 13,
    GET_GLOBAL_TIME_MS = 14,
    GET_LOCAL_TIME_MS = 15,
    GET_ROUTING_PARENT_LINKQUALITY = 16,
    GET_PLATFORM = 17,
    GET_CLOCK_FREQ = 18,
    GET_ROUTING_MASTER = 19,
    GET_ROUTING_HOPCOUNT = 20,
    GET_ROUTING_PARENT_RSSI = 21,
} get_value_t;

typedef enum {
    TELOSB   = 1,
    MICAZ    = 2,
    IMOTE2   = 3,
    MICA2    = 4,
    MICA2DOT = 5,
} platform_value_t;

typedef enum {
/* Arith Operators */ 
    A_ADD  = 1,
    A_SUB  = 2,
    A_MULT = 3,
    A_DIV  = 4,
    A_DIFF = 5,
    A_MOD  = 6,
    A_POW  = 7,
/* Comparison Operators */ 
    LT  = 11,
    GT  = 12,
    EQ  = 13,
    LEQ = 14,
    GEQ = 15,
    NEQ = 16,
/* Counting Comparison Operators */ 
//All COUNT_* need to have bigger number than others due to Comparison element implementation
    COUNT_LT  = 21,
    COUNT_GT  = 22,
    COUNT_EQ  = 23,
    COUNT_LEQ = 24,
    COUNT_GEQ = 25,
    COUNT_NEQ = 26,
} arith_comparison_op_t;
    
typedef enum {
    AND  = 1,
    OR   = 2,
    NOT  = 3,
    XOR  = 4,
    NAND = 5,
    NOR  = 6,
    SHL  = 7, //shift left <<
    SHR  = 8, //shift right >>
} bit_op_t;

typedef enum {
    LAND = AND,
    LOR  = OR,
    LNOT = NOT,
} logical_op_t;

typedef enum {
    SUMM = 1,   // name conflict... change later
    MIN = 2,
    MAX = 3,
    AVG = 4,
    STD = 5,
    CNT = 6,
    MEANDEV = 7,
} stat_op_t;

typedef enum {
    EXIST     = 1,
    NOT_EXIST = 2,
    LENGTH    = 3,
} attribute_op_t;

typedef enum {
    ERR_INSTALL_FAILURE = 1,
    ERR_CONSTRUCT_FAILURE,
    ERR_INVALID_TASK_DESCRIPTION,
    ERR_INVALID_TASK_PARAMETER,
    ERR_MALLOC_FAILURE,
    ERR_INVALID_ATTRIBUTE,
    ERR_INVALID_OPERATION,
    ERR_NULL_TASK,
    ERR_NULL_ACTIVE_TASK,
    ERR_RESOURCE_BUSY,
    ERR_RUNTIME_FAILURE,
    ERR_NOT_SUPPORTED,
    ERR_MALFORMED_ACTIVE_TASK,
    ERR_DATA_REMOVE,
    ERR_NO_ROUTE,
    ERR_QUEUE_OVERFLOW,
    ERR_SENSOR_ERROR,
    ERR_TIMESYNC_FAILURE,
} error_code_t;

typedef enum {
    ACTUATE_LEDS = 0,
    ACTUATE_RADIO = 1,
    ACTUATE_SOUNDER = 2,
    ACTUATE_LEDS_TOGGLE = 3,
    ACTUATE_ROUTE_RESET = 11,
    ACTUATE_ROUTE_HOLD = 12,
} actuate_channel_t;

typedef nx_struct {
    nx_uint16_t err_code;   /* error code.     (eg. malloc fail, description error) */
    nx_uint16_t err_loc;    /* error location. (eg. element_id) */
    nx_uint16_t err_loc2;   /* error location-2. (eg. element index) */
} error_report_t;


//----------------- UserButton ----------------------

typedef nx_struct userButton_params_s {
    nx_uint8_t repeat;
    nx_uint8_t pad;
} __attribute__((packed)) userButton_params_t;

//----------------- SendPkt --------------------------

typedef nx_struct sendPkt_params_s {
    // possible params could be...
    //  - number of e2e retx, or timeout, etc
    nx_uint8_t e2e_ack;
    nx_uint8_t unused;
} __attribute__((packed)) sendPkt_params_t;

//----------------- SendSTR --------------------------
// no params

//----------------- SendRcrt --------------------------

typedef struct sendRcrt_params_s {
    uint16_t irate;     // inverse of desired pkt rate (interval in millisec)
} __attribute__((packed)) sendRcrt_params_t;

//----------------- Issue -------------------------

typedef nx_struct issue_params_s {
    nx_uint32_t starttime;
    nx_uint32_t period;
    nx_uint8_t abs;
    nx_uint8_t pad;
} __attribute__((packed)) issue_params_t;

//---------------- Actuate ----------------------

typedef nx_struct actuate_params_s {
    nx_uint8_t chan;
    nx_uint8_t argtype;
    nx_uint16_t arg1;
}__attribute__((packed)) actuate_params_t;

//--------------- Logical ---------------------------

typedef nx_struct logical_params_s {
    nxtag_t result;
    nxtag_t attr;
    nx_uint8_t optype;
    nx_uint8_t argtype;
    nxtag_t arg;
}__attribute__((packed)) logical_params_t;

//--------------- Bit ---------------------------

typedef nx_struct bit_params_s {
    nxtag_t result;
    nxtag_t attr;
    nx_uint8_t optype;
    nx_uint8_t argtype;
    nxtag_t arg;
}__attribute__((packed)) bit_params_t;

//----------------- Arithmetic --------------------

typedef nx_struct arith_params_s {
    nxtag_t result;
    nxtag_t attr;
    nx_uint8_t optype;
    nx_uint8_t argtype;
    nxtag_t arg;
} __attribute__((packed)) arith_params_t; 

//----------------- Memory ------------------------

typedef struct memoryop_params_s {
    uint16_t addr; // memory address
    uint8_t value; // length if op=read, data to write if op=write(1,2)
    uint8_t op; // 0=read/ 1=write 1-byte var, 2=write 2-byte var
    tag_t type; // tag for return data
} __attribute__((packed)) memoryop_params_t;


//----------------- Reboot -----------------------
// no params

//----------------- Count ------------------------

typedef nx_struct count_params_s {
    nx_uint16_t count;
    nx_int16_t rate;
    nxtag_t type;
} __attribute__((packed)) count_params_t;

//----------------- Get --------------------

typedef nx_struct get_params_s {
    nxtag_t type;
    nx_uint16_t value;
} __attribute__((packed)) get_params_t;

//----------------- Comparison --------------------

typedef nx_struct comparison_params_s {
    nxtag_t result;
    nxtag_t attr;
    nx_uint8_t optype;
    nx_uint8_t argtype;
    nxtag_t arg;
} __attribute__((packed)) comparison_params_t; 

//----------------- Stats --------------------

typedef nx_struct stats_params_s {
    nxtag_t result;
    nxtag_t attr;
    nx_uint16_t optype;
} __attribute__((packed)) stats_params_t;

//----------------- Pack --------------------

typedef nx_struct pack_params_s {
    nxtag_t attr;
    nx_uint16_t size;
    nx_uint8_t block;
    nx_uint8_t pad;
} __attribute__((packed)) pack_params_t;

//----------------- Attribute --------------------

typedef nx_struct attribute_params_s {
    nxtag_t result;
    nxtag_t attr;
    nx_uint8_t optype;
    nx_uint8_t pad;
} __attribute__((packed)) attribute_params_t;

//---------------------- Sample -------------------------

typedef enum {
    // lets make this greater than 20.
    HUMIDITY = 20,
    TEMPERATURE = 21,
    TSRSENSOR = 22,
    PARSENSOR = 23,
    ITEMP = 24,
    VOLTAGE = 25,
    PHOTO = 26,
    ACCELX = 27,
    ACCELY = 28,
} sensors_t;

typedef nx_struct sample_params_s {
    nx_uint32_t interval;      // sampling interval in millisec
    nx_uint16_t count;
    nxtag_t outputName;
    nx_uint8_t channel;
    nx_uint8_t repeat;
} __attribute__((packed)) sample_params_t;

//----------------- SimpleSample ---------------------

typedef nx_struct simpleSample_params_s {
    nxtag_t outputName;
    nx_uint8_t channel;
    nx_uint8_t pad;
} __attribute__((packed)) simpleSample_params_t;

//---------------------- Voltage -------------------------

typedef nx_struct voltage_params_s {
    nxtag_t outputName;
} __attribute__((packed)) voltage_params_t;

//----------------- MemoryStats -------------------------

typedef nx_struct {
    nx_uint16_t bytesAllocated;
    nx_uint16_t ptrsAllocated;
    nx_uint16_t maxBytesAllocated;
    nx_uint16_t maxPtrsAllocated;
} __attribute__((packed)) memory_stats_t;

//------------- Storage (Store/Restore) --------------

typedef nx_struct storage_params_s {
    nxtag_t tagIn;
    nxtag_t tagOut;
    nx_uint8_t store; /* 1: store, 0: restore */
    nx_uint8_t pad;
} __attribute__((packed)) storage_params_t;


//----------------- DeleteAttributeIf --------------------

typedef nx_struct deleteAttributeIf_params_s {
    nxtag_t arg;
    nxtag_t tag;
    nx_uint8_t argtype;
    nx_uint8_t deleteAll;
} __attribute__((packed)) deleteAttributeIf_params_t;


//----------------- DeleteActiveTaskIf --------------------

typedef nx_struct deleteActiveTaskIf_params_s {
    nxtag_t arg;
    nx_uint8_t argtype;
    nx_uint8_t pad;
} __attribute__((packed)) deleteActiveTaskIf_params_t;


//----------------- DeleteTaskIf --------------------

typedef nx_struct deleteTaskIf_params_s {
    nxtag_t arg;
    nx_uint8_t argtype;
    nx_uint8_t pad;
} __attribute__((packed)) deleteTaskIf_params_t;


//----------------- Image (Cyclops) -------------------------

typedef struct image_params_s {
    nxtag_t outputName;
    nx_uint8_t nModule;        // Neuron module (snapN, activeN, etc)
    nx_uint8_t length;
    nx_uint8_t slaveQuery[0];
} __attribute__((packed)) image_params_t;


//--------------------- FIR low pass filter -----------------------

typedef nx_struct firLpFilter_params_s {
    nxtag_t type_in;
    nxtag_t type_out;
} __attribute__((packed)) firLpFilter_params_t;


//--------------------- Run Length Encoding -----------------------

typedef nx_struct rle_params_s {
    nxtag_t result;
    nxtag_t attr;
    nx_uint16_t thresh;
} __attribute__((packed)) rle_params_t;


//----------------- Vector ------------------------

typedef nx_struct vector_params_s {
    nx_uint16_t length;
    nx_uint16_t pattern;
    nxtag_t attr;
} __attribute__((packed)) vector_params_t;



#endif //_TENET_TASK_H_


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
 * Collection layer header file.
 *
 * Used by both the mote and the master routing layer and transport layer.
 *
 * Embedded Networks Laboratory, University of Southern California
 * @date Nov/21/2007
 * @author Jeongyeup Paek
 * @author Omprakash Gnawali
 **/


#ifndef _COLLECTION_LAYER_H_
#define _COLLECTION_LAYER_H_

#ifdef BUILDING_PC_SIDE
#include <sys/types.h>
#include <stdint.h>
#include "nx.h"

// HACK: Re-define stuff for master (no need for mote side)

// only used by the master router
// !!! the same enum is defined in tenet-t2/mote/lib/net/lqi/MultiHopLqi.h
enum {
    AM_COL_BEACON = 250,
    AM_COL_DATA = 251,
};

// only used by the master router
// !!! the same structure is defined in tenet-t2/mote/lib/net/lqi/MultiHopLqi.h

// LQI routing data types
#define AM_LQI_BEACON_MSG 250
typedef struct lqi_beacon_msg {
  uint16_t originaddr;
  int16_t seqno;
  int16_t originseqno;
  uint16_t parent;
  uint16_t cost;
  uint16_t hopcount;
} __attribute__((packed)) lqi_beacon_msg_t;

typedef nx_struct lqi_data_msg {
  nx_uint16_t originaddr;
  nx_uint16_t dstaddr;
  nx_uint16_t prevhop;
  nx_int16_t seqno;
  nx_int16_t originseqno;
  //nx_uint16_t hopcount;
  nx_uint16_t ttl;
  //nx_collection_id_t collectId;
  nx_uint8_t protocol;
  nx_uint8_t pad;
} __attribute__ ((packed)) lqi_header_t;


/////////////////////////////////////////////////////////

#else   // NOT(BUILDING_PC_SIDE)

#include "MultiHopLqi.h"

#endif  // BUILDING_PC_SIDE

// both mote & master

typedef lqi_header_t collection_header_t;

enum {
  COL_RT_DATA_LENGTH = TOSH_DATA_LENGTH - sizeof(collection_header_t),
};

////////////////////////////////////////////////////////

#ifdef BUILDING_PC_SIDE
/**
 * read_collection_msg: takes the 'packet', and decapsulates the collection packet.
 * 'packet' should be in TOS_Msg format.
 * assumes that a 'collection msg' is encapsulated in 'packet'.
 * @return 'payload' part of the collection msg. 
 **/
void *read_collection_msg(int len, uint8_t *packet, int *paylen,
                       uint16_t *src, uint16_t *dst,
                       uint16_t *prevhop, uint8_t *protocol, uint8_t *ttl);

/** 
 * write_collection_msg: encapsulate 'payload' in a collection packet and send to 'addr'
 *
 **/
void write_collection_msg(uint8_t *payload, int len, uint8_t protocol, uint16_t addr, uint8_t ttl);
#endif

#endif // _COLLECTION_LAYER_H_


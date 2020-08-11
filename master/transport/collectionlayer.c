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
 * @date Nov/21/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/

#include "transportmain.h"
#include "tosmsg.h"
#include "collectionlayer.h"
#include "transport.h"
#include "sfsource.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

extern int packets_written;

/**
 * Given 'packet' and 'len', where 'packet' is in collection layer packet format
 * encapsulated in tinyos-link-layer packet format,
 * (has TOS_Msg header, and also RoutingLayer header)
 * this function removes both headers and extracts the inner payload,
 * and returns the payload in [rtmsg, *paylen] in addition to 
 * all collection layer header information such as src/dst addresses.
 **/
void *read_collection_msg(int len, uint8_t *packet, int *paylen,
                       uint16_t *originaddr, uint16_t *dstaddr,
                       uint16_t *prevhop, uint8_t *protocol, uint8_t *ttl) {
    TOS_Msg *tosmsg = (TOS_Msg *) packet;
    collection_header_t *rt_header;
    uint8_t *rtmsg;
    uint16_t ttl16;

    if (!packet)
        return NULL;

    if (tosmsg->type != AM_COL_DATA) {
      fprintf(stderr, "[read_collection_msg] Non LQI msg received\n");
      return NULL;
    }

    if ((len != (offsetof(TOS_Msg, data) + tosmsg->length)) 
            || (tosmsg->length < sizeof(collection_header_t))
            || (len > 128)
            || (len < sizeof(collection_header_t))) {
        fprintf(stderr, "[read_collection_msg] Error in packet lengths:");
        fprintf(stderr, " len=%d, msg->length=%d\n", len, tosmsg->length);
        fdump_packet(stderr, packet, len);
        return NULL;
    }

    rt_header = (collection_header_t *) tosmsg->data;
    *originaddr = ntohs(rt_header->originaddr);
    *dstaddr = ntohs(rt_header->dstaddr);
    *prevhop = ntohs(rt_header->prevhop);
    *protocol = rt_header->protocol;
    ttl16 = ntohs(rt_header->ttl);
    *ttl = 0xFF & ttl16;
    
    *paylen = len - sizeof(collection_header_t) - offsetof(TOS_Msg, data);

    rtmsg = (uint8_t *)&tosmsg->data[sizeof(collection_header_t)];


    return rtmsg;
}


/**
 * Encapsulate 'msg' in collection layer packet format and 
 * send it out to 'send_TOS_Msg' function which will again
 * encapsulate the packet in TOS_Msg format and send it 
 * down to the collection layer.
 **/
void write_collection_msg(uint8_t *msg, int len, uint8_t protocol, uint16_t addr, uint8_t ttl) {
    uint8_t *packet;
    collection_header_t *header;
    uint8_t type = AM_COL_DATA;
    int rt_fd = get_router_fd();

    if (len <= 0)
        return;
    packet = malloc(len + sizeof(collection_header_t));
    header = (collection_header_t *) packet;
    memcpy(&packet[sizeof(collection_header_t)], msg, len);
    header->originaddr = htons((uint16_t) TOS_LOCAL_ADDRESS());
    header->dstaddr = htons((uint16_t) addr);
    header->prevhop = htons((uint16_t) TOS_LOCAL_ADDRESS());
    header->ttl = htons(ttl);
    header->protocol = protocol | PROTOCOL_DOWNLINK_BIT;
    len += sizeof(collection_header_t);

    packets_written++;
    send_TOS_Msg(rt_fd, packet, len, type, addr, TOS_DEFAULT_GROUP);
    free((void *)packet);
    return;
}


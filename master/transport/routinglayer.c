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
 *
 * Embedded Networks Laboratory, University of Southern California
 * @date Nov/21/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/

#include "transportmain.h"
#include "tosmsg.h"
#include "routinglayer.h"
#include "transport.h"
#include "sfsource.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

/**
 *
 **/
void *read_routing_msg(int len, uint8_t *packet, int *paylen,
                       uint16_t *srcAddr, uint16_t *dstAddr,
                       uint16_t *prevhop, uint8_t *protocol, uint8_t *ttl) {
    TOS_Msg *tosmsg = (TOS_Msg *) packet;

    if (!packet) return NULL;

    if (tosmsg->type == AM_COL_DATA) {
        return read_collection_msg(len, packet, paylen, srcAddr, dstAddr, prevhop, protocol, ttl);
    }
    fprintf(stderr, "[read_routing_msg] Non-routing msg received\n");
    return NULL;
}


/**
 *
 **/
void write_routing_msg(uint8_t *msg, int len, uint8_t protocol, uint16_t addr, uint8_t ttl) {

    write_collection_msg(msg, len, protocol, addr, ttl);
    return;
}


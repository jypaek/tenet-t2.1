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
 *
 * @author Jeongyeup Paek
 * Embedded Networks Laboratory, University of Southern California
 * @modified 2/5/2007
 **/

// Omprakash Gnawali
// yanked this stuff from transport
// also copied code from sflisten; connect to the sf directly

// Jongkeun Na
// to use beacon header types in collectionlayer.h.

#include <stdlib.h>
#include <unistd.h>
#include "sfsource.h"
#include "tosmsg.h"
#include "collectionlayer.h"

uint16_t seq = 0;
int fd;
uint16_t  TOS_LOCAL_ADDRESS;

unsigned char packet[200];

void send_beacon() {
    uint8_t length = sizeof(lqi_beacon_msg_t);
    lqi_beacon_msg_t *bMsg = (lqi_beacon_msg_t *) &packet;

    bMsg->parent = htons(TOS_LOCAL_ADDRESS);
    bMsg->cost = 0;
    bMsg->originaddr = htons(TOS_LOCAL_ADDRESS);
    bMsg->hopcount = 0;
    bMsg->seqno = htons(seq++);

    send_TOS_Msg(fd, packet, length, AM_LQI_BEACON_MSG, TOS_BCAST_ADDR, TOS_DEFAULT_GROUP);
}


int main(int argc, char **argv)
{

    if (argc != 4)
    {
        fprintf(stderr, "Usage: %s <host> <port> <nodeid> - connect to the sf at host:port and send lqi beacons as a root with nodeid\n", argv[0]);
        exit(2);
    }
    TOS_LOCAL_ADDRESS = atoi(argv[3]);
    fd = open_sf_source(argv[1], atoi(argv[2]));
    if (fd < 0)
    {
        fprintf(stderr, "Couldn't open serial forwarder at %s:%s\n",
                argv[1], argv[2]);
        exit(1);
    }

    for (;;) {
        send_beacon();
        printf("node %d sent beacon seq %d\n", TOS_LOCAL_ADDRESS, seq);
        sleep(30);
    }
    return 1;
}

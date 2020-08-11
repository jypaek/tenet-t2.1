/*
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
*/

/**
 * RCRT_Logger
 * - RcrTransport Packet Logger
 * - This interface is 'RcrTransport' specific.
 * - Packet size and wrap-around boundary must match with rctransport.h
 *
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * @modified Feb/27/2009
 **/


#ifndef _RCRT_PKT_LOGGER_H
#define _RCRT_PKT_LOGGER_H

#include "rcrtransport.h"

enum {
#ifdef RCRT_2_CON
    RCRT_NUM_VOLS = 2,
    RCRT_NUM_REAL_VOLS = 4,
#else
    RCRT_NUM_VOLS = 1,
    RCRT_NUM_REAL_VOLS = 2,
#endif
};

#endif


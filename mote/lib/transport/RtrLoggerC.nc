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
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * Embedded Networks Laboratory, University of Southern California
 * @modified Feb/27/2009
 **/

#include "StorageVolumes.h"

configuration RtrLoggerC {
    provides {
        interface Init;
        interface TrPktLogger as PktLogger;
    }
}
implementation
{
    components RtrLoggerP as PktLoggerP;
    Init = PktLoggerP;
    PktLogger = PktLoggerP;

    components new BlockStorageC(VOLUME_RCRT_BLOCK_ID0) as Block_RCRT_BLOCK_ID0,
                new BlockStorageC(VOLUME_RCRT_BLOCK_ID1) as Block_RCRT_BLOCK_ID1;
    PktLoggerP.BlockWrite0 -> Block_RCRT_BLOCK_ID0;
    PktLoggerP.BlockWrite1 -> Block_RCRT_BLOCK_ID1;
    PktLoggerP.BlockRead0 -> Block_RCRT_BLOCK_ID0;
    PktLoggerP.BlockRead1 -> Block_RCRT_BLOCK_ID1;
    #ifdef RCRT_2_CON
    components new BlockStorageC(VOLUME_RCRT_BLOCK_ID2) as Block_RCRT_BLOCK_ID2,
                new BlockStorageC(VOLUME_RCRT_BLOCK_ID3) as Block_RCRT_BLOCK_ID3;
    PktLoggerP.BlockWrite2 -> Block_RCRT_BLOCK_ID2;
    PktLoggerP.BlockWrite3 -> Block_RCRT_BLOCK_ID3;
    PktLoggerP.BlockRead2 -> Block_RCRT_BLOCK_ID2;
    PktLoggerP.BlockRead3 -> Block_RCRT_BLOCK_ID3;
    #endif
}


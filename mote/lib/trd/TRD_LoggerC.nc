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
 * Configuration file for TRD packet logger.
 *
 * This file performs necessary platform-dependant wiring to provide
 * platform-independant interface to the TRD module.
 *
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * Embedded Networks Laboratory, University of Southern California
 * @modified Feb/27/2009
 **/

#include "StorageVolumes.h"
#include "TRD_Logger.h"

configuration TRD_LoggerC {
    provides {
        interface Init;
        interface TRD_Logger as Logger;
    }
}
implementation
{
#ifdef RAM_TRD
    components TRD_LoggerRAM as LoggerP;
#else
    components TRD_LoggerP as LoggerP;
#endif
    Init = LoggerP;
    Logger = LoggerP;

#ifdef RAM_TRD
    /* Nothing more to wire */
#else
    components new BlockStorageC(VOLUME_TRD_BLOCK_ID0) as Block_TRD_BLOCK_ID0,
                new BlockStorageC(VOLUME_TRD_BLOCK_ID1) as Block_TRD_BLOCK_ID1;
    LoggerP.BlockWrite0 -> Block_TRD_BLOCK_ID0;
    LoggerP.BlockWrite1 -> Block_TRD_BLOCK_ID1;
    LoggerP.BlockRead0 -> Block_TRD_BLOCK_ID0;
    LoggerP.BlockRead1 -> Block_TRD_BLOCK_ID1;
#endif
}


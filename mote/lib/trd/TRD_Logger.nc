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
 * Interface for TRD packet logger.
 *
 * Embedded Networks Laboratory, University of Southern California
 * @date Nov/19/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/

interface TRD_Logger {

    /* init
        - In TelosB, erase all volumes prior to use.
        - In Mica2/MicaZ, initDone is signaled when allocation is done.
    */
    command error_t init();

    event void initDone(error_t success);

    /**
     * Write 'data' of length 'size' into the flash.
     *  - returns the memory location in *memloc where *data is writen.
     *  - size can be less than BYTES_PER_PKT, but that amount is allocated.
     **/
    command error_t write(uint16_t *memloc, uint8_t *data, uint8_t size);

    event void writeDone(uint8_t *data, uint8_t size, error_t success);

    command error_t read(uint16_t memloc, uint8_t* buffer);

    event void readDone(uint8_t* buffer, error_t success);
}


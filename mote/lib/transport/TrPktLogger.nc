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
 * Transport Packet Logger interface: log packets into flash sequentially,
 * and retrieve packets in the flash based on transport sequence number.
 *
 * Used by reliable transport layers.
 * Use the flash as a circular buffer for all packets.
 * Store packets for potential retransmissions.
 *
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * Embedded Networks Laboratory, University of Southern California
 * @modified Feb/27/2009
 **/

interface TrPktLogger {

    /**
     * Initialize the flash for logging, erase all volumes.
     * Must be called after StdControl.init() of the actuall Logger module.
     **/
    command error_t init();

    event void initDone(error_t err);

    /**
     * You must erase before re-using (over-writing)
     **/
    command error_t erase(uint8_t id);

    event void eraseDone(uint8_t id, error_t err);

    /**
     * This command assumes sequential write, meaning that seqno must be
     * non-decreasing (except for wrap-arround)
     * The reason for having 'seqno' as an argument is to deal with
     * duplicate calls, validity check, etc.
     * @param size can be less than TR_BYTES_PER_PKT, but that amount is allocated.
     **/
    command error_t write(uint8_t id, uint16_t seqno, uint8_t *data, uint8_t size);

    event void writeDone(uint8_t *data, uint8_t size, error_t err);

    command error_t read(uint8_t id, uint16_t seqno, uint8_t* buffer);

    event void readDone(uint8_t* buffer, uint8_t size, error_t err);
}


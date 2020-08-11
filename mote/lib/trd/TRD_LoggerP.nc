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
 * TRD packet logger module for TelosB platform.
 * - 1 logical volume corresponds to 2 physical volumes.
 *
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * Embedded Networks Laboratory, University of Southern California
 * @modified Feb/27/2009
 **/


#include "trd.h"
#include "TRD_Logger.h"

module TRD_LoggerP
{
    provides {
        interface Init;
        interface TRD_Logger as Logger;
    }
    uses {
        interface BlockWrite as BlockWrite0;
        interface BlockWrite as BlockWrite1;
        interface BlockRead as BlockRead0;
        interface BlockRead as BlockRead1;
    }
}

implementation
{
    uint8_t bInfo_ready;
    uint8_t bInfo_currVol;  // primary(0) or secondary(1)
    uint8_t bInfo_dirty0;
    uint8_t bInfo_dirty1;
    uint8_t bInfo_initState;

    uint16_t curr_flash_vptr;
    
    enum {
        S_INIT      = 0x2,
        S_IDLE      = 0x3,
        S_ERASE_VOL = 0x4
    };  

    command error_t Init.init() {
        bInfo_ready = FALSE;
        bInfo_currVol = 0;
        bInfo_dirty0 = FALSE;
        bInfo_dirty1 = FALSE;
        bInfo_initState = S_IDLE;
        curr_flash_vptr = 0;
        return SUCCESS;
    }

    error_t _erase(uint8_t vol) {
        if (vol == 0)
            return call BlockWrite0.erase();
        else if (vol == 1)
            return call BlockWrite1.erase();
        return FAIL;
    }
    
    command error_t Logger.init() { // This will erase ALL volumes!!!
        if (bInfo_initState == S_IDLE)  // in idle. mount was done.
            _erase(0);              // start erasing all volumes
        else
            return FAIL;
        bInfo_initState = S_INIT;
        return SUCCESS;
    }

    command error_t Logger.write(uint16_t *memloc, uint8_t *data, uint8_t size) {
        uint16_t virtual_addr = curr_flash_vptr;
        uint32_t physical_addr = virtual_addr * TRD_FLASH_PKT_SIZE;
        error_t result = FAIL;

        if (bInfo_initState != S_IDLE)
            return FAIL;
        if (size > TRD_FLASH_PKT_SIZE)
            return FAIL;
        if (((bInfo_currVol == 0) && (bInfo_dirty0)) ||
            ((bInfo_currVol == 1) && (bInfo_dirty1))) { // before eraseDone
            return FAIL;
        }
        if (bInfo_currVol == 0)
            result = call BlockWrite0.write(physical_addr, data, size);
        else if (bInfo_currVol == 1)
            result = call BlockWrite1.write(physical_addr, data, size);

        if (result == SUCCESS) {
            *memloc = virtual_addr;
            curr_flash_vptr++;
            if (curr_flash_vptr >= TRD_FLASH_NUM_PKTS)
                curr_flash_vptr = 0;    // flash wrap-around
        }
        return result;
    }

    void _writeDone(uint8_t vol, error_t result, storage_addr_t addr, void* buf, storage_len_t len)
    {
        if (result != SUCCESS) {
            signal Logger.writeDone(buf, len, FAIL);
            return;
        }
        if (curr_flash_vptr == 0) {
            if (bInfo_currVol == 0) {
                bInfo_dirty0 = TRUE;    // this volume is full
                bInfo_currVol = 1;    // change to the other volume
            } else {
                bInfo_dirty1 = TRUE;    // this volume is full
                bInfo_currVol = 0;    // change to the other volume
            }

            if (bInfo_currVol == 0) {
                if (bInfo_dirty0)   // if that is also full,
                    _erase(0);
            } else {
                if (bInfo_dirty1)   // if that is also full,
                    _erase(1);
            }
        }
        signal Logger.writeDone(buf, (uint8_t)len, SUCCESS);
    }

    event void BlockWrite0.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {
        _writeDone(0, error, addr, buf, len);
    }
    event void BlockWrite1.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {
        _writeDone(1, error, addr, buf, len);
    }


    command error_t Logger.read(uint16_t memloc, uint8_t* buffer) {
        uint8_t vol;
        uint32_t size = (uint32_t) TRD_FLASH_PKT_SIZE;
        uint32_t physical_addr = memloc * TRD_FLASH_PKT_SIZE;
        error_t result = FAIL;

        if (bInfo_initState != S_IDLE)
            return FAIL;
        if (memloc > TRD_FLASH_NUM_PKTS)
            return FAIL;

        if (memloc < curr_flash_vptr) {
            vol = bInfo_currVol;
        } else {
            if (bInfo_currVol == 0)
                vol = 1;
            else
                vol = 0;
        }

        if (vol == 0)
            result = call BlockRead0.read(physical_addr, buffer, size);
        else if (vol == 1)
            result = call BlockRead1.read(physical_addr, buffer, size);
        return result;
    }


    void _readDone(uint8_t vol, error_t result, storage_addr_t addr, void* buf, storage_addr_t len) {
        if (result == SUCCESS) {
            signal Logger.readDone(buf, SUCCESS);
        } else {
            signal Logger.readDone(buf, FAIL);
        }
    }

    event void BlockRead0.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {
        _readDone(0, error, addr, buf, len);
    }
    event void BlockRead1.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {
        _readDone(1, error, addr, buf, len);
    }

    event void BlockWrite0.eraseDone(error_t result) {
        bInfo_dirty0 = FALSE;
        if (result != SUCCESS) {

        } else if (!bInfo_ready)
            _erase(1);
    }

    event void BlockWrite1.eraseDone(error_t result) {
        bInfo_dirty1 = FALSE;
        if (!bInfo_ready) {
            bInfo_ready = TRUE;
            if (bInfo_initState == S_INIT) {    // init(=erase_all) requested
                bInfo_initState = S_IDLE;
                signal Logger.initDone(SUCCESS);
            }
        }
    }

    event void BlockWrite0.syncDone(error_t result) {}
    event void BlockWrite1.syncDone(error_t result) {}
    event void BlockRead0.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
    event void BlockRead1.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}

    default event void Logger.initDone(error_t success) {}
    default event void Logger.writeDone(uint8_t *data, uint8_t size, error_t succ) {}
    default event void Logger.readDone(uint8_t* buffer, error_t succ) {}
}


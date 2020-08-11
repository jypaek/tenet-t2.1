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
 *
 * @author Jeongyeup Paek (jpaek@usc.edu)
 * @modified Feb/16/2009
 **/


module DummyRouteControlP {

  provides {
    interface RouteControl;
  }
}

implementation {
  command uint16_t RouteControl.getParent() {
    return 0;
  }

  command uint8_t RouteControl.getQuality() {
    return 0;
  }

  command uint8_t RouteControl.getDepth() {
    return 0;
  }

  command uint8_t RouteControl.getOccupancy() {
    return 0;
  }
  
  command uint8_t RouteControl.getLinkRssi() {
    return 0;
  }

  command error_t RouteControl.setUpdateInterval(uint16_t Interval) {
    return SUCCESS;
  }

  command error_t RouteControl.manualUpdate() {
    return SUCCESS;
  }
}
  

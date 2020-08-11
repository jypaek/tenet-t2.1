
/**
 * Wrapper around HilAlarm32khzC to provid Alarm32khzC
 *
 * @modified Oct/26/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/

#include "Timer.h"

configuration Alarm32khzP {
  provides interface Alarm<T32khz, uint32_t> as Alarm32khz[uint8_t id];
}
implementation {
  components HilAlarm32khzC, MainC;
  MainC.SoftwareInit -> HilAlarm32khzC;
  Alarm32khz = HilAlarm32khzC;
}



/**
 * Alarm32khzC is a platform-independant 32khz/32bit alarm module.
 *
 * @modified Oct/26/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/

#include "Timer.h"

generic configuration Alarm32khzC() {
    provides interface Alarm<T32khz, uint32_t>;
}
implementation {
    /*
    components Alarm32khzP;
    Alarm = Alarm32khzP.Alarm32khz[unique(UQ_TIMER_MILLI)];
    */
    components new Alarm32khz32C(), MainC;
    Alarm = Alarm32khz32C;
    MainC.SoftwareInit -> Alarm32khz32C;
}


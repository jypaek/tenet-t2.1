
/**
 * GlobalAlarm module which provides an alarm that fires at specific 
 * time-synchronized global time.
 *
 * @modified Oct/26/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/


module GlobalAlarmP {
    provides {
        interface AbsoluteTimer as GlobalAbsoluteTimer;
    }
    uses {
        interface GlobalTime<TMilli>;
        interface Alarm<T32khz, uint32_t>;
    }
}
implementation {

    /**
     * Set an alarm(AbsoluteTimer) that fires at a specific global time.
     *
     * It first converts global time into a corresponding local time,
     * and then sets a local alarm.
     * @return FAIL if time is not synchronized.
     **/
    command error_t GlobalAbsoluteTimer.set(uint32_t gtime) {
        uint32_t convertTime, now;
        
        convertTime = gtime;
        if (call GlobalTime.global2Local(&convertTime) == FAIL)
            return FAIL;

        now = call Alarm.getNow();
        if (convertTime < now)
            return FAIL;
        call Alarm.start(convertTime - now);
        return SUCCESS;
    }
    
    command error_t GlobalAbsoluteTimer.cancel() {
        call Alarm.stop();
        return SUCCESS;
    }

    task void fired_task() {
        signal GlobalAbsoluteTimer.fired();
    }

    async event void Alarm.fired() {
        post fired_task();
    }

    default event void GlobalAbsoluteTimer.fired() { }
}



/**
 * LocalTimeInfoM
 *
 * @modified Oct/26/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/

enum {
    //#if defined(PLATFORM_TELOS) || defined(PLATFORM_TELOSB)
        TICKS_PER_SEC = 32768L
    //#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2)
    //    TICKS_PER_SEC = 32768L
    //#endif
};

module LocalTimeInfoP {
    provides {
        interface LocalTimeInfo;
    }
}
implementation {

    command uint32_t LocalTimeInfo.msToTimerInterval(uint32_t interval) {
        uint32_t t1,t2,t10;
        // Basically, we are doing 1024*interval/1000
        t10 = (256*interval)/25;
        t1 = t10 / 10;
        t2 = t1 + 1;
        if(t10 - (t1*10) > (t2*10) - t10)
            t1 = t2;
        interval = t1;
        return interval;
    }

    command uint32_t LocalTimeInfo.getClockFreq() {
        uint32_t freq = TICKS_PER_SEC;
        return freq;
    }

    command uint32_t LocalTimeInfo.msToTicks(uint32_t ms) {
        uint32_t ms_h, ms_l;
        uint32_t tmp, tmp2;
        uint32_t ticks_h, ticks_l, ticks;
        
        ms_h = (ms >> 16) & 0x0000ffff; // upper 2-bytes
        ms_l = (ms) & 0x0000ffff;       // lower 2-bytes
        
        tmp = ((0x00010000/8)*TICKS_PER_SEC)/(1000/8);
        tmp2 = (ms_h*TICKS_PER_SEC)/(1000/8);

        if (tmp > tmp2)
            ticks_h = ms_h * tmp;
        else
            ticks_h = (0x00010000/8)*tmp2;
        
        ticks_l = (TICKS_PER_SEC * ms_l) / 1000;

        ticks = ticks_h + ticks_l;
        //return ((ms * TICKS_PER_SEC) / 1000);
        return ticks;
    }

    command uint32_t LocalTimeInfo.ticksToMs(uint32_t ticks) {
        uint32_t ticks_h, ticks_l, tmp;
        uint32_t ms_h, ms_l, ms;
        
        ticks_h = (ticks >> 16) & 0x0000ffff; // upper 2-bytes
        ticks_l = (ticks) & 0x0000ffff;       // lower 2-bytes
        
        tmp = 0x00010000/TICKS_PER_SEC; // "2^16 / RATE"
        
        ms_h = (1000 * ticks_h) * tmp;
        ms_l = (1000 * ticks_l) / TICKS_PER_SEC;

        ms = ms_h + ms_l;
        //return ((ticks * 1000) / TICKS_PER_SEC);
        return ms;
    }

}


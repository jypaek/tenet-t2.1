
/**
 * For t1->t2 porting convenience for now.
 *
 * @modified Oct/26/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/


configuration LocalTimeC {
    provides {
        interface LocalTime<T32khz>;
        interface LocalTimeInfo;
    }
}
implementation {
    components LocalTimeInfoP, LocalTime32khzC;

    LocalTime     = LocalTime32khzC;
    LocalTimeInfo = LocalTimeInfoP;
}


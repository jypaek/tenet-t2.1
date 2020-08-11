
/**
 * Configuration file for GlobalAlarm module which provides 'alarm' service
 * based on time-synchronized global time (using FTSP)
 *
 * @modified Oct/26/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/

configuration GlobalAlarmC {
    // alarm that fires at specific global time
    provides interface AbsoluteTimer as GlobalAbsoluteTimer; 
}
implementation {
    components  MainC, GlobalAlarmP
                , TimeSyncC
                , new Alarm32khzC()
                ;

    //MainC.StdControl   -> TimeSyncC;
    MainC.SoftwareInit -> TimeSyncC;
    MainC.Boot         <- TimeSyncC;

    // The goal is to transform global timer alarm into local timer alarm.
    GlobalAbsoluteTimer = GlobalAlarmP;
    GlobalAlarmP.Alarm -> Alarm32khzC;
    GlobalAlarmP.GlobalTime -> TimeSyncC.GlobalTime;
}


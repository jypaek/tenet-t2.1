
/**
 * HilAlarm32khzC provides a parameterized interface to a virtualized
 * 32khz alarm.  Alarm32khzC uses this component to allocate new alarms.
 *
 * @modified Oct/26/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 **/

configuration HilAlarm32khzC
{
  provides interface Init;
  provides interface Alarm<T32khz, uint32_t> as Alarm32khz[ uint8_t num ];
}
implementation
{
  components new Alarm32khz32C();
  components new VirtualizeAlarmC(T32khz, uint32_t, uniqueCount(UQ_TIMER_MILLI));

  Init = Alarm32khz32C;
  Init = VirtualizeAlarmC;

  Alarm32khz = VirtualizeAlarmC.Alarm;
  VirtualizeAlarmC.AlarmFrom -> Alarm32khz32C;
}


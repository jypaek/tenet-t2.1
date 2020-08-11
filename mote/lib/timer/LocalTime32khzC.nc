
/**
 * Provide current time via the LocalTime<T32khz> interface.
 *
 * @modified Oct/26/2007
 * @author Jeongyeup Paek (jpaek@enl.usc.edu)
 */

#include "Timer.h"

configuration LocalTime32khzC {
  provides interface LocalTime<T32khz>;
}
implementation
{
  components new CounterToLocalTimeC(T32khz);
  components Counter32khz32C;

  LocalTime = CounterToLocalTimeC;
  CounterToLocalTimeC.Counter -> Counter32khz32C;
}


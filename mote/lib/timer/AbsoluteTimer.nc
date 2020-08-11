
/**
 * We will probably remove this interface later and substitue with 
 * 'Alarm' interface in tinyos-2.
 * We leave it for now during the process of porting.
 *
 * @author Jeongyeup Paek
 **/

interface AbsoluteTimer {

    /**
     * Set the AbsoluteTimer (alarm) so that 'fired' event happens at 
     * localtime 'atime'.
     **/
    command error_t set(uint32_t atime);

    command error_t cancel();

    event   void fired();

}


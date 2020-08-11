/*
 * Interface between platform dependant and independant parts of sampling.
 *
 * @author August Joki
*/

interface SampleADC {
    command void init();
    command void start();
    command void stop();
    command bool validChannel(uint8_t channel);
    command error_t getData(uint8_t channel);
    event void dataReady(error_t err, uint16_t data);
}


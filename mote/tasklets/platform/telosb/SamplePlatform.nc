/*
 * Platform dependant part of sampling.
 *
 * @author Marcos Vieira
 * @author August Joki
 * @author Jeongyeup Paek
*/

module SamplePlatform {
    provides {
        interface SampleADC as ADC;
    }
    uses {
        interface Read<uint16_t> as InternalTemperature;
        interface Read<uint16_t> as InternalVoltage;
        interface Read<uint16_t> as Tsr;
        interface Read<uint16_t> as Par;
        interface Read<uint16_t> as Temperature;
        interface Read<uint16_t> as Humidity;
    }
}
implementation {

    command error_t ADC.getData(uint8_t channel) {
        switch(channel) {
            case HUMIDITY:
                return call Humidity.read();
                break;
            case TEMPERATURE:
                return call Temperature.read();
                break;
            case PHOTO:
            case TSRSENSOR:
                return call Tsr.read();
                break;
            case PARSENSOR:
                return call Par.read();
                break;
            case ITEMP:
                return call InternalTemperature.read();
                break;
            case VOLTAGE:
                return call InternalVoltage.read();
                break;
            default:
                return FAIL;
        }
        return SUCCESS;
    }

    command bool ADC.validChannel(uint8_t channel) {
        switch(channel) {
            case HUMIDITY:
            case TEMPERATURE:
            case PHOTO:
            case TSRSENSOR:
            case PARSENSOR:
            case ITEMP:
            case VOLTAGE:
                break;
            default:
                return FALSE;
        }
        return TRUE;
    }

    event void InternalTemperature.readDone(error_t err, uint16_t data) {
        signal ADC.dataReady(err, data);
    }
    event void InternalVoltage.readDone(error_t err, uint16_t data) {
        signal ADC.dataReady(err, data);
    }
    event void Humidity.readDone(error_t err, uint16_t data) {
        signal ADC.dataReady(err, data);
    }
    event void Temperature.readDone(error_t err, uint16_t data) {
        signal ADC.dataReady(err, data);
    }
    event void Tsr.readDone(error_t err, uint16_t data) {
        signal ADC.dataReady(err, data);
    }
    event void Par.readDone(error_t err, uint16_t data) {
        signal ADC.dataReady(err, data);
    }

    command void ADC.init() {
    }

    command void ADC.start() {
    }

    command void ADC.stop() {
    }
}


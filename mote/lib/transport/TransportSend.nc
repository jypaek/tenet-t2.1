
/**
 * Send interface that the transport layer provides.
 *
 * @author Jeongyeup Paek
 * Embedded Networks Laboratory, University of Southern California
 * @modified 1/24/2007
 **/

interface TransportSend {

    /**
     * Sends a single transport packet with specified 'tid' to 'dstAddr'
     *
     **/
    command error_t send(uint16_t tid, uint16_t dstAddr, uint8_t length, void *data);

    /**
     * SendDone event: 'data' with 'tid' has been sent.
     *
     **/
    event void sendDone(uint16_t tid, void *data, error_t success);

    /**
     * get the maximun payload length that can be used.
     *
     **/
    command uint8_t maxPayloadLength();
}



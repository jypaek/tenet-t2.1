
TR_TARGET     = transport  # default binary name
TR_TARGET_ARM = atransport # for arm processors (e.g. Stargates)
# default is not to compile for arm.
# do 'make arm' to compile for arm processors


BASESTATIONPATH = $(MOTELIB)/../apps/BaseStation

include ../Makerules


# main
TR_SRC = transportmain.c    # main
# various mote-to-master transport layer protocols
TR_SRC += packettransport.c streamtransport.c rcrtransport.c
# data structures (client-app, tid-list, packet-list, etc)
TR_SRC += client.c tidlist.c connectionlist.c sortedpacketlist.c uint16list.c 
# interfaces to master-app layer
TR_SRC += tr_if.c service_if.c
# special services
TR_SRC += tcmp.c service.c
# routing layer
TR_SRC += routinglayer.c
TR_SRC += collectionlayer.c
# misc
TR_SRC += $(INCPATH)/timeval.c $(INCPATH)/tosmsg.c $(SFPATH)/sfsource.c
TR_SRC += trsource.c
# trd (master)
TR_SRC += $(TRDPATH)/trd.c $(TRDPATH)/trd_state.c $(TRDPATH)/trd_misc.c \
          $(TRDPATH)/trd_timer.c $(TRDPATH)/trd_memory.c \
          $(TRDPATH)/trd_transport.c $(TRDPATH)/trd_fragment.c
# trd (mote&master)
TR_SRC += $(MOTETRDPATH)/trd_metalist.c $(MOTETRDPATH)/trd_nodecache.c \
          $(MOTETRDPATH)/trd_seqno.c $(MOTETRDPATH)/trd_table.c $(MOTETRDPATH)/trd_checksum.c
# transport layer misc
TR_SRC += $(MOTETRANSPORTPATH)/tr_checksum.c $(MOTETRANSPORTPATH)/tr_packet.c \
          $(MOTETRANSPORTPATH)/tr_seqno.c



CFLAGS += -g -Wall
CFLAGS += -I. -I$(INCPATH) -I$(SFPATH) -I$(LIBPATH) 
CFLAGS += -I$(TRDPATH) -I$(MOTETRDPATH)
CFLAGS += -I$(MOTELIB)
CFLAGS += -I$(MOTEROUTERPATH)
CFLAGS += -I$(MOTETRANSPORTPATH)
CFLAGS += -I$(BASESTATIONPATH)

# default is not to compile for arm.
all: pc
pc: $(TR_TARGET)
arm: $(TR_TARGET_ARM)


# default compilation
transport: $(TR_SRC)
	gcc -O1 $(CFLAGS) $^ -o $@ 


# for ARM processors (e.g. Stargates)
atransport: $(TR_SRC)
	arm-linux-gcc -O1 $(CFLAGS) $^ -o $@ 


clean:
	rm -f $(TR_TARGET) $(TR_TARGET_ARM)
	rm -f *.o



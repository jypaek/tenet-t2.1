
PC= snoop   # default binary name
ARM= asnoop # for arm processors (e.g. Stargates)


include ../../master/Makerules


CFILES += $(INCPATH)/timeval.c $(INCPATH)/tosmsg.c $(INCPATH)/tosserial.c
CFILES += $(SFPATH)/serialsource.c $(SFPATH)/sfsource.c
CFILES += $(TRDPATH)/trd_misc.c


CFLAGS += -I$(INCPATH) -I$(SFPATH) -I$(TRDPATH) -I$(TRPATH)
CFLAGS += -I$(MOTETRDPATH) -I$(MOTEROUTERPATH) -I$(MOTETRANSPORTPATH)
CFLAGS += -I$(MOTETIMESYNCPATH) -I$(MOTELIB)


all: $(PC)

# default compilation
snoop: snoop.c $(CFILES)
	gcc -O1 -Wall -g -o $@ $(CFLAGS) snoop.c $(CFILES)

# For ARM
asnoop: snoop.c $(CFILES)
	arm-linux-gcc -O1 -Wall -g -o $@ $(CFLAGS) snoop.c $(CFILES)

clean:
	rm -f $(PC) $(ARM)


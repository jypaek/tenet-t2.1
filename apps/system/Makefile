
PC= system   # default binary name
ARM= asystem # for arm processors (e.g. Stargates), using arm-linux-gcc

include ../Makerules
CFLAGS += -I$(MOTELIB)

all: tenetlib pc

pc: $(PC)
arm: $(ARM)

# default compilation
system: system.c sortedlist.c $(TENET_LIB)
	gcc -O1 -Wall -g $(CFLAGS) $^ -o $@

# for arm processors (e.g. Stargates), using arm-linux-gcc
asystem: system.c sortedlist.c $(TENET_LIB_ARM)
	arm-linux-gcc -O1 -Wall -g $(CFLAGS) $^ -o $@

# need to compile the tenet master-side library, if not done before
tenetlib:
	(cd ../../master/tasklib; make)
    
clean:
	rm -f $(PC) $(ARM)



include ../Makerules

SF_SRC += $(INCPATH)/tosmsg.c $(SFPATH)/sfsource.c

CFLAGS += -g -Wall
CFLAGS += -I. -I$(INCPATH) -I$(SFPATH)
CFLAGS += -I$(MOTEROUTERPATH)

all: lqibase.c $(SF_SRC)
	gcc $(CFLAGS) $(SF_SRC) lqibase.c -o lqibase

clean:
	rm -f lqibase

vpath %.s math string cout

LIST= cnvrt.o pow.o print.o

all: $(LIST) libcmple.out

%.o: %.s
	as -o $@ $<

libcmple.out: libcmple.c
	gcc -o $@ -O3 $<
	./libcmple.out

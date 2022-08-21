vpath %.s math string cout

LIST= cnvrt.o pow.o print.o
LIBCMPLE=false

all: $(LIST) libcmple.out
	$(if $(filter $(LIBCMPLE), true), ./libcmple.out)

%.o: %.s
	as -o $@ $<
	$(eval LIBCMPLE=true)

libcmple.out: libcmple.c
	gcc -o $@ -O3 $<

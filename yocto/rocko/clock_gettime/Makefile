TARGET = aarch64-poky-linux-
#CC   = $(CC)

SRCS = clock_gettime.c
OBJS = $(SRCS:.c=.o)
PROG = clock_gettime

all : obj prog

obj : $(OBJS)

prog : $(PROG)

%.o : %.c
	$(CC) -c -o $@ $<

$(PROG) : $(OBJS)
	$(CC) -o $@ $(OBJS)

test :
	./$(PROG)

clean :
	rm -f $(OBJS) $(PROG)

.PHONY : \
	all clean test


CROSS = h8300-elf-
CC    = $(CROSS)gcc
RUN   = $(CROSS)run

SRCS = main.c
OBJS = $(SRCS:.c=.o)
PROG = hello.elf

all : obj prog

obj : $(OBJS)

prog : $(PROG)

%.o : %.c
	$(CC) -c -o $@ $<

$(PROG) : $(OBJS)
	$(CC) -o $@ $(OBJS)

run : test

test :
	$(RUN) $(PROG)

clean :
	rm -f $(OBJS) $(PROG)

.PHONY : \
    all clean test obj prog run


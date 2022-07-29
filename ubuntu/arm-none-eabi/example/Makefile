CROSS = arm-none-eabi-
CC    = $(CROSS)gcc
RUN   = $(CROSS)run

SRCS = main.c
OBJS = $(SRCS:.c=.o)
PROG = hello.elf

LDFLAGS = -specs=rdimon.specs

all : obj prog

obj : $(OBJS)

prog : $(PROG)

%.o : %.c
	$(CC) -c -o $@ $<

$(PROG) : $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

run : test

test :
	$(RUN) $(PROG)

.PHONY : \
    all clean test obj prog run


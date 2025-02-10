SRCS = mymodule.c
OBJS = $(SRCS:.c=.o)

obj-m += $(OBJS)

KERNEL_RELEASE=$(shell uname -r)
KBUILD=/lib/modules/$(KERNEL_RELEASE)/build/

KERNEL_OBJ = mymodule.ko

all :
	$(MAKE) -C $(KBUILD) M=$(PWD) modules

help :
	@echo "Usage : make <target>"
	@echo "  target:"
	@echo "    all"
	@echo "    clean"
	@echo "    ins"
	@echo "    rm"
	@echo "    info"

clean :
	$(MAKE) -C $(KBUILD) M=$(PWD) clean

ins:
	sudo insmod $(KERNEL_OBJ)

rm:
	sudo rmmod  $(KERNEL_OBJ)

info :
	modinfo $(KERNEL_OBJ)


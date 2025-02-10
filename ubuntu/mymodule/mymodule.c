/* https://developer.ibm.com/articles/control-linux-kernel-extensions/ */

/*
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
*/

#include <linux/module.h>
#include <linux/printk.h>

#define MODULE_NAME "mymodule"

MODULE_LICENSE("GPL");

int init_mymodule(void);
void exit_mymodule(void);

/*
#include <linux/kthread.h>

int open(const char *pathname, int flags);
int fd;
#define DEVICE_FILE_NAME "/dev/char_dev"
fd = open(DEVICE_FILE_NAME, 0);

*/

int init_mymodule(void)
{
    pr_info("[MyModule] init_mymodule\n");
    return 0;
}

void exit_mymodule(void)
{
    pr_info("[MyModule] exit_mymodule\n");
}

module_init(init_mymodule);
module_exit(exit_mymodule);




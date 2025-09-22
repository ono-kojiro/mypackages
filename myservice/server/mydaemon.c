#include <stdio.h>
#include <stdlib.h>

/* for MAX_PATH */
#include <limits.h>

/* for strerror() */
#include <string.h>

/* for errno */
#include <errno.h>

#include <syslog.h>

/* for signal() */
#include <signal.h>

/* for dup2() */
#include <unistd.h>

/* for O_RDWR */
#include <fcntl.h>

#define MAXFD 64

#include <event.h>

#include <getopt.h>

#include "common.h"
#include "accept_handler.h"
#include "cmd_handler.h"

void signal_handler(int sig)
{
    switch(sig){
        case SIGHUP:
		    syslog(LOG_INFO, "Hangup Signal Catched");
            break;
        case SIGTERM:
	    	syslog(LOG_INFO, "Terminate Signal Catched");
	    	closelog();
            exit(0);
            break;
        default :
            break;
    }
}

int daemonize(int flag)
{
    int i;
    int ret;
    int fd = 0;

    pid_t pid = 0;
    pid = fork();
    if(pid == -1){
        /* failure */
        return -1;
    }
    else if(pid != 0){
        /* parent process */
        /* pid is PID of the child process */
        _exit(0);
    }

    /* child process */
  
    setsid();

    signal(SIGCHLD, SIG_IGN);
    signal(SIGTSTP, SIG_IGN);
    signal(SIGTTOU, SIG_IGN);
    signal(SIGTTIN, SIG_IGN);

    signal(SIGHUP,  signal_handler);
    signal(SIGTERM, signal_handler);

    pid = fork();
    if(pid == 0){
        /* child process */
        _exit(0);
    }

    /* parent process */

    if(flag == 0){
        ret = chdir("/");
        if(!ret){
            perror("chdir");
            exit(ret);
        }
    }

    for(i = 0; i < MAXFD; i++){
        close(i);
    }

    fd = open("/dev/null", O_RDWR, 0);
    if(fd != -1){
        dup2(fd, 0);
        dup2(fd, 1);
        dup2(fd, 2);
        if(fd < 2){
            close(fd);
        }
    }

    return 0;
}

int start_server(const char *port)
{
	int soc;
	int err;
	struct event ev;
    struct event ev_cmd;

	const char *host = "localhost";
	/* const char *port = "9999"; */

	event_init();
	soc = server_socket(host, port);
	if(soc == -1){
	    syslog(LOG_INFO, "server_socket failed");
		exit(1);
	}

	event_set(&ev, soc, EV_READ | EV_PERSIST, accept_handler, &ev);
	err = event_add(&ev, NULL);
	if(err != 0){
	    syslog(LOG_INFO, "event_add failed");
		close(soc);
		exit(1);
	}
	
    soc = server_socket(host, "9999");
	if(soc == -1){
	    syslog(LOG_INFO, "server_socket failed");
		exit(1);
	}

	event_set(&ev_cmd, soc, EV_READ | EV_PERSIST, accept_cmd, &ev_cmd);
	err = event_add(&ev_cmd, NULL);
	if(err != 0){
	    syslog(LOG_INFO, "event_add failed");
		close(soc);
		exit(1);
	}

	event_dispatch();
	return 0;
}

int main(int argc, char **argv)
{
    int ret = 0;
    int c;
    int index;

    struct option options[] = {
        { "help",       no_argument, 0, 'h' },
        { "foreground", no_argument, 0, 'F' },
        { "port", required_argument, 0, 'p' },
        { 0, 0, 0, 0 }
    };
    const char *port = NULL;
    int show_help = 0;
    int is_foreground = 0;

    char buf[PATH_MAX];
    char *str;

    while(1){
        c = getopt_long(argc, argv, "hp:F", options, &index);
        if(c == -1){
            break;
        }

        switch(c){
            case 'h' :
                show_help = 1;
                break;
            case 'p' :
                port = optarg;
                break;
            case 'F' :
                is_foreground = 1;
                break;
        }
    }

    if(show_help){
        printf("Usage: %s <options>\n", argv[0]);
        printf("  options:\n");
        printf("\n");
        printf("  -h, --help\n");
        printf("  -p, --port\n");
        printf("  -F, --foreground\n");
        exit(1);
    }

    if(!port){
        fprintf(stderr, "ERROR: no port option\n");
        ret++;
    }

    if(ret){
        exit(ret);
    }


    if(!is_foreground){
        openlog(argv[0], LOG_CONS | LOG_PID, LOG_USER);
        syslog(LOG_INFO, "call daemonize()");
        daemonize(1);
    }
    else {
        openlog(NULL, LOG_PERROR, LOG_USER);
        syslog(LOG_INFO, "call daemonize()");
    }
    str = getcwd(buf, sizeof(buf));

    if(str == NULL){
        str = strerror(errno);
        syslog(LOG_USER | LOG_NOTICE, "daemon:%s\n", str);
    }
    else {
        syslog(LOG_USER | LOG_NOTICE, "daemon:cwd=%s\n", buf);
    }

	/*
    while(1){
        sleep(1);
    }
	*/
	start_server(port);

    closelog();

    return 0;
}


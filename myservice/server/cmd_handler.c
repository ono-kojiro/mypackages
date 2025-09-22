#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>

#include <sys/param.h>
#include <sys/socket.h>
#include <sys/types.h>

#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>

#include <syslog.h>

#include <event.h>

#include "cmd_handler.h"
#include "mystrlcat.h"

void receive_cmd(int acc, short event, void *arg)
{
    char buf[512], *ptr;
    ssize_t len;
    struct event *ev = (struct event*) arg;

    if (event & EV_READ) {
        if ((len = recv(acc, buf, sizeof(buf), 0)) == -1) {
            /* エラー */
		    syslog(LOG_INFO, "recv failed");
		    (void) event_del(ev);
		    free(ev);
            (void) close(acc);
            return;
        }
        if (len == 0) {
		    syslog(LOG_INFO, "recv:EOF");
	    	(void) event_del(ev);
	    	free(ev);
            (void) close(acc);
            return;
        }
        buf[len]='\0';
        if ((ptr = strpbrk(buf, "\r\n")) != NULL) {
            *ptr = '\0';
        }
	    syslog(LOG_INFO, "[client]%s", buf);
		
		if(!strcmp(buf, "shutdown")){
			/* fprintf(stderr, "shutdown tcpserver\n"); */
	    	syslog(LOG_INFO, "shutdown tcpserver");
			event_del(ev);
			free(ev);
			close(acc);
			event_loopexit(NULL);
			return;
		}

        {
            FILE *pipe;
            int c;
            char ch;
            char line[256] = { 0 };
            char *p;
	    	syslog(LOG_INFO, "CMD request: '%s'\n", buf);
            pipe = popen(buf, "r");
            if(!pipe){
	    	    syslog(LOG_INFO, "popen failed");
			    event_del(ev);
			    free(ev);
			    close(acc);
			    event_loopexit(NULL);
            }

            while(1){
                p = fgets(line, 128, pipe);
                syslog(LOG_INFO, "%s", line);
                if(!p){
                    break;
                }

                if ((len = send(acc, line, (size_t)strlen(line), 0)) == -1) {
	    	        syslog(LOG_INFO, "send failed");
	    	        (void) event_del(ev);
	    	        free(ev);
                    (void) close(acc);
                }
            }

            pclose(pipe);
        }

    }
}

void accept_cmd(int soc, short event, void *arg)
{
	int err;

	char addr[NI_MAXHOST];
	char port[NI_MAXSERV];
	int acc;
	struct sockaddr_storage storage;
	socklen_t len;

	struct event *ev;

	if(event & EV_READ){
		len = (socklen_t) sizeof(storage);

		acc = accept(soc, (struct sockaddr *)&storage, &len);
		if(acc == -1){
		    syslog(LOG_INFO, "accept failed");
			return;
		}
		else{
			getnameinfo(
				(struct sockaddr *)&storage,
				len,
				addr, sizeof(addr),
				port, sizeof(port),
				NI_NUMERICHOST | NI_NUMERICSERV);
		    syslog(LOG_INFO, "accept:%s:%s\n", addr, port);
		}

		ev = (struct event *)malloc(1 * sizeof(struct event));
		if(ev == NULL){
			perror("malloc");
			return;
		}

		event_set(ev, acc, EV_READ | EV_PERSIST, receive_cmd, ev);
		err = event_add(ev, NULL);
		if(err != 0){
		    syslog(LOG_INFO, "event_add failed");
			free(ev);
			return;
		}
	}
}


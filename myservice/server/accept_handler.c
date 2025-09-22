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

#include "accept_handler.h"
#include "recv_handler.h"


void accept_handler(int soc, short event, void *arg)
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

		event_set(ev, acc, EV_READ | EV_PERSIST, recv_handler, ev);
		err = event_add(ev, NULL);
		if(err != 0){
		    syslog(LOG_INFO, "event_add failed");
			free(ev);
			return;
		}
	}
}


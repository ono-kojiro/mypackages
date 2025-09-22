#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <sys/socket.h>

#include <syslog.h>

#include <event.h>

#include "recv_handler.h"

#include "mystrlcat.h"

/* 送受信ハンドラ */
void recv_handler(int acc, short event, void *arg)
{
    char buf[512], *ptr;
    ssize_t len;
    /* event_set()の第５引数のデータをargで受け取れる */
    struct event *ev = (struct event*) arg;

    /* イベントのタイプが読み込み可能だった */
    if (event & EV_READ) {
        /* 受信 */
        if ((len = recv(acc, buf, sizeof(buf), 0)) == -1) {
            /* エラー */
		    syslog(LOG_INFO, "recv failed");
		    (void) event_del(ev);
		    free(ev);
            (void) close(acc);
            return;
        }
        if (len == 0) {
            /* エンド・オブ・ファイル */
            /* (void) fprintf(stderr, "recv:EOF\n"); */
		    syslog(LOG_INFO, "recv:EOF");
	    	(void) event_del(ev);
	    	free(ev);
            (void) close(acc);
            return;
        }
        /* 文字列化・表示 */
        buf[len]='\0';
        if ((ptr = strpbrk(buf, "\r\n")) != NULL) {
            *ptr = '\0';
        }
        /* (void) fprintf(stderr, "[client]%s\n", buf); */
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

        /* 応答文字列作成 */
        (void) mystrlcat(buf, ":OK\r\n", sizeof(buf));
        len = (ssize_t) strlen(buf);
        /* 応答 */
        if ((len = send(acc, buf, (size_t) len, 0)) == -1) {
            /* エラー */
            /* perror("send"); */
	    	syslog(LOG_INFO, "send failed");
	    	(void) event_del(ev);
	    	free(ev);
            (void) close(acc);
        }

    }
}


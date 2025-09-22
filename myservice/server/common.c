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

#include "common.h"

int get_sockaddr_info(const char *host, const char *port,
				struct sockaddr_storage *addr, socklen_t *addr_len)
{
	int soc;

	int err;
	struct addrinfo *info;

	char host_buf[NI_MAXHOST];
	char serv_buf[NI_MAXSERV];

	int opt;
	socklen_t opt_len;

	{
		struct addrinfo hints;
		memset(&hints, 0, sizeof(hints));
		hints.ai_family = AF_INET;
		hints.ai_socktype = SOCK_DGRAM;
		//hints.ai_flags = AI_PASSIVE;

		err = getaddrinfo(host, port, &hints, &info);
		//err = getaddrinfo(NULL, port, &hints, &info);
		if(err != 0){
			fprintf(stderr, "getaddrinfo():%s\n", gai_strerror(err));
			return -1;
		}
	}

	err = getnameinfo(
			info->ai_addr,info->ai_addrlen,
			host_buf, sizeof(host_buf),
			serv_buf, sizeof(serv_buf),
			NI_NUMERICHOST | NI_NUMERICSERV);
	if(err != 0){
		fprintf(stderr, "getnameinfo():%s\n", gai_strerror(err));
		freeaddrinfo(info);
		return -1;
	}

	fprintf(stderr, "addr=%s,port=%s\n", host_buf, serv_buf);

	memcpy(addr, info->ai_addr, info->ai_addrlen);
	*addr_len = info->ai_addrlen;

	freeaddrinfo(info);

	return 0;
}


int server_socket(const char *host, const char *port)
{
	int soc;

	int err;
	struct addrinfo *info;

	char host_buf[NI_MAXHOST];
	char serv_buf[NI_MAXSERV];

	int opt;
	socklen_t opt_len;

	{
		struct addrinfo hints;
		memset(&hints, 0, sizeof(hints));
		hints.ai_family = AF_INET;
		hints.ai_socktype = SOCK_STREAM;
		hints.ai_flags = AI_PASSIVE;

		err = getaddrinfo(host, port, &hints, &info);
		//err = getaddrinfo(NULL, port, &hints, &info);
		if(err != 0){
			fprintf(stderr, "getaddrinfo():%s\n", gai_strerror(err));
			return -1;
		}
	}

	err = getnameinfo(
			info->ai_addr,info->ai_addrlen,
			host_buf, sizeof(host_buf),
			serv_buf, sizeof(serv_buf),
			NI_NUMERICHOST | NI_NUMERICSERV);
	if(err != 0){
		fprintf(stderr, "getnameinfo():%s\n", gai_strerror(err));
		freeaddrinfo(info);
		return -1;
	}

	fprintf(stderr, "addr = %s, port = %s\n", host_buf, serv_buf);

	soc = socket(info->ai_family, info->ai_socktype, info->ai_protocol);
	if(soc == -1){
		perror("socket");
		freeaddrinfo(info);
		return -1;
	}

	opt = 1;
	opt_len = sizeof(opt);
	err = setsockopt(soc, SOL_SOCKET, SO_REUSEADDR, &opt, opt_len);
	if(err == -1){
		perror("setsockopt");
		close(soc);
		freeaddrinfo(info);
		return -1;
	}

	err = bind(soc, info->ai_addr, info->ai_addrlen);
	if(err == -1){
		perror("bind");
		close(soc);
		freeaddrinfo(info);
		return -1;
	}

	err = listen(soc, SOMAXCONN);
	if(err == -1){
		perror("listen");
		close(soc);
		freeaddrinfo(info);
		return -1;
	}

	freeaddrinfo(info);

	return soc;
}


int receiver_socket(const char *host, const char *port,
				const char *multicast_address)
{
	int soc;

	int err;
	struct addrinfo *info;

	char host_buf[NI_MAXHOST];
	char serv_buf[NI_MAXSERV];

	int opt;
	socklen_t opt_len;

	struct ip_mreq mreq;

	{
		struct addrinfo hints;
		memset(&hints, 0, sizeof(hints));
		hints.ai_family = AF_INET;
		//hints.ai_socktype = SOCK_STREAM;
		hints.ai_socktype = SOCK_DGRAM;
		hints.ai_flags = AI_PASSIVE;

		//err = getaddrinfo(host, port, &hints, &info);
		err = getaddrinfo(NULL, port, &hints, &info);
		if(err != 0){
			fprintf(stderr, "getaddrinfo():%s\n", gai_strerror(err));
			return -1;
		}
	}

	err = getnameinfo(
			info->ai_addr,info->ai_addrlen,
			host_buf, sizeof(host_buf),
			serv_buf, sizeof(serv_buf),
			NI_NUMERICHOST | NI_NUMERICSERV);
	if(err != 0){
		fprintf(stderr, "getnameinfo():%s\n", gai_strerror(err));
		freeaddrinfo(info);
		return -1;
	}

	fprintf(stderr, "addr = %s, port = %s\n", host_buf, serv_buf);

	soc = socket(info->ai_family, info->ai_socktype, info->ai_protocol);
	if(soc == -1){
		perror("socket");
		freeaddrinfo(info);
		return -1;
	}

	opt = 1;
	opt_len = sizeof(opt);
	err = setsockopt(soc, SOL_SOCKET, SO_REUSEADDR, &opt, opt_len);
	if(err == -1){
		perror("setsockopt");
		close(soc);
		freeaddrinfo(info);
		return -1;
	}

	err = bind(soc, info->ai_addr, info->ai_addrlen);
	if(err == -1){
		perror("bind");
		close(soc);
		freeaddrinfo(info);
		return -1;
	}

	if(multicast_address){
		fprintf(stderr,"mutlcast_address is %s\n", multicast_address);
		/* join multicast group */
		inet_pton(AF_INET, multicast_address, &mreq.imr_multiaddr);
		inet_pton(AF_INET, host, &mreq.imr_interface);
		err = setsockopt(soc, IPPROTO_IP, IP_ADD_MEMBERSHIP,
				&mreq, sizeof(mreq));
		if(err == -1){
			fprintf(stderr, "ERROR : %s(%d)\n", __FILE__, __LINE__ );
			perror("setsockopt");
			close(soc);
			freeaddrinfo(info);
			return -1;
		}
	}
	
	freeaddrinfo(info);

	return soc;
}

int client_socket(const char *host, const char *port)
{
	int soc;

	int err;
	struct addrinfo *info;

	char host_buf[NI_MAXHOST];
	char serv_buf[NI_MAXSERV];

	int opt;
	socklen_t opt_len;

	{
		struct addrinfo hints;
		memset(&hints, 0, sizeof(hints));
		hints.ai_family = AF_INET;
		hints.ai_socktype = SOCK_STREAM;
		//hints.ai_flags = AI_PASSIVE;

		err = getaddrinfo(host, port, &hints, &info);
		if(err != 0){
			fprintf(stderr, "getaddrinfo():%s\n", gai_strerror(err));
			return -1;
		}
	}

	err = getnameinfo(
			info->ai_addr,info->ai_addrlen,
			host_buf, sizeof(host_buf),
			serv_buf, sizeof(serv_buf),
			NI_NUMERICHOST | NI_NUMERICSERV);
	if(err != 0){
		fprintf(stderr, "getnameinfo():%s\n", gai_strerror(err));
		freeaddrinfo(info);
		return -1;
	}

	fprintf(stderr, "addr = %s, port = %s\n", host_buf, serv_buf);

	soc = socket(info->ai_family, info->ai_socktype, info->ai_protocol);
	if(soc == -1){
		perror("socket");
		freeaddrinfo(info);
		return -1;
	}

	err = connect(soc, info->ai_addr, info->ai_addrlen);
	if(err == -1){
		perror("connect");
		close(soc);
		freeaddrinfo(info);
		return -1;
	}

	freeaddrinfo(info);

	return soc;
}


int sender_socket(const char *host, const char *port, 
				const char *multicast_address)
{
	int soc;

	int err;
	struct addrinfo *info;

	char host_buf[NI_MAXHOST];
	char serv_buf[NI_MAXSERV];

	int opt;
	socklen_t opt_len;

	unsigned char multicast_ttl = 64;
	unsigned char multicast_loopback = 1;

#if 0
	{
		struct addrinfo hints;
		memset(&hints, 0, sizeof(hints));
		hints.ai_family = AF_INET;
		//hints.ai_socktype = SOCK_STREAM;
		hints.ai_socktype = SOCK_DGRAM;

		err = getaddrinfo(host, port, &hints, &info);
		if(err != 0){
			fprintf(stderr, "getaddrinfo():%s\n", gai_strerror(err));
			return -1;
		}
	}
#endif

#if 0
	err = getnameinfo(
			info->ai_addr,info->ai_addrlen,
			host_buf, sizeof(host_buf),
			serv_buf, sizeof(serv_buf),
			NI_NUMERICHOST | NI_NUMERICSERV);
	if(err != 0){
		fprintf(stderr, "getnameinfo():%s\n", gai_strerror(err));
		freeaddrinfo(info);
		return -1;
	}

	fprintf(stderr, "%s : addr = %s, port = %s\n", __FUNCTION__, host_buf, serv_buf);
#endif

	//soc = socket(info->ai_family, info->ai_socktype, info->ai_protocol);
	soc = socket(PF_INET, SOCK_DGRAM, 0);
	if(soc == -1){
		perror("socket");
		freeaddrinfo(info);
		return -1;
	}

#if 0
	err = connect(soc, info->ai_addr, info->ai_addrlen);
	if(err == -1){
		perror("connect");
		close(soc);
		freeaddrinfo(info);
		return -1;
	}
#endif

	opt = 1;
	err = setsockopt(soc, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(int));
	if(err == -1){
		perror("setsockopt");
		return -1;
	}
	
	{
		struct addrinfo hints;
		memset(&hints, 0, sizeof(hints));
		hints.ai_family = AF_INET;
		//hints.ai_socktype = SOCK_STREAM;
		hints.ai_socktype = SOCK_DGRAM;

		err = getaddrinfo(host, port, &hints, &info);
		if(err != 0){
			fprintf(stderr, "getaddrinfo():%s\n", gai_strerror(err));
			return -1;
		}
	}

	err = bind(soc, (struct sockaddr *)info->ai_addr, info->ai_addrlen);
	if(err == -1){
		perror("bind");
		freeaddrinfo(info);
		close(soc);
		return -1;
	}


	/* multicast settings */
	err = setsockopt(soc, IPPROTO_IP, IP_MULTICAST_IF,
					&((struct sockaddr_in *)info->ai_addr)->sin_addr,
					sizeof(struct in_addr));
	if(err == -1){
		perror("setsockopt");
		freeaddrinfo(info);
		close(soc);
		return -1;
	}

	err = setsockopt(soc, IPPROTO_IP, IP_MULTICAST_TTL,
					&multicast_ttl, sizeof(multicast_ttl));
	if(err == -1){
		perror("setsockopt");
		freeaddrinfo(info);
		close(soc);
		return -1;
	}

	err = setsockopt(soc, IPPROTO_IP, IP_MULTICAST_LOOP,
					&multicast_loopback, sizeof(multicast_loopback));
	if(err == -1){
		perror("setsockopt");
		freeaddrinfo(info);
		close(soc);
		return -1;
	}
	
	freeaddrinfo(info);

	return soc;
}


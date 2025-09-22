#ifndef COMMON_H
#define COMMON_H

int get_sockaddr_info(const char *host, const char *port,
				struct sockaddr_storage *addr, socklen_t *addr_len);

int server_socket(const char *hostname, const char *port);
int client_socket(const char *hostname, const char *port);

int receiver_socket(const char *hostname, const char *port,
				const char *multicast_address);
int sender_socket(const char *hostname, const char *port,
				const char *multicast_address);


#endif /* #ifndef COMMON_H */



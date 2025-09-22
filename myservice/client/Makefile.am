bin_PROGRAMS = client

client_SOURCES = \
  recv_handler.c \
  client.c \
  common.c

client_CFLAGS =

client_LDADD = \
  -levent

test :
	./client --host localhost --port 1234




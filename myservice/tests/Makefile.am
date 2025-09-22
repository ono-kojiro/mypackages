PORT = 1234

start :
	$(top_builddir)/server/myserver -p $(PORT)

debug :
	$(top_builddir)/server/myserver -p $(PORT) -F

stop :
	-pkill myserver

test :
	$(top_builddir)/client/client --host localhost --port $(PORT)

cmd :
	$(top_builddir)/client/client --host localhost --port 9999


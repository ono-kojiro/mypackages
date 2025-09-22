PORT = 1234

start :
	$(top_builddir)/server/mydaemond -p 1234

debug :
	$(top_builddir)/server/mydaemond -p 1234 -F

stop :
	-pkill mydaemond

test :
	$(top_builddir)/client/client --host localhost --port $(PORT)

cmd :
	$(top_builddir)/client/client --host localhost --port 9999


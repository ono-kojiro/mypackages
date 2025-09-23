XZDIR   = /var/lib/pcapd
XZFILES = $(wildcard $(XZDIR)/*.pcap.xz)
CWD     = $(shell pwd)

all : test

generate: 
	./generate.py -o build.ninja -l /var/log/pcapd $(XZDIR)

test :
	sudo -u tcpdump cp -f packetbeat.yml /tmp/
	sudo -u tcpdump cp -f build.ninja /tmp/
	sudo -u tcpdump ninja -j 4 -C /var/log/pcapd/ -f /tmp/build.ninja

debug :
	sudo -u tcpdump sh pcap2ndjson.sh


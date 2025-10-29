#!/usr/bin/env python3

import sys
import os

import getopt
import json

import glob

def usage():
    print("Usage : {0}".format(sys.argv[0]))

def main():
    ret = 0

    try:
        opts, args = getopt.getopt(
            sys.argv[1:],
            "hvo:l:",
            [
                "help",
                "version",
                "output=",
                "logdir=",
            ]
        )
    except getopt.GetoptError as err:
        print(str(err))
        sys.exit(2)
	
    output = None
    logdir = None
	
    for o, a in opts:
        if o == "-v":
            usage()
            sys.exit(0)
        elif o in ("-h", "--help"):
            usage()
            sys.exit(0)
        elif o in ("-o", "--output"):
            output = a
        elif o in ("-l", "--logdir"):
            logdir = a
        else:
            assert False, "unknown option"
	
    if output is not None :
        fp = open(output, mode='w', encoding='utf-8')
    else :
        fp = sys.stdout

    if logdir is None :
        print('ERROR: no logdir option', file=sys.stderr)
        ret += 1

    if ret != 0:
        sys.exit(1)
    
    msg = '''
pb_opt  = --path.home=/var/log/pcapd/$${basename} $
        --path.config=/var/log/pcapd/$${basename} $
        --path.data=/var/log/pcapd/$${basename} $
        --path.logs=/var/log/pcapd/$${basename} $
        -E setup.dashboards.enabled=false $
        -E "output.file.path=/var/log/pcapd/$${basename}"

rule pcapxz2log
    command = $
      export basename=`basename -s .pcap.xz $in` $
      && export pcapfile=`echo $out | sed -e 's/\\.log/\\.pcap/'` $
      && mkdir -p `dirname $$pcapfile` $
      && xz -dcf -k $in > $$pcapfile $
      && packetbeat $
        -e $
        -c /tmp/packetbeat.yml $
        -I $$pcapfile $
        $pb_opt $
        -E "output.file.filename=$${basename}" $
        2>$out $
      && chmod 660 $out $
      && chmod 660 $${basename}/$${basename}-*.ndjson $
      && rm -f $$pcapfile
'''

    fp.write(msg + '\n')
    fp.write('\n')

    count = 0

    for dirpath in args:
        files = glob.glob("{0}/**/*.pcap.xz".format(dirpath), recursive=True)
        pcapxzs = sorted(files)

        for pcapxz in pcapxzs:
            basename = os.path.basename(pcapxz).split('.', 1)[0]
            logfile  = logdir + '/' + basename + '/' + basename + '.log'
            fp.write('build {0}: pcapxz2log {1}\n'.format(logfile, pcapxz))
            count = count + 1 
            #print('count is {0}'.format(count), file=sys.stderr)
            #if count > 4:
            #    break

    fp.write('\n')
    if output is not None :
        fp.close()
    print('INFO: generate {0} target'.format(count))

if __name__ == "__main__":
	main()

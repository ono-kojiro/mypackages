#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
#cd $top_dir

ret=0

input_top="/var/lib/pcapd"
output_top="/var/log/pcapd"
  
echo "DEBUG: input_top is $input_top" 1>&2
echo "DEBUG: output_top is $output_top" 1>&2

cd $output_top/

pcap2log()
{
  pcappath="$1"
  output_json="$2"
  echo "DEBUG: pcap2log()"

  basename=`basename -s .pcap $pcappath`

  mkdir -p $basename
  #cd $basename
  pwd
  echo "DEBUG: output_top is $output_top"
  dt_begin=`date "+%Y%m%d-%H%M%S.%3N"`
  echo "DEBUG: begin $dt_begin"
  packetbeat \
      -e \
      -c /var/log/pcapd/packetbeat.yml \
      -I $pcappath \
      --path.home=/var/log/pcapd/ \
      --path.config=/var/log/pcapd/ \
      --path.data=/var/log/pcapd/$basename \
      --path.logs=/var/log/pcapd/$basename \
      -E setup.dashboards.enabled=false \
      -E "output.file.path=/var/log/pcapd/$basename" \
      -E "output.file.filename=${basename}" \
      2>${basename}/packetbeat.log
  
  # "output.file.permissions" does not work
  # -E output.file.permissions=0600 \
  chmod 0660 ${basename}/*.ndjson
      
  dt_end=`date "+%Y%m%d-%H%M%S.%3N"`
  echo "DEBUG: end   $dt_end"
  #cd ..
  
  #packetbeat \
  #    --path.home=/var/log/pcapd/ \
  #    --path.config=/var/log/pcapd/ \
  #    --path.data=/var/log/pcapd/$basename \
  #    --path.logs=/var/log/pcapd/$basename \
  #    -e \
  #    -E "logging.files.path=$PWD" \
  #    -E "data.path=$PWD" \
  #    -E "path.home=$PWD" \
  #    -I $pcappath \
  #    -t 2>&1 >$output_json
  #    #-c /var/log/pcapd/packetbeat.yml \
}

pcapxz2pcap()
{
  pcapxz="$1"
  pcap="$2"

  if [ ! -e "$pcap" ] || [ "$pcapxz" -nt "$pcap" ]; then
    echo "INFO: extract pcap"
    basename=`basename -s .pcap $pcap`
    mkdir -p $basename
    xz -dcf -k $pcapxz > $pcap
  else
    echo "INFO: $pcap already exists, skip xz"
  fi
}

analyze()
{
  echo "DEBUG: analyze start" 1>&2
  pcapxzs=`find $input_top/ -type f -name "*.pcap.xz" | sort`

  #echo "DEBUG: pcapxzs is $pcapxzs" 1>&2
  for pcapxz in $pcapxzs; do
    basename=`basename -s .pcap.xz $pcapxz`
    pcapfile="${basename}.pcap"
    pcappath="$output_top/$basename/$pcapfile"
    meta_json="$output_top/$basename/meta.json"
    output_json="$output_top/$basename/${basename}.ndjson"

    echo "DEBUG: pcapxz is $pcapxz"
    echo "DEBUG: basename is $basename"

    if [ ! -e "$meta_json" ]; then
      pcapxz2pcap $pcapxz $pcappath
      pcap2log $pcappath $output_json
      #rm -f $pcappath
      break
    else
      echo "INFO: $meta_json is existing. skip pcap2log"
    fi
  done
}

help()
{
  usage
}

usage()
{
  cat << EOS
usage : $0 [options]
EOS

}

all()
{
  analyze
}

args=""
while [ $# -ne 0 ]; do
  case $1 in
    -h )
      usage
      exit 1
      ;;
    -v )
      verbose=1
      ;;
    * )
      args="$args $1"
      ;;
  esac
  
  shift
done

if [ -z "$args" ]; then
  #usage
  #exit 1
  args="analyze"
fi

for arg in $args; do
  num=`LANG=C type $arg 2>&1 | grep 'function' | wc -l`
  if [ $num -ne 0 ]; then
    $arg
  else
    #echo "ERROR : $arg is not shell function"
    #exit 1
    default $arg
  fi
done



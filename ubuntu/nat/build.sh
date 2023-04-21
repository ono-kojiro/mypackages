#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

# https://ytsuboi.jp/archives/642
# https://faq.interlink.or.jp/faq2/View/wcDisplayContent.aspx?id=761

#                                                   +-------------+
#                                       +-----------+ client PC   |
#                                       |           +-------------+
#         +------------------+          |
#         |       NAT        |      +--------+      +-------------+
# net ----| wlan0       eth0 |------| switch |------| client PC   |
#         |                  |      +--------+      +-------------+
#         +------------------+          |
#                                       |           +-------------+
#                                       +-----------+ client PC   |
#                                                   +-------------+
#     
#  wlan0 : 192.168.0.98
#  eth0  : 192.168.10.1 (DNS)
#

dest="wlan0"
src="192.168.10.0/24"  # eth0

help()
{
  usage
}

usage()
{
  cat << EOS
usage : $0 [options] target1 target2 ...

target:
  enable_nat
  show_rules
EOS

}

all()
{
  usage
}

list()
{
  nmcli con show
}

enable_nat()
{
  sudo iptables -t nat -A POSTROUTING -s $src -o $dest -j MASQUERADE
}

show_rules()
{
  sudo iptables -t nat --line-numbers -L POSTROUTING
}

disable_nat()
{
  sudo iptables -t nat --line-numbers -L POSTROUTING | \
    gawk '{ print $1, $5 }' | grep "$src" | tee rules.log

  num=`cat rules.log | wc -l`
  if [ "$num" -eq 1 ]; then
    echo rule found
    num=`cat rules.log | gawk '{ print $1 }'`
    cmd="iptables -t nat --delete POSTROUTING $num"
    echo $cmd
    sudo $cmd
  else
    echo "SKIP : rule NOT found"
  fi
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
  help
  exit 1
fi

for arg in $args; do
  num=`LANG=C type $arg | grep 'function' | wc -l`
  if [ $num -ne 0 ]; then
    $arg
  else
    echo "ERROR : $arg is not shell function"
    exit 1
  fi
done


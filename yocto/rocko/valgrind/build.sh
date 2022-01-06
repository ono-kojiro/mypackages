#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

remote="192.168.7.2"

help()
{
    usage
}

usage()
{
	echo "usage : $0 [options] target1 target2 ..."
    echo "  target"
    echo "    test"
	exit 0
}

all()
{
  cat - << 'EOS' | ssh -y $remote sh -s --
{
  clock_gettime
  valgrind --tool=callgrind clock_gettime
  
  clock_gettime
  valgrind --tool=callgrind lxc-execute -n mylxc -- clock_gettime
}
EOS

}
        
while [ "$#" -ne 0 ]; do
  case "$1" in
    -h | --help)
      ;;
	-v | --version)
	  ;;
	*)
	  break
	  ;;
  esac
  shift
done


if [ $# -eq 0 ]; then
  all
fi

for target in "$@" ; do
	LANG=C type $target | grep function > /dev/null 2>&1
	if [ "$?" -eq 0 ]; then
		$target
	else
	    echo "ERROR : $target is not a shell function"
	fi
done


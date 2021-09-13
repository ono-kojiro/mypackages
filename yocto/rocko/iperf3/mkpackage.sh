#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  iperf-3.7.spec


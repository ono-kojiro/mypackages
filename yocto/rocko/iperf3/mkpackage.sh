#!/bin/sh

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="_build x86_64-linux-gnu" \
  iperf-3.7.spec


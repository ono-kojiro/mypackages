#!/bin/sh

sudo sh ./install_packages.sh

if [ ! -e "get-pip.py" ]; then
  wget https://bootstrap.pypa.io/pip/3.6/get-pip.py
fi

python3 get-pip.py

python3 -m pip install -r requirements.txt



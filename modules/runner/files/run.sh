#!/bin/bash

cd $(dirname $0)

connect=$(sudo -u postgres /usr/local/bin/init_db.sh $1|grep connect|sed -e "s/connect: *//")

./clone $1
./monitor_process $1 "$connect"



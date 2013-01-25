#!/bin/bash

echo "project run $1">>/tmp/runer_log.txt

if [ "$1" == "" ]; then
  echo "invalid project name"
  exit
fi

cd $(dirname $0)

mkdir -p dbs
if [ -e dbs/$1 ]; then
  connect=$(cat dbs/$1)
else
  connect=$(sudo -u postgres /usr/local/bin/init_db.sh $1|grep connect|sed -e "s/connect: *//")
  echo $connect>dbs/$1
fi

./clone.sh $1
./monitor_process.sh $1 "$connect"



#!/bin/bash

if [ "$1" == "" ]; then
  echo "invalid project name"
  exit 1
fi

echo "project: $1"

echo "generate pw.."
pw=$(dd if=/dev/urandom of=/dev/stdout count=16 bs=16 2>/dev/null |md5sum|awk '{print $1}')

#echo "creating user.."

echo "create user..."
echo "create user $1 with password '$pw';"|psql


#echo -e "$pw\n$pw\n"|createuser -P -c 2 $1
echo "create db.."
createdb -O $1 $1

#echo "create user..."
#echo "create user $1 with password '$pw';"|psql
echo "grant access..."
echo "grant all privileges on database $1 to $1;"|psql


host=$(hostname -a)
echo "connect: postgres://$1:$pw@$host/$1"

#!/bin/bash

echo "very simple version"

freeport=9494

cd $(dirname $0)

mkdir -p fifos

test -e fifos/$1_out || mkfifo fifos/$1_out
test -e fifos/$1_err || mkfifo fifos/$1_err

cd tmp/$1
rackup -p $freeport

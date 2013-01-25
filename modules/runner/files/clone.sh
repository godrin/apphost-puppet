#!/bin/bash
cd $(dirname $0)
mkdir -p tmp
cd tmp
rm -rf $1
git clone git@localhost:$1

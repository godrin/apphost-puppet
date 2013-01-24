#!/bin/bash
cd $(dirname $0)
mkdir -p tmp
cd tmp
git clone git@localhost:$1

#!/bin/bash

export HOME=/home/gadmin
cd

. .profile

if [ "$(whoami)" == "gadmin" ] ; then
  echo "ok - correct user"
else
  echo "wrong user !" 
  exit 1
fi
cd ~/repo
cp ~/.ssh/id_dsa.pub keydir/gadmin.pub
grep gadmin conf/gitolite.conf
found=$?
if [ "$found" != "0" ] ; then
  echo "">>conf/gitolite.conf

  echo "repo    gitolite-admin">>conf/gitolite.conf
  echo "        RW+     =   gadmin">>conf/gitolite.conf
fi

rm keydir/admin.pub
git add keydir/gadmin.pub
git commit -a -m "secondary key"
git push origin master

exit $?

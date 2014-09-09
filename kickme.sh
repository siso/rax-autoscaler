#!/usr/bin/env sh

echo "Alive'n'kickin'" > /kicked.txt

yum -y install python-pip

/usr/bin/yes | pip install pyrax

exit 0

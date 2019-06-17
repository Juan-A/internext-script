#!/bin/bash
if [ ! -x /usr/local/internext/scripts-local.sh ]
then
mkdir -p /usr/local/internext/
curl -O https://raw.githubusercontent.com/Juan-A/internext-script/master/scripts-local.sh
mv scripts-local.sh /usr/local/internext/scripts-local.sh
chmod +x /usr/local/internext/scripts-local.sh
./usr/local/internext/scripts-local.sh


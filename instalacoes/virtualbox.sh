#!/bin/bash

#Fontes das dependencias:
# https://www.virtualbox.org/manual/ch02.html#idp50290576

echo "instalando o Virtual Box..."

sudo apt-get install dkms libsdl1.2debian

wget "http://download.virtualbox.org/virtualbox/4.3.16/virtualbox-4.3_4.3.16-95972~Ubuntu~raring_amd64.deb"

sudo dpkg -i virtualbox-4.3_4.3.16-95972~Ubuntu~raring_amd64.deb

rm virtualbox-4.3_4.3.16-95972~Ubuntu~raring_amd64.deb

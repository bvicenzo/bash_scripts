#!/bin/bash

echo "instalando o Skype..."
sudo apt-get install sni-qt:i386
sudo apt-get install -f libqt4-webkit:i386 libxss1:i386 libxv1:i386

wget "http://download.skype.com/linux/skype-ubuntu-lucid_4.3.0.37-1_i386.deb"
sudo dpkg -i -E skype-ubuntu-lucid_4.3.0.37-1_i386.deb
rm skype-ubuntu-lucid_4.3.0.37-1_i386.deb

echo "Feito"

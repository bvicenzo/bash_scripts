#!/bin/bash

echo "instalando outras dependencias..."

echo "instalando o Tmux..."
sudo apt-get install tmux

echo "instalando xvfb para funcionamento correto do Cucumber..."
sudo apt-get install xvfb -y

echo "Instalando dependencias do nokogiri..."
sudo apt-get install libxslt-dev libxml2-dev

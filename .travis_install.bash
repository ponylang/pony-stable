#! /bin/bash

set -o errexit
set -o nounset

install_ponyc(){
  echo -e "\033[0;32mInstalling latest ponyc release\033[0m"
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "D401AB61 DBE1D0A2"
  echo "deb https://dl.bintray.com/pony-language/ponyc-debian pony-language main" | sudo tee -a /etc/apt/sources.list
  sudo apt-get update
  sudo apt-get -V install ponyc
}

install_ponyc

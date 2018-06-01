#! /bin/bash

set -o errexit
set -o nounset

install_ponyc(){
  echo -e "\033[0;32mInstalling latest ponyc release\033[0m"
  sudo add-apt-repository ppa:ponylang/ponylang -y
  sudo apt-get update
  sudo apt-get -V install ponyc -y
}

install_ponyc

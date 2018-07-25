#! /bin/bash

set -o errexit
set -o nounset

install_ponyc(){
  echo -e "\033[0;32mInstalling latest ponyc release\033[0m"
  sudo add-apt-repository ppa:ponylang/ponylang -y
  sudo apt-get update
  # NOTE: libpcre2-dev is specified because otherwise
  # apt refuses to install it and everything fails
  sudo apt-get -V install ponyc libpcre2-dev -y
}

install_ponyc

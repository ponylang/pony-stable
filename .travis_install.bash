#! /bin/bash

set -o errexit
set -o nounset

install_ponyc(){
  echo -e "\033[0;32mInstalling latest ponyc release\033[0m"
  sudo add-apt-repository ppa:ponylang/ponylang -y
  sudo apt-get update
  # NOTE: libpcre2-dev is specified because otherwise
  # apt refuses to install it and everything fails
  sudo apt-get -V install ponyc libpcre2-dev -y --allow-unauthenticated
}

case "${TRAVIS_OS_NAME}" in
  "linux")
    install_ponyc
  ;;

  "osx")
    brew update
    brew install ponyc
  ;;

  *)
    echo "ERROR: An unrecognized OS. Consider OS: ${TRAVIS_OS_NAME}."
    exit 1
  ;;

esac

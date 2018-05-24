#! /bin/bash

set -o errexit
set -o nounset

pony-stable-build-packages(){
  echo "Installing ruby, rpm, and fpm..."
  rvm use 2.2.3 --default
  sudo apt-get install -y rpm
  gem install fpm

  # The PACKAGE_ITERATION will be fed to the DEB and RPM systems by FPM
  # as a suffix to the base version (DEB:debian_revision or RPM:release,
  # used to disambiguate packages with the same version).
  PACKAGE_ITERATION="${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short --verify 'HEAD^{commit}')"

  echo "Building ponyc packages for deployment..."
  make arch=x86-64 package_name="pony-stable" package_base_version="$(cat VERSION)" package_iteration="${PACKAGE_ITERATION}" deploy
}

if [[ "$TRAVIS_BRANCH" == "release" && "$TRAVIS_PULL_REQUEST" == "false" ]]
then
  pony-stable-build-packages
fi

#! /bin/bash

set -o errexit
set -o nounset

build_deb(){
  deb_distro=$1

  # untar source code
  tar -xvzf "pony-stable_${package_version}.orig.tar.gz"

  pushd "pony-stable-${package_version}"

  cp -r .packaging/deb debian
  cp LICENSE debian/copyright

  # create changelog
  rm -f debian/changelog
  dch --package pony-stable -v "${package_version}" -D "${deb_distro}" --force-distribution --controlmaint --create "Release ${package_version}"

  # create package for distro using docker to run debuild
  sudo docker run -v "$(pwd)/..:/home/pony" --rm --user root "ponylang/ponyc-ci:${deb_distro}-deb-builder" sh -c 'cd pony-stable* && mk-build-deps -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" -i -r && debuild -b -us -uc'

  ls -l ..

  # restore original working directory
  popd

  # create bintray upload json file
  bash .bintray_deb.bash "$package_version" "$deb_distro"

  # rename package to avoid clashing across different distros packages
  mv "pony-stable_${package_version}_amd64.deb" "pony-stable_${package_version}_${deb_distro}_amd64.deb"

  # clean up old build directory to ensure things are all clean
  sudo rm -rf "pony-stable-${package_version}"
}

pony-stable-build-debs(){
  package_version=$1

  set -x

  echo "Install devscripts..."
  sudo apt-get update
  sudo apt-get install -y devscripts

  echo "Building pony-stable debs for bintray..."
  wget "https://github.com/ponylang/pony-stable/archive/${package_version}.tar.gz" -O "pony-stable_${package_version}.orig.tar.gz"

  build_deb xenial
  build_deb artful
  build_deb bionic
  build_deb trusty
  build_deb buster
  build_deb stretch
  build_deb jessie

  ls -la
  set +x
}

build_and_submit_deb_src(){
  deb_distro=$1
  rm -f debian/changelog
  dch --package pony-stable -v "${package_version}-0ppa1~${deb_distro}" -D "${deb_distro}" --controlmaint --create "Release ${package_version}"
  debuild -S
  dput custom-ppa "../pony-stable_${package_version}-0ppa1~${deb_distro}_source.changes"
}

pony-stable-kickoff-copr-ppa(){
  package_version=$(cat VERSION)

  echo "Install debuild, dch, dput..."
  sudo apt-get install -y devscripts build-essential lintian debhelper python-paramiko

  echo "Decrypting and Importing gpg keys..."
  # Disable shellcheck error SC2154 for uninitialized variables as these get set by travis-ci for us.
  # See the following for error details: https://github.com/koalaman/shellcheck/wiki/SC2154
  # shellcheck disable=SC2154
  openssl aes-256-cbc -K "$encrypted_8da6a6ec0f12_key" -iv "$encrypted_8da6a6ec0f12_iv" -in .securefiles.tar.enc -out .securefiles.tar -d
  tar -xvf .securefiles.tar
  gpg --import ponylang-secret-gpg.key
  gpg --import-ownertrust ponylang-ownertrust-gpg.txt
  mv sshkey ~/sshkey
  sudo chmod 600 ~/sshkey

  echo "Kicking off pony-stable packaging for PPA..."
  wget "https://github.com/ponylang/pony-stable/archive/${package_version}.tar.gz" -O "pony-stable_${package_version}.orig.tar.gz"
  tar -xvzf "pony-stable_${package_version}.orig.tar.gz"
  pushd "pony-stable-${package_version}"
  cp -r .packaging/deb debian
  cp LICENSE debian/copyright

  # ssh stuff for launchpad as a workaround for https://github.com/travis-ci/travis-ci/issues/9391
  {
    echo "[custom-ppa]"
    echo "fqdn = ppa.launchpad.net"
    echo "method = sftp"
    echo "incoming = ~ponylang/ubuntu/ponylang/"
    echo "login = ponylang"
    echo "allow_unsigned_uploads = 0"
  } >> ~/.dput.cf

  mkdir -p ~/.ssh
  {
    echo "Host ppa.launchpad.net"
    echo "    StrictHostKeyChecking no"
    echo "    IdentityFile ~/sshkey"
  } >> ~/.ssh/config
  sudo chmod 400 ~/.ssh/config

  build_and_submit_deb_src xenial
  build_and_submit_deb_src artful
  build_and_submit_deb_src bionic
  build_and_submit_deb_src cosmic
  build_and_submit_deb_src trusty

  # COPR for fedora/centos/suse
  echo "Kicking off pony-stable packaging for COPR..."
  docker run -it --rm -e COPR_LOGIN="${COPR_LOGIN}" -e COPR_USERNAME=ponylang -e COPR_TOKEN="${COPR_TOKEN}" -e COPR_COPR_URL=https://copr.fedorainfracloud.org mgruener/copr-cli buildscm --clone-url https://github.com/ponylang/pony-stable --commit "${package_version}" --subdir /.packaging/rpm/ --spec pony-stable.spec --type git --nowait ponylang

  # restore original working directory
  popd
}

pony-stable-build-packages(){
  echo "Installing ruby, rpm, and fpm..."
  rvm use 2.2.3 --default
  sudo apt-get install -y rpm
  gem install fpm

  # The PACKAGE_ITERATION will be fed to the DEB and RPM systems by FPM
  # as a suffix to the base version (DEB:debian_revision or RPM:release,
  # used to disambiguate packages with the same version).
  PACKAGE_ITERATION="${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short --verify 'HEAD^{commit}')"

  echo "Building pony-stable packages for deployment..."
  make arch=x86-64 package_name="pony-stable" package_base_version="$(cat VERSION)" package_iteration="${PACKAGE_ITERATION}" deploy
}

if [[ "$TRAVIS_BRANCH" == "release" && "$TRAVIS_PULL_REQUEST" == "false" ]]
then
  pony-stable-build-debs "$(cat VERSION)"
  pony-stable-kickoff-copr-ppa
  pony-stable-build-packages
fi

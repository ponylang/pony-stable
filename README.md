# pony-stable

A simple dependency manager for the [Pony language](http://www.ponylang.io/).

Too many ponies to keep track of?

Put them in a stable and make your life easier.

<a href="https://openclipart.org/detail/11509/rpg-map-symbols-stables"><img src="https://openclipart.org/download/11509/nicubunu-RPG-map-symbols-Stables.svg" width="400px" /></a>

## Status

[![Actions Status](https://github.com/ponylang/pony-stable/workflows/vs-ponyc-latest/badge.svg)](https://github.com/ponylang/pony-stable/actions)

Production ready.

## Installation

### Debian and Ubuntu Linux using a DEB package (via Bintray)

For Debian and Ubuntu versions of Linux, the `release` builds are packaged and available on Bintray ([pony-language/ponyc-debian](https://bintray.com/pony-language/ponyc-debian)).

To install builds via Apt (and install Bintray's public key):

```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D401AB61 DBE1D0A2
echo "deb https://dl.bintray.com/pony-language/pony-stable-debian /" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get -V install pony-stable
```

### macOS

```bash
brew install pony-stable
```

### Linux using an RPM package (via COPR)

For Red Hat, CentOS, Oracle Linux, Fedora Linux, or openSUSE, the `release` builds are packaged and available on COPR ([ponylang/ponylang](https://copr.fedorainfracloud.org/coprs/ponylang/ponylang/)).

#### Using `yum` for Red Hat, CentOS, Oracle Linux and other RHEL compatible systems:

```bash
yum copr enable ponylang/ponylang epel-7
yum install pony-stable
```

See https://bugzilla.redhat.com/show_bug.cgi?id=1581675 for why `epel-7` is required on the command line.

#### Using `DNF` for Fedora Linux:

```bash
dnf copr enable ponylang/ponylang
dnf install pony-stable
```

#### Using Zypper for openSUSE Leap 15:

```bash
zypper addrepo --refresh --repo https://copr.fedorainfracloud.org/coprs/ponylang/ponylang/repo/opensuse-leap-15.0/ponylang-ponylang-opensuse-leap-15.0.repo
wget https://copr-be.cloud.fedoraproject.org/results/ponylang/ponylang/pubkey.gpg
rpm --import pubkey.gpg
zypper install pony-stable
```

### Arch Linux

```bash
pacman -S pony-stable
```

### From Source

You will need `ponyc` in your PATH.

#### From Source (Unix):

```bash
git clone https://github.com/ponylang/pony-stable
cd pony-stable
make
sudo make install
```

#### From Source (Windows):

```batchfile
git clone https://github.com/ponylang/pony-stable
cd pony-stable
make.bat
```

You will then need to add `pony-stable\bin` to your `PATH`.

## Make a project with dependencies.

### GitHub

```bash
mkdir myproject && cd myproject

stable add github jemc/pony-inspect

echo '
use "inspect"
actor Main
  new create(env: Env) =>
    env.out.print(Inspect("Hello, World!"))
' > main.pony
```

### GitLab

```bash
mkdir myproject && cd myproject

stable add gitlab jemc/pony-inspect

echo '
use "inspect"
actor Main
  new create(env: Env) =>
    env.out.print(Inspect("Hello, World!"))
' > main.pony
```

### Local git project

```bash
mkdir myproject && cd myproject

stable add local-git ../pony-inspect --tag=1.0.2

echo '
use "inspect"
actor Main
  new create(env: Env) =>
    env.out.print(Inspect("Hello, World!"))
' > main.pony
```

The git tag is optional.

### Local (non-git) project

```bash
mkdir myproject && cd myproject

stable add local ../pony-inspect

echo '
use "inspect"
actor Main
  new create(env: Env) =>
    env.out.print(Inspect("Hello, World!"))
' > main.pony
```

## Fetch dependencies.

```bash
stable fetch
# The dependencies listed in `bundle.json` will be fetched
# and/or updated into the local `.deps` directory.
```
```
Cloning into '.deps/jemc/pony-inspect'...
remote: Counting objects: 131, done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 131 (delta 4), reused 0 (delta 0), pack-reused 123
Receiving objects: 100% (131/131), 21.73 KiB | 0 bytes/s, done.
Resolving deltas: 100% (82/82), done.
Checking connectivity... done.
```

## Compile in a stable environment.

```bash
stable env ponyc --debug
# The local paths to the dependencies listed in `bundle.json`
# will be included in the `PONYPATH` environment variable,
# available to `use` in the `ponyc` invocation.
# You can run any custom command here - not just `ponyc`.
```
```
Building builtin -> /usr/local/lib/pony/0.2.1-204-g87fcb40/packages/builtin
Building . -> /home/jemc/1/code/hg/myproject
Building inspect -> /home/jemc/1/code/hg/myproject/.deps/jemc/pony-inspect/inspect
Generating
Writing ./myproject.o
Linking ./myproject
```

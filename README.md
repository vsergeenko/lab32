* https://github.com/karelzak/util-linux

./autogen
./configure
make

./dmesg -V
dmesg from util-linux 2.27.125-28a2d

![dmesg color](https://github.com/vsergeenko/lab32/blob/master/screenshot1.jpg)

* http://packages.ubuntu.com/xenial/util-linux
sudo apt-get install devscripts

dget http://archive.ubuntu.com/ubuntu/pool/main/u/util-linux/util-linux_2.27.1-1ubuntu3.dsc

dpkg-source -x util-linux_2.27.1-1ubuntu3.dsc

sudo apt-get install autoconf automake autopoint debhelper dh-autoreconf dh-exec 
dh-systemd dpkg-dev gettext libncurses5-dev libncursesw5-dev 
libpam0g-dev libselinux1-dev libsystemd-dev libtool libudev-dev 
lsb-release pkg-config po-debconf systemd zlib1g-dev

Package systemd is not available, but is referred to by another package. This may mean that 
the package is missing, has been obsoleted, or is only available from 
another source
E: Unable to locate package dh-systemd
E: Unable to locate package libsystemd-dev
E: Package 'systemd' has no installation candidate

dpkg-buildpackage -rfakeroot
dpkg-buildpackage: source package util-linux
dpkg-buildpackage: source version 2.27.1-1ubuntu3
dpkg-buildpackage: source changed by Matthias Klose <doko@ubuntu.com>
dpkg-buildpackage: host architecture amd64 dpkg-source --before-build 
util-linux-2.27.1
dpkg-source: warning: can't parse dependency libpam0g-dev <!stage1> dpkg-source: error: error occurred while parsing 
Build-Depends
dpkg-buildpackage: error: dpkg-source --before-build util-linux-2.27.1 gave error exit status 255



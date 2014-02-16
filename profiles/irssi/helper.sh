#!/bin/sh

set -e

version=0.8.16-rc1

echo Downloading irssi-$version.tar.gz...
pushd /tmp/cygmake/src > /dev/null
curl -sLO http://irssi.org/files/irssi-0.8.16-rc1.tar.gz
popd > /dev/null

echo Extracting irssi-$version.tar.gz...
tar xf /tmp/cygmake/src/irssi-$version.tar.gz -C /tmp/cygmake/build

# strange symptom that intermittently appears for reasons yet unknown:
# make[4]: g++-4: Command not found
# Makefile:499: recipe for target 'blib/arch/auto/Irssi/Irssi.dll' failed

# disgusting hack to work around that:
# echo Creating g++-4 symlink to fix Makefile bug...
# ln -s "`which g++`" "`which g++`-4"

echo Hack: working around missing Irssi.dll error...
mv /usr/bin/chmod /usr/bin/chmod.real
echo '#!/bin/sh' >> /usr/bin/chmod
echo 'chmod.real "$@"' >> /usr/bin/chmod
echo 'exit 0' >> /usr/bin/chmod
chmod.real +x /usr/bin/chmod

# --with-bot results in hundreds of undefined reference errors
# --with-gc results in silent exit
# --enable-dane doesn't work because dnssec-tools is broken on Windows
# --with-socks doesn't work because I can't find whatever libsocks is

echo Compiling irssi...
pushd /tmp/cygmake/build/irssi-$version > /dev/null
CFLAGS=-DUSEIMPORTLIB ./configure \
	--prefix=/tmp/cygmake/install/irssi \
	--with-proxy \
	--with-perl-staticlib \
	--without-socks \
	--without-bot \
	--without-gc \
	--disable-dane \
	> /tmp/cygmake/logs/010-configure.log 2>&1
make -j8 > /tmp/cygmake/logs/011-make.log 2>&1
make install > /tmp/cygmake/logs/012-install.log 2>&1
popd > /dev/null

echo Rolling in required libraries and binaries...
pushd /tmp/cygmake/install/irssi > /dev/null
ldd bin/irssi | \
	egrep -v 'cygdrive|\?\?\?' | \
	tr -d '\t' | \
	cut -d ' ' -f 3 | \
	xargs -I ! cp ! bin
mkdir -p usr/share
cp -r /usr/share/terminfo usr/share
cp -r /lib/perl5/5.* lib/perl5
cp /usr/bin/mintty bin
popd > /dev/null

echo Preparing the installer by copying cygpath.exe...
cp /usr/bin/cygpath /tmp/cygmake/install/installer/bin

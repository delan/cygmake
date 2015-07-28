#!/bin/sh

set -e

version=0.8.16-rc1

echo Downloading irssi-$version.tar.gz...
pushd /tmp/cygmake/src > /dev/null
curl -sLO http://irssi.org/files/irssi-$version.tar.gz
popd > /dev/null

echo Extracting irssi-$version.tar.gz...
tar xf /tmp/cygmake/src/irssi-$version.tar.gz -C /tmp/cygmake/build

echo Hack: working around missing Irssi.dll error...
mv /usr/bin/chmod /usr/bin/chmod.real
echo '#!/bin/sh' >> /usr/bin/chmod
echo 'chmod.real "$@"' >> /usr/bin/chmod
echo 'exit 0' >> /usr/bin/chmod
chmod.real +x /usr/bin/chmod

echo Configuring Irssi...
pushd /tmp/cygmake/build/irssi-$version > /dev/null
CFLAGS=-DUSEIMPORTLIB ./configure \
	--prefix=/tmp/cygmake/install/irssi \
	--with-textui --with-terminfo \
	--without-bot \
	--with-proxy \
	--with-modules \
	--with-perl-staticlib \
	--enable-ipv6 \
	--enable-ssl \
	--enable-largefile \
	--without-gc \
	--disable-dane \
	> /tmp/cygmake/logs/010-configure.log 2>&1
popd > /dev/null

echo Compiling Irssi...
pushd /tmp/cygmake/build/irssi-$version > /dev/null
make -j8 > /tmp/cygmake/logs/011-make.log 2>&1
popd > /dev/null

echo Hack for x86: fix syntax errors in some Makefiles
pushd /tmp/cygmake/build/irssi-$version/src/perl > /dev/null
for i in common irc textui ui; do
	sed -i -r 's^dll /bin/rebase^dll | /bin/rebase^' $i/Makefile
done
popd > /dev/null

echo Installing Irssi to a temporary directory...
pushd /tmp/cygmake/build/irssi-$version > /dev/null
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
cp /usr/bin/cygpath bin
popd > /dev/null

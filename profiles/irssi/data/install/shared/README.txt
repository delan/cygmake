Irssi 0.8.16-rc1 for Windows
============================



This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.



Introduction
------------

Thank you for using irssi-win32-0.8.16-rc1.

Included in this release:

  * mintty 1.1.3
  * Irssi proxy (--with-proxy)
  * Perl scripting support (--with-perl-staticlib)

Not included in this release:

  * Irssi bot (--with-bot): linking fails with undefined reference errors.
  * SOCKS proxy support (--with-socks): can't locate appropriate libsocks.
  * Garbage collector (--with-gc): Irssi silently exits or segfaults when run.
  * DANE (--enable-dane): libval does not support Windows and fails to compile.



Important usage information
---------------------------

To ensure that /help works properly, run the following Irssi commands:

	/set help_path ../../share/irssi/help
	/save

You only have to run these commands once after starting from a fresh or default
Irssi configuration.

Note that you currently cannot quit Irssi by clicking the mintty window's "X"
button. This is because mintty sends the SIGHUP signal when the "X" is clicked,
and Irssi reloads its configuration when it receives SIGHUP (this is as
designed). Instead, please quit Irssi by using its built-in /quit command.

To reference Windows paths from within Irssi, for instance when using DCC, use
the Unix-style path convention provided by Cygwin:

	/cygdrive/<lowercase drive letter>/path/to/file



Automatic build instructions
----------------------------

1. Download and install NSIS from http://nsis.sourceforge.net/
2. Download cygmake from https://github.com/delan/cygmake
3. In a Windows command prompt, run:

	cygmake -profile irssi

The generated installer can be found in:

	%TEMP%\cygmake\<number>\root\tmp\cygmake\install



Manual build instructions
-------------------------

1. Download the Cygwin installer for x86 from http://cygwin.com/setup-x86.exe
2. Install Cygwin, along with the following packages:

	gcc-core
	gcc-g++
	gettext
	gettext-devel
	libncurses-devel
	make
	pkg-config
	zlib-devel
	perl
	libglib2.0_0
	libglib2.0-devel
	libopenssl098
	openssl-devel

3. Download the Irssi source code from http://irssi.org and save it to
   C:\cygwin\home\<username>

4. Open a Cygwin terminal, and run the following commands:

	tar xf irssi-*.tar.gz
	cd irssi-*

	# If you want Perl support:
	CFLAGS=-DUSEIMPORTLIB ./configure --prefix=/cygdrive/c/irssi \
		--with-proxy --with-perl-staticlib

	# If you don't want Perl support:
	CFLAGS=-DUSEIMPORTLIB ./configure --prefix=/cygdrive/c/irssi \
		--with-proxy --with-perl=no

	make
	make install

5. You may encounter an error during 'make install' where chmod Irssi.dll fails
   because it doesn't exist. Work around this by typing the following commands:

	mv /usr/bin/chmod /usr/bin/chmod.real
	echo '#!/bin/sh' >> /usr/bin/chmod
	echo 'chmod.real "$@"' >> /usr/bin/chmod
	echo 'exit 0' >> /usr/bin/chmod
	chmod.real +x /usr/bin/chmod
	make install

6. Now you can start Irssi from a Cygwin terminal with:

	/cygdrive/c/irssi/bin/irssi



Preparing a manual build for distribution
-----------------------------------------

1. In a Cygwin terminal, change directories into your Irssi installation:

	cd /cygdrive/c/irssi

2. Copy the Cygwin DLLs that are necessary for Irssi to run:

	ldd bin/irssi | \
		egrep -v 'cygdrive|\?\?\?' | \
		tr -d '\t' | \
		cut -d ' ' -f 3 | \
		xargs -I ! cp -v ! bin

3. Copy /usr/share/terminfo from your Cygwin installation to the irssi
   root, such that the Irssi directory contains its own usr\share\terminfo:

	mkdir -pv usr/share
	cp -rv /usr/share/terminfo usr/share

4. If you opted for Perl support, merge the contents of /lib/perl5/5.14 from
   your Cygwin installation into the corresponding directory in your Irssi
   directory tree (irssi/lib/perl5/5.14):

	cp -rv /lib/perl5/5.* lib/perl5

5. Copy mintty to the bin subdirectory of the Irssi installation:

	cp -v /usr/bin/mintty bin



Credits
-------

This package is a modified, updated version of the irssi-win32-0.8.15 package
assembled by Josh Dick, which is itself based on Nei's irssi-win32-0.8.10:

http://anti.teamidiot.de/nei/2007/01/irssi_0810_for_windows_cygwinw/

This README is similarly based on documentation written by Josh Dick and Nei:

http://svn.irssi.org/repos/contrib/w32installer/shared/README.txt

The irssi binary included in this package was compiled under Cygwin and
assembled by Delan Azabani. The NSIS installer script for this package was
created by Sebastian Pipping and Josh Dick.

This package was made possible by:

  * The Irssi team <http://www.irssi.org/>
  * #irssi at IRCnet <irc://open.ircnet.net/#irssi>
  * Cygwin <http://www.cygwin.com>
  * NSIS <http://nsis.sourceforge.net>
  * Nei <http://anti.teamidiot.de/nei/2007/01/irssi_0810_for_windows_cygwinw/>

Enjoy!



- Josh Dick <josh@joshdick.net>
- Sebastian Pipping <webmaster@hartwork.org>
- Delan Azabani <delan@azabani.com>

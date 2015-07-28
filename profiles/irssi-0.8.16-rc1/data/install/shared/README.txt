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

  * mintty and the Irssi text UI
  * Irssi proxy
  * Support for modules and Perl scripting
  * Support for IPv6, SSL, and large files

Not included in this release:

  * Irssi bot: linking fails with undefined reference errors
  * Garbage collector: Irssi silently exits or segfaults when run
  * DANE: libval does not support Windows and fails to compile



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



Build instructions
------------------

1. Download and install NSIS from http://nsis.sourceforge.net/
2. Download cygmake from https://github.com/delan/cygmake
3. Change the line endings of helper.sh to LF characters only
4. In a Windows command prompt, run:

	cygmake -profile irssi-0.8.16-rc1

The generated installer can be found in:

	%TEMP%\cygmake\<number>\root\tmp\cygmake\install



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

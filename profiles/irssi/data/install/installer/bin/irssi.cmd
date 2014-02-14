SET LANG=C
SET PERL5LIB=lib/perl5/5.14
SET PERLLIB=lib/perl5/5.14

:: Determine the correct location for IRSSI_HOME
FOR /f "delims=" %%i IN ('cygpath -C UTF8 "%APPDATA%\Irssi"') DO SET IRSSI_HOME=%%i

:: Strip leading/trailing spaces from the IRSSI_HOME location
FOR /f "tokens=* delims= " %%a IN ("%IRSSI_HOME%") DO SET IRSSI_HOME=%%a
IF "!IRSSI_HOME:~-1!"==" " SET IRSSI_HOME=!IRSSI_HOME:~0,-1!

SET HOME=%IRSSI_HOME%

mintty.exe -i ..\irssi.ico -t Irssi ./irssi --home="%IRSSI_HOME%"
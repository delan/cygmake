@echo off

REM option variables

set o_arch=x86
set o_mirror=http://mirror.internode.on.net/pub/cygwin
set o_profile=

REM parse command line arguments
REM http://stackoverflow.com/a/3981086/330644

:loop_argp
if not "%1"=="" (
	if "%1"=="-arch" (
		set o_arch=%2
		shift
	)
	if "%1"=="-mirror" (
		set o_mirror=%2
		shift
	)
	if "%1"=="-profile" (
		set o_profile=%2
		shift
	)
	shift
	goto :loop_argp
)

if "%o_profile%"=="" (
	goto :help
)

REM internal variables

set token=%RANDOM%
set bdir=%TEMP%\cygmake\%token%
set cdir=%TEMP%\cygmake\cache
set ldir=%bdir%\logs
set rdir=%bdir%\root
set sdir=%bdir%\setup

REM Cygwin setup command

set scmd=%sdir%\setup ^
	--site %o_mirror% ^
	--root %rdir% ^
	--local-package-dir %cdir% ^
	--arch %o_arch% ^
	--quiet-mode ^
	--no-admin ^
	--no-shortcuts

echo Starting cygmake: %bdir%

pushd %SystemDrive%\
for /f "usebackq tokens=*" %%i in (`dir /s /b makensis.exe`) do (
	set nsis=%%i
)
popd

echo NSIS binary: %nsis%

echo Creating directories...

mkdir %bdir% > nul 2>&1
mkdir %cdir% > nul 2>&1
mkdir %ldir% > nul 2>&1
mkdir %rdir% > nul 2>&1
mkdir %sdir% > nul 2>&1

echo Downloading Cygwin setup...
call :download http://cygwin.com/setup-%o_arch%.exe %sdir%\setup.exe

echo Installing Cygwin base...

%scmd% > %ldir%\000-setup-base.log 2>&1
if errorlevel 1 goto :fail %ERRORLEVEL% setup

REM run %scmd% for each line in the profile's package list
REM http://ss64.com/nt/for_f.html

for /f "eol=# tokens=*" %%i in (profiles\%o_profile%\packages.txt) do (
	echo Installing package: %%i...
	%scmd% --packages %%i > %ldir%\001-setup-%%i.log 2>&1
	if errorlevel 1 goto :fail %ERRORLEVEL% setup
)

echo Augmenting root filesystem...
mkdir %rdir%\tmp\cygmake
mkdir %rdir%\tmp\cygmake\build
mkdir %rdir%\tmp\cygmake\install
mkdir %rdir%\tmp\cygmake\logs
mkdir %rdir%\tmp\cygmake\src
copy profiles\%o_profile%\helper.sh %rdir%\tmp\cygmake > nul 2>&1
if exist profiles\%o_profile%\data (
	xcopy profiles\%o_profile%\data %rdir%\tmp\cygmake ^
		> %ldir%\002-augment.log 2>&1 /s /y
)
if errorlevel 1 goto :fail %ERRORLEVEL% xcopy

echo Running helper.sh...
pushd %rdir%
bin\sh -l /tmp/cygmake/helper.sh
if errorlevel 1 goto :fail %ERRORLEVEL% helper.sh
popd

echo Building installer...
pushd %rdir%\tmp\cygmake\install
"%nsis%" irssi.nsi > %ldir%\090-nsis.log 2>&1
popd

echo Backing up logs...
copy %rdir%\tmp\cygmake\logs\* %ldir% > %ldir%\095-logbackup.log 2>&1

goto :eof

REM subroutines

:help
echo cygmake.cmd: cleanly compile applications for Cygwin
echo -arch [...]	CPU architecture (x86_64, default x86)
echo -mirror [...]	Cygwin package mirror URL (default Internode)
echo -profile [...]	build profile (mandatory)
goto :eof

:fail
echo Fatal error: subprocess %2 failed with return value %1
goto :eof

:download
powershell -Command (new-object System.Net.WebClient).DownloadFile('%1','%2')
if errorlevel 1 goto :fail %ERRORLEVEL% powershell
goto :eof

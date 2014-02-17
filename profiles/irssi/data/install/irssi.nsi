; NSIS installer script for Irssi
; Copyright (C) 2008-2010, Joshua Dick <josh@joshdick.net>
; Copyright (C) 2008, Sebastian Pipping <webmaster@hartwork.org>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

!define EXTRA_INSTALLER "installer"
!include "${EXTRA_INSTALLER}\RequireVersion.nsh"
!insertmacro REQUIRE_VERSION "2.35"

!define APP_VER_FULL "0.8.16-rc1"
; Four numbers, delimited with dots, are required here. For release candidates,
; use a high build number in the previous version, such as 9800 plus the
; release candidate number. This allows any programs sorting on this internal
; field to work as expected.
!define APP_VER_INFO "0.8.15.9801"
!define APP_PKG_RELEASE "1"
!define SRC_DIR "irssi"
!define EXTRA_SHARED "shared"

!define APP_NAME_FULL "Irssi"
!define APP_NAME_SHORT "Irssi"
!define APP_NAME_FILE "irssi"
!define APP_AUTHOR "Irssi Team"
!define APP_WEBSITE "http://www.irssi.org/"

!define APP_INSTDIR_DEFAULT "$PROGRAMFILES\${APP_NAME_SHORT}"
!define APP_UNINST_FILE "Uninstall.exe"
!define APP_ICON_FILE "irssi.ico"

; Registry
!define APP_REG_ROOT "HKCU"
!define APP_REG_AUTHOR "Software\${APP_AUTHOR}"
!define APP_REG_APP "${APP_REG_AUTHOR}\${APP_NAME_SHORT}"
!define APP_REG_INSTALLER "${APP_REG_APP}\Installer"
!define APP_REG_INSTDIR_VALUE "InstallDir"
!define APP_REG_START_MENU_VALUE "StartMenuFolder"
!define APP_UNINST_ROOT "HKCU"
!define APP_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME_SHORT}"

; Start menu
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${APP_REG_ROOT}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${APP_REG_INSTALLER}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${APP_REG_START_MENU_VALUE}"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${APP_NAME_FULL}"

SetCompressor /solid lzma
ShowInstDetails show
ShowUninstDetails show

Name "${APP_NAME_FULL} ${APP_VER_FULL}"
OutFile "${APP_NAME_FILE}-${APP_VER_FULL}.exe"
InstallDir "${APP_INSTDIR_DEFAULT}"
InstallDirRegKey "${APP_REG_ROOT}" "${APP_REG_INSTALLER}" "${APP_REG_INSTDIR_VALUE}"

RequestExecutionLevel admin

!addplugindir "${EXTRA_INSTALLER}"
!include "MUI2.nsh"

; Graphics
!define MUI_ICON "${EXTRA_INSTALLER}\irssi.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall-nsis.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "${EXTRA_INSTALLER}\HEADERIMAGE_BITMAP.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "${NSISDIR}\Contrib\Graphics\Header\orange-uninstall-r.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${EXTRA_INSTALLER}\WELCOMEFINISHPAGE_BITMAP.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\orange-uninstall.bmp"

!define MUI_INSTFILESPAGE_PROGRESSBAR
!define APP_START_MENU_PAGE_ID "StartMenuPage"

var StartMenuFolder
var CygwinFolder

; Install pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${EXTRA_SHARED}\gpl-2.0.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU "${APP_START_MENU_PAGE_ID}" $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES

; Uninstall pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

; Messages
!define MSG_REMOVE_CONFIG "Do you want to remove your Irssi configuration files?$\n$\nChoose [No] if you plan to re-install Irssi later."

; Version info block
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${APP_NAME_FULL}"
; VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "XXX"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${APP_AUTHOR}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Copyright (C) 2008 ${APP_AUTHOR}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright (C) 2008 ${APP_AUTHOR}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${APP_NAME_FULL}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${APP_VER_INFO}"
VIProductVersion "${APP_VER_INFO}"

Function .onInit

  ClearErrors
  UserInfo::GetName ; If this fails, we don't have to be running as an administrator (Windows 9x, etc.)
  IfErrors adminCheckDone

  ; The following usage of the userinfo plugin was found at http://nsis.sourceforge.net/Simple_tutorials#Check_if_user_is_administrator
  
  ; call userInfo plugin to get user info.  The plugin puts the result in the stack.
  userInfo::getAccountType 
  ; Pop the result from the stack into $0.
  pop $0
  ; Compare the result with the string "Admin" to see if the user is admin.
  ; If there's a match, jump to 'adminCheckDone'.
  strCmp $0 "Admin" adminCheckDone
 
  ; If there is not a match, print message and abort
  messageBox MB_OK "The Irssi installer must be run as a user with administrator privileges."
  Abort

  adminCheckDone:
  
    ; Check for a previous installation and prompt the user to remove it  
    ReadRegStr $R0 "${APP_UNINST_ROOT}" "${APP_UNINST_KEY}" "UninstallString"
    StrCmp $R0 "" previousCheckDone
 
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
    "Another version of Irssi is already installed and must be removed before installing this \
    version.$\n$\nClick 'OK' to start its uninstaller or 'Cancel' to cancel this installation."
    Exec $INSTDIR\Uninstall.exe
    Abort
  
    previousCheckDone:
  
FunctionEnd

Function un.onInit

  ClearErrors
  UserInfo::GetName ; If this fails, we don't have to be running as an administrator (Windows 9x, etc.)
  IfErrors adminCheckDone

  ; The following usage of the userinfo plugin was found at http://nsis.sourceforge.net/Simple_tutorials#Check_if_user_is_administrator
  
  ; call userInfo plugin to get user info.  The plugin puts the result in the stack.
  userInfo::getAccountType 
  ; Pop the result from the stack into $0.
  pop $0
  ; Compare the result with the string "Admin" to see if the user is admin.
  ; If there's a match, jump to 'checksFinished'.
  strCmp $0 "Admin" adminCheckDone
 
  ; If there is not a match, print message and abort
  messageBox MB_OK "The Irssi uninstaller must be run as a user with administrator privileges."
  Abort

  adminCheckDone:
  
FunctionEnd

Section -AppDataFiles

  ; Startup script
  SetOutPath "$APPDATA\${APP_NAME_SHORT}"
  File "${EXTRA_SHARED}\startup"

  ; Batch files
  SetOutPath "$INSTDIR"
  File /r /x .svn "${EXTRA_INSTALLER}\bin"

SectionEnd

Section un.AppDataFiles

  ; Startup script and config
  MessageBox MB_YESNO|MB_DEFBUTTON2 "${MSG_REMOVE_CONFIG}" IDNO KEEP_CONFIG_DATA
    RMDir /r "$APPDATA\${APP_NAME_SHORT}"
	
  KEEP_CONFIG_DATA:
SectionEnd

Section -StartMenuEntry
  SetShellVarContext all ; Need to create shortcuts in the 'all users' folder
  
  !insertmacro MUI_STARTMENU_WRITE_BEGIN ${APP_START_MENU_PAGE_ID}

  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${APP_NAME_SHORT}.lnk" "$INSTDIR\bin\irssi.vbs" "" "$INSTDIR\irssi.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Readme.lnk" "$INSTDIR\README.txt"
  WriteINIStr "$SMPROGRAMS\$StartMenuFolder\Website.url" "InternetShortcut" "URL" "http://www.irssi.org/"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\${APP_UNINST_FILE}"
  
  !insertmacro MUI_STARTMENU_WRITE_END
  
SectionEnd

Section un.StartMenuEntry
  SetShellVarContext all ; Need to remove shortcuts the shortcuts from the 'all users' folder

  !insertmacro MUI_STARTMENU_GETFOLDER "${APP_START_MENU_PAGE_ID}" $StartMenuFolder
  ; NOTE: The check below must stay in until we have a way to prevent
  ; compilation of this script with NSIS versions prior to 2.35 .
  StrCmp $StartMenuFolder "" NO_SHORTCUTS
    RMDir /r "$SMPROGRAMS\$StartMenuFolder"

  NO_SHORTCUTS:
SectionEnd

Section -ProgramsEntry
  WriteRegStr "${APP_UNINST_ROOT}" "${APP_UNINST_KEY}" "DisplayName" "${APP_NAME_FULL} ${APP_VER_FULL}"
  WriteRegStr "${APP_UNINST_ROOT}" "${APP_UNINST_KEY}" "UninstallString" "$INSTDIR\${APP_UNINST_FILE}"
  WriteRegStr "${APP_UNINST_ROOT}" "${APP_UNINST_KEY}" "DisplayIcon" "$INSTDIR\${APP_ICON_FILE}"
  WriteRegStr "${APP_UNINST_ROOT}" "${APP_UNINST_KEY}" "DisplayVersion" "${APP_VER_INFO}"
  WriteRegStr "${APP_UNINST_ROOT}" "${APP_UNINST_KEY}" "URLInfoAbout" "${APP_WEBSITE}"
  WriteRegStr "${APP_UNINST_ROOT}" "${APP_UNINST_KEY}" "Publisher" "${APP_AUTHOR}"
SectionEnd

Section un.ProgramsEntry
  DeleteRegKey "${APP_UNINST_ROOT}" "${APP_UNINST_KEY}"
SectionEnd

Section -InstallEssentials
  SetOutPath "$INSTDIR"
  File /r "${SRC_DIR}\bin"
  File /r "${SRC_DIR}\lib"
  File /r "${SRC_DIR}\share"
  File /r "${SRC_DIR}\terminfo"

  ; Copy cygwin1.dll from Cygwin to avoid version conflicts
  ReadRegStr $CygwinFolder HKCU "Software\Cygnus Solutions\Cygwin\mounts v2\/" "native"
  IfFileExists "$CygwinFolder\bin\cygwin1.dll" FOUND_CU
    ReadRegStr $CygwinFolder HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/" "native"
    IfFileExists "$CygwinFolder\bin\cygwin1.dll" FOUND_LM
      Goto AFTER_LM

    FOUND_LM:
      DetailPrint "File cygwin1.dll found in $CygwinFolder\bin\"
      CopyFiles /SILENT /FILESONLY "$CygwinFolder\bin\cygwin1.dll" "$INSTDIR\bin\"

    AFTER_LM:
    Goto AFTER_CU

  FOUND_CU:
    DetailPrint "File cygwin1.dll found in $CygwinFolder\bin\"
    CopyFiles /SILENT /FILESONLY "$CygwinFolder\bin\cygwin1.dll" "$INSTDIR\bin\"

  AFTER_CU:

  File "${EXTRA_SHARED}\gpl-2.0.txt"
  File "${EXTRA_INSTALLER}\irssi.ico"
  File "${EXTRA_SHARED}\README.txt"
  WriteUninstaller "$INSTDIR\${APP_UNINST_FILE}"

  WriteRegStr ${APP_REG_ROOT} "${APP_REG_INSTALLER}" "${APP_REG_INSTDIR_VALUE}" $INSTDIR
  
  MessageBox MB_YESNO \
    "Installation complete!$\n$\nIt is HIGHLY RECOMMENDED that you follow the instructions in the \
	'Important Usage Information' section of README.txt to ensure that several Irssi features \
	will work properly.$\n$\nOpen README.txt now?" \
  IDNO skipreadme
  ExecShell "open" "$INSTDIR\README.txt"
  skipreadme:
SectionEnd

Section un.InstallEssentials
  RMDir /r "$INSTDIR\bin"
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\share"
  RMDir /r "$INSTDIR\usr"

  Delete "$INSTDIR\gpl-2.0.txt"
  Delete "$INSTDIR\irssi.ico"
  Delete "$INSTDIR\README.txt"
  Delete "$INSTDIR\${APP_UNINST_FILE}"
  RMDir "$INSTDIR"

  DeleteRegKey ${APP_REG_ROOT} "${APP_REG_APP}"
  DeleteRegKey /ifempty ${APP_REG_ROOT} "${APP_REG_AUTHOR}"
SectionEnd

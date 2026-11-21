; SPDX-FileCopyrightText: Copyright 2026 Eden Emulator Project
; SPDX-License-Identifier: GPL-3.0-or-later

; Usage:
;   get the latest nsis: https://nsis.sourceforge.io/Download

; Require these for makensis.
!ifndef PRODUCT_VERSION
  !error "PRODUCT_VERSION must be defined"
!endif

!ifndef ARCH
  !error "ARCH must be defined"
!endif

!ifndef VARIANT
  !error "VARIANT must be defined"
!endif

Unicode true
ManifestDPIAware true

; A localized build passes INSTALLER_CONFIG_FILE: an .nsh of !define overrides (title, language list,
; default language) read before the defaults below.
!ifdef INSTALLER_CONFIG_FILE
  !include "${INSTALLER_CONFIG_FILE}"
!endif

!ifndef PRODUCT_NAME
  !define PRODUCT_NAME "Lichii"
!endif
!ifndef PRODUCT_PUBLISHER
  !define PRODUCT_PUBLISHER "Lichii contributors"
!endif
!ifndef PRODUCT_WEB_SITE
  !define PRODUCT_WEB_SITE "https://github.com/zortos293/Eglantine"
!endif
; Window title of the installer. Overridable so a localized build can name itself in its language.
!ifndef INSTALLER_TITLE
  !define INSTALLER_TITLE "${PRODUCT_NAME}"
!endif
; Language preselected in INSTALLER_LANGUAGES_FILE mode. 2052 is Simplified Chinese.
!ifndef INSTALLER_DEFAULT_LANG
  !define INSTALLER_DEFAULT_LANG 1033
!endif
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

; Paths are relative to this file when it is run from its own directory (the default), and
; overridden by the build when it drives makensis from elsewhere.
!ifndef BINARY_SOURCE_DIR
  !define BINARY_SOURCE_DIR "..\bin"
!endif
!ifndef LICENSE_FILE
  !define LICENSE_FILE "..\LICENSE.txt"
!endif
!ifndef INSTALLER_ICON
  !define INSTALLER_ICON "lichii.ico"
!endif

Name "${INSTALLER_TITLE}"
!ifndef OUTFILE
  !define OUTFILE "${PRODUCT_NAME}-Windows-${PRODUCT_VERSION}-${ARCH}-${VARIANT}-installer.exe"
!endif
OutFile "${OUTFILE}"
SetCompressor /SOLID lzma
InstallDir "$LOCALAPPDATA\$(^Name)" 
ShowInstDetails show
ShowUnInstDetails show

!include "MUI2.nsh"
; Custom page plugin
!include "nsDialogs.nsh"

; MUI Settings
!define MUI_ICON "${INSTALLER_ICON}"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; License page
!insertmacro MUI_PAGE_LICENSE "${LICENSE_FILE}"
; Desktop Shortcut page
Page custom desktopShortcutPageCreate desktopShortcutPageLeave
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\lichii.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Variables
Var DesktopShortcutPageDialog
Var DesktopShortcutCheckbox
Var DesktopShortcut

; Page strings of this installer's own pages. MUI uses the default language (the first one loaded)
; for any language that has no string of its own.
LangString LICHII_SHORTCUT_TITLE ${LANG_ENGLISH} "Create Desktop Shortcut"
LangString LICHII_SHORTCUT_TITLE ${LANG_SIMPCHINESE} "创建桌面快捷方式"
LangString LICHII_SHORTCUT_TITLE ${LANG_TRADCHINESE} "建立桌面捷徑"
LangString LICHII_SHORTCUT_SUBTITLE ${LANG_ENGLISH} "Would you like to create a desktop shortcut?"
LangString LICHII_SHORTCUT_SUBTITLE ${LANG_SIMPCHINESE} "是否要创建桌面快捷方式？"
LangString LICHII_SHORTCUT_SUBTITLE ${LANG_TRADCHINESE} "是否要建立桌面捷徑？"
LangString LICHII_SHORTCUT_CHECKBOX ${LANG_ENGLISH} "Create a desktop shortcut"
LangString LICHII_SHORTCUT_CHECKBOX ${LANG_SIMPCHINESE} "创建桌面快捷方式"
LangString LICHII_SHORTCUT_CHECKBOX ${LANG_TRADCHINESE} "建立桌面捷徑"

; Language files. A localized build passes INSTALLER_LANGUAGES_FILE: an .nsh holding its own
; MUI_LANGUAGE list, which is then used instead of the full list below.
!ifdef INSTALLER_LANGUAGES_FILE
!include "${INSTALLER_LANGUAGES_FILE}"
!else
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "Danish"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Hungarian"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "Japanese"
!insertmacro MUI_LANGUAGE "Korean"
!insertmacro MUI_LANGUAGE "Lithuanian"
!insertmacro MUI_LANGUAGE "Norwegian"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "Romanian"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "Swedish"
!insertmacro MUI_LANGUAGE "Turkish"
!insertmacro MUI_LANGUAGE "Vietnamese"
!endif

; MUI end ------

Function .onInit
  StrCpy $DesktopShortcut 1

  !ifdef INSTALLER_LANGUAGES_FILE
  ; A localized build installs in its own language without asking.
  StrCpy $LANGUAGE ${INSTALLER_DEFAULT_LANG}
  !else
  !insertmacro MUI_LANGDLL_DISPLAY
  !endif
FunctionEnd

Function desktopShortcutPageCreate
  !insertmacro MUI_HEADER_TEXT "$(LICHII_SHORTCUT_TITLE)" "$(LICHII_SHORTCUT_SUBTITLE)"
  nsDialogs::Create 1018
  Pop $DesktopShortcutPageDialog
  ${If} $DesktopShortcutPageDialog == error
    Abort
  ${EndIf}

  ${NSD_CreateCheckbox} 0u 0u 100% 12u "$(LICHII_SHORTCUT_CHECKBOX)"
  Pop $DesktopShortcutCheckbox
  ${NSD_SetState} $DesktopShortcutCheckbox $DesktopShortcut

  nsDialogs::Show
FunctionEnd

Function desktopShortcutPageLeave
  ${NSD_GetState} $DesktopShortcutCheckbox $DesktopShortcut
FunctionEnd

Section "Base"
  ExecWait '"$INSTDIR\uninst.exe" /S _?=$INSTDIR'

  SectionIn RO

  SetOutPath "$INSTDIR"

  ; The binplaced build output will be included verbatim.
  File /r "${BINARY_SOURCE_DIR}\*"

  ; Create start menu and desktop shortcuts
  CreateShortCut "$SMPROGRAMS\$(^Name).lnk" "$INSTDIR\lichii.exe"
  ${If} $DesktopShortcut == 1
    CreateShortCut "$DESKTOP\$(^Name).lnk" "$INSTDIR\lichii.exe"
  ${EndIf}
SectionEnd

!include "FileFunc.nsh"

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"

  WriteRegStr HKCU "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\lichii.exe"

  ; Write metadata for add/remove programs applet
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\lichii.exe"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKCU "${PRODUCT_UNINST_KEY}" "EstimatedSize" "$0"

  WriteRegStr HKCU "Software\Classes\.nsp" "" "$(^Name)"
  WriteRegStr HKCU "Software\Classes\.xci" "" "$(^Name)"
  WriteRegStr HKCU "Software\Classes\.nro" "" "$(^Name)"
  WriteRegStr HKCU "Software\Classes\.kip" "" "$(^Name)"
  WriteRegStr HKCU "Software\Classes\$(^Name)\DefaultIcon" "" "$INSTDIR\lichii.exe,0"
  WriteRegStr HKCU "Software\Classes\$(^Name)\Shell\open\command" "" '"$INSTDIR\lichii.exe" %1'
SectionEnd

Section Uninstall
  Delete "$DESKTOP\$(^Name).lnk"
  Delete "$SMPROGRAMS\$(^Name).lnk"

  ; Be a bit careful to not delete files a user may have put into the install directory.
  Delete "$INSTDIR\lichii.exe"
  Delete "$INSTDIR\eden-cli.exe"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\LICENSE.txt"
  Delete "$INSTDIR\README.md"
  RMDir /r "$INSTDIR\LICENSES"
  RMDir "$INSTDIR"

  DeleteRegKey HKCU "Software\Classes\.nsp"
  DeleteRegKey HKCU "Software\Classes\.xci"
  DeleteRegKey HKCU "Software\Classes\.nro"
  DeleteRegKey HKCU "Software\Classes\.kip"
  DeleteRegKey HKCU "Software\Classes\$(^Name)"

  DeleteRegKey HKCU "Software\Classes\discord-1397286652128264252"

  DeleteRegKey HKCU "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKCU "${PRODUCT_DIR_REGKEY}"

  SetAutoClose true
SectionEnd

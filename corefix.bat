echo off

REM Echo Y|wmic product where "name='WIC Direct - Core Interop - 6.15.1.30'" Call Uninstall
REM Echo Y|wmic product where "name='WIC Direct - Core Interop - 6.16.1.15'" Call Uninstall

REM assume there can only be one version of WIC Direct installed at a time
REM so we only need to run this once
echo "Removing old versions of WIC Direct..."
Echo Y|wmic Product Where "Name Like 'WIC%%'" Call Uninstall /NoInteractive

REM use Windows' Curl to download latest CoreInterop into current directory
echo "Downloading latest version of WIC Direct..."
curl https://ebtprodweb.cdpehs.com/EBT/CoreInteropDownload/CoreInterop.msi -o %~dp0\CoreInterop.msi

REM Install fresh CoreInterop
echo "Installing WIC Direct..."
msiexec /i %~dp0\CoreInterop.msi /quiet


REM Restart CoreInterop Service
REM echo "Restarting CoreInterop services..."
REM net stop BB.EBT.ServiceHosts.CoreInterop
REM net start BB.EBT.ServiceHosts.CoreInterop

REM close browsers
REM echo "Press any key to close browsers..."
REM pause
REM taskkill /F /IM firefox.exe /T
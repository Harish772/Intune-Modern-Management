#For PS Script. 

## Find winget.exe
$JBNWinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$JBNWinGetPathExe = $JBNWinGetResolve[-1].Path

$JBNWinGetPath = Split-Path -Path $JBNWinGetPathExe -Parent
set-location $JBNWinGetPath

#Variable Declaration - Log File name
$logfile = [string]$env:windir + "\logs\software\CompanyPortalWinget.log"

#Variable Declaration - Log Folder
$logpath = [string]$env:windir + "\logs\software\"

#Creating a log file folder

if (!(test-path $logfile)) {
    new-item -Path $logfile -ItemType File -Force | Out-Null
}

if (!(test-path $logpath)) {
    new-item -Path $logpath -ItemType Directory -Force | Out-Null
}


If ($JBNWinGetResolve) 
{

.\winget.exe install --Scope Machine -e --id 9WZDNCRFJ3PZ --accept-package-agreements --accept-source-agreements --disable-interactivity | Out-File "c:\Windows\logs\software\CompanyPortalWinget.log" -Append string -Force 

}



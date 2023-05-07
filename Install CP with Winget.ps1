####### Detection script ########
### Software Detection Script to see if software needs an update
### Author: John Bryntze
### Date: 6th January 2023

## Help System to find winget.exe
$JBNWinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$JBNWinGetPathExe = $JBNWinGetResolve[-1].Path

$JBNWinGetPath = Split-Path -Path $JBNWinGetPathExe -Parent
set-location $JBNWinGetPath

## Variables
$JBNAppID = "VideoLAN.VLC"
$JBNAppFriendlyName = "VideoLAN VLC"

## Check locally installed software version
$JBNLocalInstalledSoftware = .\winget.exe list -e --id $JBNAppID --accept-source-agreements

$JBNAvailable = (-split $JBNLocalInstalledSoftware[-3])[-2]

## Check if needs update
if ($JBNAvailable -eq 'Available')
{
    write-host $JBNAppFriendlyName "is installed but not the latest version, needs an update"
    exit 1
}

if ($JBNAvailable -eq 'Version')
{
    write-host $JBNAppFriendlyName "is installed and is the latest version"
    exit 0
}

if (!$JBNAvailable)
{
    write-host $JBNAppFriendlyName "VLC is not installed"
    exit 0
}

##### Do not copy this line, below is another script #####

######## Remediation script #########
### Software Remediation Script to update the software
### Author: John Bryntze
### Date: 6th January 2023

## Help System to find winget.exe
$JBNWinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$JBNWinGetPathExe = $JBNWinGetResolve[-1].Path

$JBNWinGetPath = Split-Path -Path $JBNWinGetPathExe -Parent
set-location $JBNWinGetPath

## Variables
$JBNAppID = "VideoLAN.VLC"

## Run upgrade of the software
.\winget.exe upgrade -e --id $JBNAppID --silent --accept-package-agreements --accept-source-agreements
winget install -e --id 9WZDNCRFJ3PZ --accept-package-agreements --accept-source-agreements
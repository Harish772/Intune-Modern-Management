#Powershell Scratch Pad


##*===============================================
##* Section: AD Realted 
##*===============================================

# Get’s the information from AD for a User. 
Get-ADuser P72362 
# Get’s the list of AD Groups that the user is part of. 
Get-ADPrincipalGroupMembership p72362 | Select-Object name | Sort-Object -Property name
# Get’s you the list of users who are part of this AD Group
Get-ADgroupmemeber Genutie_I_SCCM
 #Get’s you the count of users in this AD Group. 
(Get-ADgroupmemeber Genutie_I_SCCM).count 
 #Get’s you the list of users with name like Joel from AD. 
Get-ADUser -filter 'name -like "Zoch*"' | Select-object Name, SAMaccountname | Sort-Object -Property Name

(Get-ADUser –filter *).count

(get-ADComputer –filter *).count

(get-adgroup –filter *).count


##*===============================================
##* Section: SCCM Related 
##*===============================================

Get-CMApplication -fast | Select-Object Localizeddisplayname, Manufacturer, SoftwareVersion, LocalizedDescription, {$_.LocalizedCategoryInstanceNames}, Numberofdeploymenttypes, NumberOfDeployments, Isdeployed, Hascontent, Datecreated, CreatedBy, LastModifiedBy, DateLastModified | Sort-Object -Property Localizeddisplayname | Export-Csv C:\temp\PSSCCMDumps\test11.csv –NoTypeInformation
Get-CMPackage -Fast | Select-Object Name, Description, NumOfPrograms, PackageID,  ObjectPath, sourcedate | Sort-Object -Property name | Export-Csv C:\temp\PSSCCMDumps\test12.csv –NoTypeInformation
Get-CMApplicationDeployment | Select-Object ApplicationName, CollectionName, TargetCollectionID | Sort-Object -Property CollectionName | Export-csv "C:\temp\PSSCCMDumps\Temsdar12.csv" -NoTypeInformation
New-CMCollection -CollectionType User -LimitingCollectionName "All Users and User Groups" -Name "Win10 - ACG - Corporate Affinity 3.5 - Available (User)"
New-CMApplicationDeployment -Name "Napa Tracs Enterprise 2.11.73" -CollectionName 'Win10 - Napa Tracs Enterprise 2.11.73 - Available (User)' -DeployAction Install -DeployPurpose Available -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False
Get-CMApplication -fast -Name "Microsoft *" | Select-Object LocalizedDisplayName | Sort-Object -Property LocalizedDisplayname
Get-CMUserCollection | Select-Object name | Sort-Object -Property name
Get-CMDeployment -CollectionName "Win10 - All MECM Win10 Prod Ready Applications - Available (User)" | Select-Object ApplicationName : Gets you the List of Apps deployed to a Particualr Collection
Set-CmApplication: Configures Properties of an Application 
Get-CMCollection -Name "Win10 - Project Max Applications (Temp) - Available (User)" | Get-CMCollectionMember | Select-Object Name | Sort-Object -Property Name | Out-File C:\temp\PSSCCMDumps\ProjectMax-Users.txt : Gives you the Members of a Collection
Get-CMApplication -fast | Where-object {$_.LocalizedCategoryInstanceNames -eq "Peer Review"} | Select-Object LocalizedDisplayName, LocalizedCategoryInstanceNames | Sort-Object -Property LocalizedDisplayname
net localgroup administrators domainname\username /add
net localgroup administrators

        ##*===============================================
		##* START: Add-CMUserCollectionDirectMembershipRule.ps1
		##*===============================================

$Users = Get-Content “C:\Temp\0816.txt” 
$Colname = "Win10 - Acrosoft - CutePDF Pro 4.0 (New) - Available (User)"

foreach ($user in $Users)

{ 

    Add-CMUserCollectionDirectMembershipRule -CollectionName $Colname -ResourceId  (Get-CMUser -Name $user).ResourceID 
    Write-Host ("$user added...Proceeding to Next") 
}
        ##*===============================================
		##* END: Add-CMUserCollectionDirectMembershipRule.ps1
		##*===============================================

        ##*===============================================
		##* START: App-UserDeployments.ps1
		##*===============================================

$CSVFile  = "C:\temp\Appsdeployment-powershell\App-UserDeployments.csv"


$Var = Import-Csv $csvFile | foreach {
  New-Object PSObject -prop @{
    
    AppName = [string]$_.AppName;
    CollName = [string]$_.CollName
  }
}



#New-CMSoftwareUpdateDeployment -SoftwareUpdateGroupName $GroupName -CollectionName $CollName 
New-CMApplicationDeployment -Name $AppName -CollectionName '$CollName' -DeployAction Install -DeployPurpose Available -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False
        ##*===============================================
		##* END: App-UserDeployments.ps1
		##*===============================================

        ##*===============================================
		##* START: Audit Scope Apps collections.ps1
		##*===============================================


#Goal is to get the Install Counts for All our Audit Scope Apps(Licensed)
# Only edit or update variables "$TargetAppARPName", "$TargetCollectionName", "$QueryRuleName" 

$TargetAppARPName = "RStudio"
$TargetCollectionName = "RStudio - Install Counts"
$QueryRuleName = "RStudio"

$query = @"
Select SMS_R_System.ResourceID, SMS_R_System.ResourceType, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceID where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like "%$TargetAppARPName%"
"@

New-CMDeviceCollection -Name $TargetCollectionName -LimitingCollectionName "All ACG Site Windows Workstation Client Systems"

Add-CMDeviceCollectionQueryMembershipRule -RuleName $QueryRuleName -CollectionName $TargetCollectionName -QueryExpression $query

$Movecollection = Get-CMDeviceCollection -Name $TargetCollectionName

Move-CMObject -FolderPath "ACG:\DeviceCollection\Deployment Collections\Testing\Harish Kakarla -P72362\Audit Scope Apps(Licensed)" -InputObject $Movecollection

 
        ##*===============================================
		##* END: Audit Scope Apps collections.ps1
		##*===============================================


        ##*===============================================
		##* START: Get-CMDistributionStatus for 100s of Apps.ps1
		##*===============================================

$Appslist = get-content 'C:\temp\Appsdeployment-powershell\Appslist.txt'

foreach ($App in $Appslist)

{
$PackageId = (Get-CMApplication -Name "$App").PackageID
Get-CMDistributionStatus -Id $PackageId | Select-Object SoftwareName, Targeted 


}


        ##*===============================================
		##* END: Get-CMDistributionStatus for 100s of Apps.ps1
		##*===============================================

        ##*===============================================
		##* START: Get-CMUsersfromAffinity.ps1
		##*===============================================

$computers = Import-Csv -Path "C:\temp\PSSCCMDumps\Devices.csv"

foreach ( $computer in $computers )
{
  $uda = Get-CMUserDeviceAffinity -DeviceName $computer.Name
  
  if ( ($uda.UniqueUserName).count -gt 1 )
  {
    foreach ( $user in $uda.UniqueUserName )
    {
      Write-Host $uda.ResourceName[1] $user
    }
  }
  else
  {
    write-host $uda.ResourceName $uda.UniqueUserName
  }
}


        ##*===============================================
		##* END: Get-CMUsersfromAffinity.ps1
		##*===============================================

        ##*===============================================
		##* START: Get-DeploymentTypeContextforAllSCCMapps.Ps1
		##*===============================================
$a = (get-cmapplication).LocalizedDisplayName

$a |  ForEach-Object {

(Get-CMDeploymentType -ApplicationName $_).ExecutionContext

if (((Get-CMDeploymentType -ApplicationName $_).ExecutionContext) -eq 0) {

Write-host "$_ is deployed in System Context"

}

elseif ($ExecutionContext -eq 1) {

Write-host "$_ is deployed in User Context"

}


}

        ##*===============================================
		##* END: Get-DeploymentTypeContextforAllSCCMapps.Ps1
		##*===============================================

        ##*===============================================
		##* START: Mass New-CMApplicationDeployment.ps1
		##*===============================================
$Appslist = get-content 'C:\temp\PSSCCMDumps\Deploy.txt'

foreach ($App in $Appslist)

{
Write-Host ("$App ..........................Incoming")

#For Available Deployments
New-CMApplicationDeployment -Name "$App" -AvailableDateTime '04/11/2022 00:00:00' -CollectionName 'All MECM Prod Ready Applications - Available (User)' -DeployAction Install -DeployPurpose Available -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False


Start-CMContentDistribution -ApplicationName "$App" -DistributionPointName "NCCHARSCCM01.AAA-ACG.NET"


#For Requried Deployments

#New-CMApplicationDeployment -Name "$App" -AvailableDateTime '01/01/2020 00:00:00' -CollectionName 'Win10 - AAA - Carloina SOAP+Postman - Required(Device)' -DeadlineDateTime '01/01/2020 00:00:00' -DeployAction Install -DeployPurpose Required -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False
Write-Host ("$App ..........................Completed")

}

Invoke-CMDeploymentSummarization -CollectionName "Win10 - AAA - Carolina Developer Apps UAT Testing - Required(Device)"

        ##*===============================================
		##* END: Mass New-CMApplicationDeployment.ps1
		##*===============================================

        ##*===============================================
		##* START: Mass Remove-CMDeployment.ps1
		##*===============================================
Get-CMDeployment -CollectionName "ACG/AAA - VDI - WIN10 - P72362(HK)" -FeatureType Application | Remove-CMDeployment -Force

(Get-CMDeployment -CollectionName "ACG/AAA - VDI - WIN10 - P72362(HK)" | Select-Object ApplicationName | Sort-Object -Property ApplicationName).count

(Get-CMDeployment -CollectionName "All MECM Prod Ready Applications - Available (User)" | Select-Object ApplicationName | Sort-Object -Property ApplicationName).count

Get-CMDeployment -CollectionName "All MECM Prod Ready Applications - Available (User)" | Select-Object ApplicationName | Sort-Object -Property ApplicationName | Export-csv "C:\temp\PSSCCMDumps\dshfweruiotuwiofgwi.csv"


Get-CMDeployment -CollectionName "All MECM Prod Ready Applications - Available (User)" -FeatureType Application | Remove-CMDeployment -Force


        ##*===============================================
		##* END: Mass Remove-CMDeployment.ps1
		##*===============================================

        ##*===============================================
		##* START: Mass Tweak Deployment Types properties.ps1
		##*===============================================

$Appslist = get-content 'C:\temp\Appsdeployment-powershell\Appslist.txt'

foreach ($App in $Appslist)

{
    $App
    $DT = (Get-CMDeploymentType -ApplicationName "$app").LocalizedDisplayName
    $DT
    #Set-CMScriptDeploymentType -ApplicationName "$App" -DeploymentTypeName "$DT"-SlowNetworkDeploymentMode Download

    Set-CMMsiDeploymentType -ApplicationName "$App" -DeploymentTypeName "$DT" -SlowNetworkDeploymentMode Download

    Write-host ("Proceeding to next...............$App")
} 


        ##*===============================================
		##* END: Mass Tweak Deployment Types properties.ps1
		##*===============================================

        ##*===============================================
		##* START: MassTweak-AppCategory.ps1
		##*===============================================
#$app = Get-CMApplication -Name "A.M. Best Company - BestSRQ Services 2015"
#$userCat = Get-CMCategory -Name "Test Applications" -CategoryType CatalogCategories
#$adminCat = Get-CMCategory -Name "ServiceNow-CSD Ready" -CategoryType AppCategories

#Set-CMApplication -InputObject $app -AddAppCategory $adminCat


#-------------------------------------
$Appslist = get-content 'C:\temp\PSSCCMDumps\Appslist.txt'

foreach ($Aa in $Appslist)

{
    #$App
    $app = Get-CMApplication -Name "$Aa"
    $adminCat = Get-CMCategory -Name "ServiceNow-CSD Ready" -CategoryType AppCategories
    Set-CMApplication -InputObject $app -AddAppCategory $adminCat
    Write-host ("Proceeding to next...........................$App")

   
} 


        ##*===============================================
		##* END: MassTweak-AppCategory.ps1
		##*===============================================

        ##*===============================================
		##* START: Mass-UpdateLimitingCollections.ps1
		##*===============================================

$TargetCollectionName = get-content "C:\temp\Appsdeployment-powershell\Appslist.txt"

Foreach ($var in $TargetCollectionName){
Write-Output $var 
Get-CMDeviceCollection -Name $var | Set-CMDeviceCollection -LimitingCollectionName "All ACG Site Windows Workstation Client Systems"
}
        ##*===============================================
		##* END: Mass-UpdateLimitingCollections.ps1
		##*===============================================

        ##*===============================================
		##* START: Start-CMContentDistribution of 100s of Apps to DP Groups
		##*===============================================

$Appslist = get-content 'C:\temp\Appsdeployment-powershell\Appslist.txt'

foreach ($App in $Appslist)

{
 
Start-CMContentDistribution -ApplicationName "$App" -DistributionPointGroupName "All ACG PILOTS DPs"


}
        ##*===============================================
		##* END: Start-CMContentDistribution of 100s of Apps to DP Groups
		##*===============================================

        ##*===============================================
		##* START: Temp-AppDeployments.ps1
		##*===============================================

#-----------------------------
$ApplicationName = "NotePad++ 8.5.0"


New-CMApplicationDeployment -Name "$ApplicationName" -AvailableDateTime '01/01/2020 00:00:00' -CollectionName 'All Prod Ready Apps for Support Techs L1, L2, L3 - Available (User)' -DeployAction Install -DeployPurpose Available -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False
#Start-CMContentDistribution -ApplicationName "$ApplicationName" -DistributionPointGroupName "All ACG PILOTS DPs"

#New-CMApplicationDeployment -Name "$ApplicationName" -AvailableDateTime '01/01/2020 00:00:00' -CollectionName 'All MECM Prod Ready Applications - Available (User)' -DeployAction Install -DeployPurpose Available -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False


#New-CMApplicationDeployment -Name "$ApplicationName" -AvailableDateTime '01/01/2020 00:00:00' -CollectionName 'ACG/AAA - VDI - WIN10 - P72362(HK)' -DeployAction Install -DeployPurpose Available -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False

#New-CMApplicationDeployment -Name "$ApplicationName" -AvailableDateTime '01/01/2020 00:00:00' -CollectionName 'Win10 - ACICF Temp UAT Testing - Required (Device)' -DeadlineDateTime '01/01/2020 00:00:00' -DeployAction Install -DeployPurpose Required -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False

#----------------------------

#--------------------------------------

$collectionName = "Win10 - NotePad++ 8.5.0 - Available (User)"
New-CMCollection -CollectionType User -LimitingCollectionName "All Users and User Groups" -Name "$collectionName"



#------------------------

$ApplicationName = "NotePad++ 8.5.0"
$collectionName = "Win10 - NotePad++ 8.5.0 - Available (User)"

New-CMApplicationDeployment -Name "$ApplicationName" -AvailableDateTime '01/01/2020 00:00:00' -CollectionName "$collectionName" -DeployAction Install -DeployPurpose Available -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False


#---------------------------------------------------------------------------------
$ApplicationName = "NotePad++ 8.5.0"

Start-CMContentDistribution -ApplicationName "$ApplicationName" -DistributionPointName "NCCHARSCCM01.AAA-ACG.NET"
#"NCROANSCCMDP01.AAA-ACG.NET"
#"NCCHARSCCM01.AAA-ACG.NET"
#------------------------------
#Below cmdlet is equiavalet to "Run Summarization" in SCCM runs against a Collection or Application 
Invoke-CMDeploymentSummarization -CollectionName "Win10 - AAA - Carolina Developer Apps UAT Testing - Required(Device)"

#------------------------------------
#Win10 - Project Max Ajhpplications (Temp) - Available (User)
#Get-CMDeployment -CollectionName "Win10 - Project Max Applications (Temp) - Available (User)" | Select-Object ApplicationName | Sort-Object -Property Name | Out-File C:\temp\PSSCCMDumps\ProjectMax-Apps.txt
$User = "AAA_Corp\P73294"

#


Add-CMUserCollectionDirectMembershipRule -CollectionName "Win10 - Project Max Applications (Temp) - Available (User)" -ResourceId  (Get-CMUser -Name $user).ResourceID 


$User = "AAA_Corp\p73064"

Add-CMUserCollectionDirectMembershipRule -CollectionName "Win10 - Microsoft - Visio Professional Standalone (x86) 2016 - Available (User)" -ResourceId  (Get-CMUser -Name $user).ResourceID 


$User = "AAA_Corp\p73064"
Add-CMUserCollectionDirectMembershipRule -CollectionName "Win10 - Microsoft - Project Professional Standalone (x86) 2016 - Available (User)" -ResourceId  (Get-CMUser -Name $user).ResourceID 



$User = "AAA_Corp\p73061"
$collectionName = "Win10 - Configuration Manager Remote Control (CMRC) 1910 - Available (User)"

Add-CMUserCollectionDirectMembershipRule -CollectionName "Win10 - Configuration Manager Remote Control (CMRC) 1910 - Available (User)" -ResourceId  (Get-CMUser -Name $user).ResourceID 



$App = "Housatonic - Project Viewer 365"
New-CMApplicationDeployment -Name "$App" -AvailableDateTime '01/01/2020 00:00:00' -CollectionName 'Win10 - Project Max Applications (Temp) - Available (User)' -DeployAction Install -DeployPurpose Available -UserNotification DisplaySoftwareCenterOnly -PersistOnWriteFilterDevice $False



Get-CMCollection -Name "Win10 - Project Max Applications (Temp) - Available (User)" | Get-CMCollectionMember | Select-Object Name | Sort-Object -Property Name | Out-File C:\temp\PSSCCMDumps\ProjectMaxo-Users.txt

Get-CMDeployment -CollectionName "Win10 - All Prod Ready Apps for Support Techs L1, L2, L3 - Available (User)" | Select-Object ApplicationName | Sort-Object -Property ApplicationName | Out-File "C:\temp\PSSCCMDumps\User Collection - VDI - P72362-Apps.txt"

(Get-CMDeployment -CollectionName "Win10 - ACG - All MECM Prod Ready Applications - Available (User)" | Select-Object ApplicationName | Sort-Object -Property ApplicationName).count


        ##*===============================================
		##* END: Temp-AppDeployments.ps1
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================













##*===============================================
##* Section: Intune Graph Related 
##*===============================================

        ##*===============================================
		##* START: Add-MultipleDevicestoAADGroup.Ps1
		##*===============================================
Connect-MgGraph
Connect-azuread
$groupname = "Win10 - Company Portal - Required (Device)"
$Group = Get-azureADGroup -Filter "Displayname eq '$Groupname'" | Select-Object ObjectID
$Members = Get-Content "C:\temp\0811.txt"
$totalcount = $Members.count

$completedCount = 0


Foreach ($var in $Members){
 $DevObjIDs = Get-AzureADDevice -SearchString "$var" | Select-Object ObjectId -ExpandProperty ObjectId
 
 start-sleep -s 1
 
 Foreach ($DevObjID in $DevObjIDs) {
 
 Add-AzureADGroupMember -ObjectId "353ae27d-6cc0-49d1-af33-2bdb35d5a9b9" -RefObjectId "$DevObjID"
 
  }
 
 $completedcount++
 Write-host "Completed $completedcount out of $totalcount devices. Proceeding onto next...$devobjID"



}
        ##*===============================================
		##* END: Add-MultipleDevicestoAADGroup.Ps1
		##*===============================================
        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================


 
##*===============================================
##* Section: Pacakging - PSADT Realted
##*===============================================

#Folder - Permissions
$DestPath2 = "C:\Program Files (x86)\Fuhr Software"
if ((Test-path $DestPath2)){

    Icacls $DestPath2 /grant:r '"Users":(OI)(CI)M' /T
}
        ##*===============================================
		##* START: Add-LocalGroupMember.ps1
		##*===============================================


Enter-pssession EDM-VMPKGR313


Add-LocalGroupMember -Group "Direct Access Users" -Member "AAA_Corp\T_EDM_USER"

Add-LocalGroupMember -Group "Administrators" -Member "AAA_Corp\T_EDM_USER"

Exit-PSSession

Get-LocalGroupMember -Group "Administrators"

        ##*===============================================
		##* END: Add-LocalGroupMember.ps1
		##*===============================================

        ##*===============================================
		##* START: Get-InstalledApp for 1 app from 1 machine.ps1
		##*===============================================

function Get-InstalledApplicationList {
    $fullapplist = @()
    
    $regapplist = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    if (test-path "HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall") {$regapplist = $regapplist + (Get-ChildItem "HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall")}

    foreach ($entry in $regapplist) {
        $fullapplist += Get-ItemProperty $entry.PSPath
    }

    return $fullapplist
}

$apps = Get-InstalledApplicationList | Select-Object DisplayName -ExpandProperty DisplayName -ErrorAction SilentlyContinue 


$TargetAppLookup2 = "Microsoft Visual C++ 2015*"

Foreach ($app in $apps) {

if (($app -like $TargetAppLookup2))  {

    Write-Host "Installed"
    
}


}

        ##*===============================================
		##* END: Get-InstalledApp for 1 app from 1 machine.ps1
		##*===============================================

        ##*===============================================
		##* START: Post Install Customization Env Variable Update.ps1
		##*===============================================
[System.Environment]::GetEnvironmentVariable('PATH','machine') > C:\backup-pathBeforee.txt
$INCLUDE = "C:\Program Files\sfdx\bin"
$OLDPATH = [System.Environment]::GetEnvironmentVariable('PATH','machine')
$NEWPATH = "$OLDPATH;$INCLUDE"
[Environment]::SetEnvironmentVariable("PATH", "$NEWPATH", "Machine")
($env:PATH).split(";")
[System.Environment]::GetEnvironmentVariable('PATH','machine') > C:\backup-pathAfter.txt

#-----------
$regkeypath= "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" 
$value1 = (Get-ItemProperty $regkeypath).Path
$value2 = "C:\Program Files\Java\Jdk1.8.0_291;C:\Program Files\Java\Jre1.8.0_291"
$value3 = $value1 + ";" + $value2
Set-ItemProperty -Path $regkeypath -Name Path -Value $value3 -Type string


        ##*===============================================
		##* END: Post Install Customization Env Variable Update.ps1
		##*===============================================

        ##*===============================================
		##* START: PSADT-Cheatsheet.ps1
		##*===============================================
## Commonly used PSADT env variables
$envCommonDesktop           # C:\Users\Public\Desktop
$envCommonStartMenuPrograms # C:\ProgramData\Microsoft\Windows\Start Menu\Programs
$envProgramFiles            # C:\Program Files
$envProgramFilesX86         # C:\Program Files (x86)
$envProgramData             # c:\ProgramData
$envUserDesktop             # c:\Users\{user currently logged in}\Desktop
$envUserStartMenuPrograms   # c:\Users\{user currently logged in}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
$envSystemDrive             # c:
$envWinDir                  # c:\windows

## How to load ("dotsource") PSADT functions/variables for manual testing (your powershell window must be run as administrator first)
cd "$path_to_PSADT_folder_youre_working_from"
. .\AppDeployToolkit\AppDeployToolkitMain.ps1

## *** Examples of exe install***
Execute-Process -Path '<application>.exe' -Parameters '/quiet' -WaitForMsiExec:$true
Execute-Process -Path "$dirFiles\DirectX\DXSetup.exe" -Parameters '/silent' -WindowStyle 'Hidden'
#open notepad, don't wait for it to close before proceeding (i.e. continue with script)
Execute-Process -Path "$envSystemRoot\notepad.exe" -NoWait 
#Execute an .exe, and hide confidential parameters from log file
$serialisation_params = '-batchmode -quit -serial <aa-bb-cc-dd-ee-ffff11111> -username "<serialisation username>" -password "SuperSecret123"'
Execute-Process -Path "$envProgramFiles\Application\Serialise.exe" -Parameters "$serialisation_params" -SecureParameters:$True

##***Example to install an msi***
Execute-MSI -Action 'Install' -Path "$dirFiles\<application>.msi" -Parameters 'REBOOT=ReallySuppress /QN'
Execute-MSI -Action 'Install' -Path 'Discovery 2015.1.msi'
#MSI install + transform file
Execute-MSI -Action 'Install' -Path 'Adobe_Reader_11.0.0_EN.msi' -Transform 'Adobe_Reader_11.0.0_EN_01.mst'

## Install a patch
Execute-MSI -Action 'Patch' -Path 'Adobe_Reader_11.0.3_EN.msp'

## To uninstall an MSI
Execute-MSI -Action Uninstall -Path '{5708517C-59A3-45C6-9727-6C06C8595AFD}'

## Uninstall a number of msi codes
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{B234DC00-1003-47E7-8111-230AA9E6BF10}" <# Last example cannot have a comma after the double quotes #>`
| % { Execute-MSI -Action 'Uninstall' -Path "$_" } <# foreach item, uninstall #>

## ***Run a vbscript***
Execute-Process -Path "cscript.exe" -Parameters "$dirFiles\whatever.vbs"


## Copy a file to the correct relative location for all user accounts
#grabbed from here: http://psappdeploytoolkit.com/forums/topic/copy-file-to-all-users-currently-logged-in-and-for-all-future-users/
$ProfilePaths = Get-UserProfiles | Select-Object -ExpandProperty 'ProfilePath'
ForEach ($Profile in $ProfilePaths) {
    Copy-File -Path "$dirFiles\Example\example.ini" -Destination "$Profile\Example\To\Path\"
}

##***Remove registry key***
#I dont know the right term, but these are to delete the whole 'folder' reg key
Remove-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Macromedia\FlashPlayer\SafeVersions' -Recurse
Remove-RegistryKey -Key 'HKLM:SOFTWARE\Macromedia\FlashPlayer\SafeVersions' -Recurse
#This is to remove a specific reg key item from within a 'folder'
Remove-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'RunAppInstall'
Remove-RegistryKey -Key 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'RunAppInstall'

## ***Create a reg key***
Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\LMKR\Licensing' -Name 'LMKR_LICENSE_FILE' -Value '@license'-Type String -ContinueOnError:$True

## ***To set an HKCU key for all users including default profile***
[scriptblock]$HKCURegistrySettings = {
    # I included both to illustrate that HKCU\ is an acceptable abbreviation
    Set-RegistryKey -Key 'HKEY_CURRENT_USER\SOFTWARE\Classes\AppX4hxtad77fbk3jkkeerkrm0ze94wjf3s9' -Name 'NoOpenWith' -Value '""'-Type String -ContinueOnError:$True -SID $UserProfile.SID
    Set-RegistryKey -Key 'HKCU\Software\Microsoft\Office\14.0\Common' -Name 'qmenable' -Value 0 -Type DWord -SID $UserProfile.SID
}
Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings

#import a .reg key, useful if there's a butt-tonne of nested keys/etc
Execute-Process -FilePath "reg.exe" -Parameters "IMPORT `"$dirFiles\name-of-reg-export.reg`"" -PassThru

## To pause script for <x> time
Start-Sleep -Seconds 120

## ***To copy and overwrite a file***
Copy-File -Path "$dirSupportFiles\mms.cfg" -Destination "C:\Windows\SysWOW64\Macromed\Flash\mms.cfg"

## ***To copy a file***
Copy-File -Path "$dirSupportFiles\mms.cfg" -Destination "C:\Windows\SysWOW64\Macromed\Flash\"

## ***To copy a folder***
# pls note the destination should be the PARENT folder, not the folder name you want it to be. 
# for example, you'd copy "mozilla firefox" to "c:\program files", if you were wanting to copy the application files.
# if copying to root of c:, include trailing slash - i.e. "$envSystemDrive\" not "$envSystemDrive" or "c:"
Copy-File -Path "$dirFiles\client_1" -Destination "C:\oracle\product\11.2.0\" -Recurse

## ***To delete a file or shortcut***
Remove-File -Path "$envCommonDesktop\GeoGraphix Seismic Modeling.lnk"

## Remove a bunch of specific files
"$envCommonDesktop\Example 1.lnk", <# Example #>`
"$envCommonDesktop\Example 2.lnk", <# Example #>`
"$envCommonDesktop\Example 3.lnk" <# Careful with the last item to not include a comma after the double quote #>`
| % { Remove-File -Path "$_" }

## Remove a bunch of specific folders and their contents
"$envSystemDrive\Example Dir1",  <# Example #>`
"$envProgramFiles\Example Dir2",  <# Example #>`
"$envProgramFiles\Example Dir3",  <# Example #>`
"$envProgramFilesX86\Example Dir4",  <# Example #>`
"$envSystemRoot\Example4" <# Careful with the last item to not include a comma after the double quote #>``
| % { Remove-Folder -Path "$_" }

## Remove a bunch of specific folders, only if they're empty
<# Use this by specifying folders from "deepest folder level" to "most shallow folder level" order e.g.
c:\program files\vendor\app\v12\junk - then 
c:\program files\vendor\app\v12 - then
c:\program files\vendor\app - then
c:\program files\vendor
using the above example, it will only remove c:\program files\vendor if every other folder above is completely empty. 
if for example v11 was also installed, it would stop prior #>
(
    "$envProgramFiles\vendor\app\v12\junk",
    "$envProgramFiles\vendor\app\v12",
    "$envProgramFiles\vendor\app",
    "$envProgramFiles\vendor",
    "$envProgramFilesX86\vendor\app\v12\junk",
    "$envProgramFilesX86\vendor\app\v12",
    "$envProgramFilesX86\vendor\app",
    "$envProgramFilesX86\vendor" <# careful not to include the comma after the double quotes in this one #>
) | % { if (!(Test-Path -Path "$_\*")) { Remove-Folder -Path "$_" } }
    # for each piped item, if the folder specified DOES NOT have contents ($folder\*), remove the folder 

## Import a certificate to system 'Trusted Publishers' store.. helpful for clickOnce installers & importing drivers
# (for references sake, I saved as base64, unsure if DER encoded certs work)
Execute-Process -Path "certutil.exe" -Parameters "-f -addstore -enterprise TrustedPublisher `"$dirFiles\certname.cer`""
Write-Log -Message "Imported Cert" -Source $deployAppScriptFriendlyName

## Import a driver (note, >= win7 must be signed, and cert must be in trusted publishers store) 
Execute-Process -Path 'PnPutil.exe' -Parameters "/a `"$dirFiles\USB Drivers\driver.inf`""

## Register a DLL module
Execute-Process -FilePath "regsvr32.exe" -Parameters "/s `"$dirFiles\example\codec.dll`""

## Make an install marker reg key for custom detections
#for e.g. below would create something like:
#HKLM:\SOFTWARE\PSAppDeployToolkit\InstallMarkers\Microsoft_KB2921916_1.0_x64_EN_01
Set-RegistryKey -Key "$configToolkitRegPath\$appDeployToolkitName\InstallMarkers\$installName"


## While loop pause (incase app installer exits immediately)
#pause until example reg key
While(!(test-path -path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{product-code-hereD}")) {
                sleep 5;
                Write-Log -Message "$appVendor - $appName - $appVersion is still not finished installing, sleeping another 5" -Source $deployAppScriptFriendlyName;
}
#pause until example file
While(!(test-path -path "$envCommonDesktop\Example Shortcut.lnk")) {
                sleep 5;
                Write-Log -Message "$appVendor - $appName - $appVersion is still not finished installing, sleeping another 5" -Source $deployAppScriptFriendlyName;
}

##***To Create a shortcut***
New-Shortcut -Path "$envCommonStartMenuPrograms\My Shortcut.lnk" `
    -TargetPath "$envWinDir\system32\notepad.exe" `
    -Arguments "--example-argument --example-argument-two" `
    -Description 'Notepad' `
    -WorkingDirectory "$envHomeDrive\$envHomePath"

## Modify ACL on a file
#first load the ACL
$acl_to_modify = "$envProgramData\Example\File.txt"
$acl = Get-Acl "$acl_to_modify"
#add another entry to the ACL list (in this case, add all users to have full control)
$ar = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users", "FullControl", "None", "None", "Allow")
$acl.SetAccessRule($ar)
#re-write the acl on the target file
Set-Acl "$acl_to_modify" $acl

## Modify ACL on a folder
$folder_to_change = "$envSystemDrive\Example_Folder"
$acl = Get-Acl "$folder_to_change"
$ar = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($ar)
Set-Acl "$folder_to_change" $acl  

## Add to environment variables (specifically PATH in this case)
# The first input in the .NET code can have Path subtituted for any other environemnt variable name (gci env: to see what is presently set)
$path_addition = "C:\bin"
#add $path_addition to permanent system wide path
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $path_addition, "Machine")
#add $path_addition to permanent user specific path
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $path_addition, "User")
#add $path_addition to the process level path only (i.e. when you quit script, it will no longer be applied)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $path_addition, "Process")


#.NET 4.x comparison/install
$version_we_require = [version]"4.5.2"
$version_we_want_path = "$dirFiles\NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
$install_params = "/q /norestart"
if((Get-RegistryKey "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Value Version) -lt $version_we_require) {
    Write-Log -Source $deployAppScriptFriendlyName -Message ".NET version is < [string]$version_we_require, installing"
    Execute-Process -Path "$version_we_want_path" -Parameters "$install_params" -WaitForMSIExec:$true
}

#exit codes for reboot required
#soft reboot <- will not 'force' restart, and sccm will progress past, but will nag to restart afterward
Exit-Script -ExitCode 3010
#hard reboot <- does not 'force' restart, but sccm won't proceed past any pre-reqs without reboot
Exit-Script -ExitCode 1641

##Create Active Setup to run once per user, and run an arbitrary executable as the user
# *WARNING* this really isn't a recommended method for a number of reasons.
# 1. You must logoff a logged in user for them to run this
# 2. Activesetup is not syncronous and will hold up the user login process until the command completes
# If the executable requests user input you can prevent logins
# 3. It's slow
# You're better off using a scheduled task, or capturing what the executable does and doing it another way

Copy-File -Path "$dirFiles\Example.exe" -Destination "$envProgramData\Example"
Set-ActiveSetup -StubExePath "$envProgramData\Example\Example.exe" `
    -Description 'AutoDesk BIM Glue install' `
    -Key 'Autodesk_BIM_Glue_Install' `
    -ContinueOnError:$true

## Create an activesetup to run once per user, to import a .reg file
# *WARNING* this really isn't a recommended method for a number of reasons.
# 1. You must logoff a logged in user for them to run this
# 2. Activesetup is not syncronous and will hold up the user login process until the command completes
# If the executable requests user input you can prevent logins
# 3. It's slow
# You're better off using a scheduled task, or capturing what the executable does and doing it another way

Copy-File -Path "$dirFiles\many_registry_keys_for_app_x.reg" -Destination "$envProgramData\Hidden\Path"
Set-ActiveSetup -StubExePath "reg.exe IMPORT `"$envProgramData\Hidden\Path\many_registry_keys_for_app_x.reg`"" `
    -Description 'My undesirable way of applying registry keys' `
    -Key 'Undesirable_Reg_keys' `
    -ContinueOnError:$true

## function to assist finding uninstall strings, msi codes, display names of installed applications
# paste into powershell window (or save in (powershell profile)[http://www.howtogeek.com/50236/customizing-your-powershell-profile/]
# usage once loaded: 'Get-Uninstaller chrome'
function Get-Uninstaller {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Name
  )
 
  $local_key     = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
  $machine_key32 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
  $machine_key64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
 
  $keys = @($local_key, $machine_key32, $machine_key64)
 
  Get-ItemProperty -Path $keys -ErrorAction 'SilentlyContinue' | ?{ ($_.DisplayName -like "*$Name*") -or ($_.PsChildName -like "*$Name*") } | Select-Object PsPath,DisplayVersion,DisplayName,UninstallString,InstallSource,InstallLocation,QuietUninstallString,InstallDate
}
## end of function

        ##*===============================================
		##* END: PSADT-Cheatsheet.ps1
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================

        ##*===============================================
		##* START:
		##*===============================================


        ##*===============================================
		##* END:
		##*===============================================



I have discussed this internally and below is the recommendations from Palo Alto
As a best practice the below steps when upgrading or installing GlobalProtect App via SCCM.

Important notes:
•	It is always recommended to first uninstall before upgrading GlobalProtect using SCCM because:
•	Uninstalling the GlobalProtect can also add time control over PanGPS’s removal which may not be available in msi-based uninstallation
•	If you are doing an upgrade within the same version such as from GlobalProtect 5.2.8 to 5.2.8-HF then in such case GlobalProtect uninstallation is required as GlobalProtect version is recognized by the first 3 numbers which will be the same in this case causing upgrade issues if GlobalProtect was not uninstalled first.
•	Please be sure the old package and new package are in the folder running the script (GlobalProtect64_old.msi, GlobalProtect64_new.msi):

To stop the existing GlobalProtect PanGPS Service: 
1. Stop PanGPS before uninstalling the old version and ensure that the old PanGPS version is stopped. 
Below is a sample script that STOPS the PanGPS process and checks every 3 seconds for 5 minutes to ensure that the PanGPS process is stopped. (This script needs to be executed with Elevated Privileges) 

set /a _count=0
"C:\WINDOWS\system32\sc.exe" stop pangps > null
:loop
if %_count% GTR 300 goto exittimeout
"C:\WINDOWS\system32\timeout.exe" /t 3 /nobreak > null
set /a _count=_count + 3
"C:\WINDOWS\system32\sc.exe" query pangps | find "STOPPED"
if %errorlevel% equ 1 goto loop
goto normalexit
:exittimeout
echo %date% %time% - PanGPS service cannot be stopped. time out 300. >> "C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPS.log"
:normalexit

2. Uninstalling Existing GlobalProtect: 
Uninstall the existing GlobalProtect App.
msiexec.exe /x GlobalProtect64_old.msi /qn KEEPREGISTRIES=”yes”

Note: The msi properties are case sensitive. Hence all msi parameters should be capitalized when used.
3. Double Checking GlobalProtect PanGPS Service Stopped:
Wait and check if PanGPS service exists (existing means custom action is not done)before installation to let all uninstallation custom actions to finish.
set /a _cnt=0
:loop2
if %_cnt% GTR 120 goto exittimeout
"C:\WINDOWS\system32\timeout.exe" /t 1 /nobreak > null
set /a _cnt=_cnt + 1
"C:\WINDOWS\system32\sc.exe" query pangps | find "WIN32_OWN_PROCESS"
if %ERRORLEVEL% EQU 0 goto loop2
:exittimeout
Installing New GlobalProtect:
Install the new GlobalProtect App. 
msiexec.exe /i GlobalProtect64_new.msi /qn /norestart

Note: GlobalProtect Portal can be pre-deployed at this stage by adding PORTAL=“portal1.paloaltonetworks.com”
4. Check New GlobalProtect PanGPS Service Started & Running:
Please check whether PanGPS is running or not, check for a maximum of 5 minutes.
set /a _count=0
:loop3
if %_count% GTR 300 goto exittimeout3
"C:\WINDOWS\system32\timeout.exe" /t 3 /nobreak > null
set /a _count=_count + 3
"C:\WINDOWS\system32\sc.exe" query pangps | find "RUNNING"
if %errorlevel% equ 1 goto loop3
echo installation completed!
goto final
:exittimeout3
echo %date% %time% - PanGPS service cannot start. time out 300. >> "C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPS.log"
:final


5. If GlobalProtect PanGPS Service Doesn’t Exist, Create One (Optional):
If PanGPS is not running, then use either of the below commands as Administrator to start the PanGPS process.
sc.exe create PanGPS binPath="C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPS.exe" start=auto
OR
PanGPS.exe -commit

I think this sets the baseline to modify the SCCM uninstall script, 
I tried running the STOP script (with elevated privileges) and I was able to uninstall GP with the proposed command

Please let me know if you have any questions

Kind regards
Alex Farinas

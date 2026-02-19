#########################################
#           Output to Log file          #
#########################################
$scriptName = $MyInvocation.MyCommand.Name
Start-Transcript -Path "C:\Apps\Tools\$scriptName.buildlog" -Append

#########################################
#           Disable Updates             #
#########################################
#Disable Windows Automatic Update
$regkeypath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$regkeyname = "NoAutoUpdate"
$regkeyvalue = "1"
New-ItemProperty -Path $regkeypath -Name $regkeyname -Value $regkeyvalue -PropertyType DWORD -Force | Out-Null

#########################################
#     Remove New Network Message        #
#########################################
New-Item -Path HKLM:\System\CurrentControlSet\Control\Network -Name NewNetworkWindowOff -Force | Out-Null

#########################################
#    Enable Verbos Status Message       #
#########################################
$regkeypath2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regkeyname2 = "verbosestatus"
$regkeyvalue2 = "1"
New-ItemProperty -Path $regkeypath2 -Name $regkeyname2 -Value $regkeyvalue2 -PropertyType DWORD -Force | Out-Null

#########################################
#        Clear AppLocker  Policy        #
#########################################
Set-AppLockerPolicy -XMLPolicy C:\apps\Tools\Configs\ClearAppLocker.xml -verbose
sc.exe config appidsvc start= auto

#########################################
#     Remove Old Sysprep Log Files      #
#########################################
if((Test-Path "$ENV:WINDIR\System32\SysPrep\Panther\setupact.log") -eq $true) {
    Remove-Item -Path "$ENV:WINDIR\System32\SysPrep\Panther\setupact.log" -Force
    }
if((Test-Path "$ENV:WINDIR\System32\SysPrep\Panther\setuperr.log") -eq $true) {
    Remove-Item -Path "$ENV:WINDIR\System32\SysPrep\Panther\setuperr.log" -Force
    }

#########################################
#        Image Creation Time            #
#########################################
New-Item -Path HKLM:\Software -Name AVD_Image_Version -Force | Out-Null
[String]$imagedate = get-date -Format "dd/MM/yyyy HH:mm"
New-ItemProperty -Path HKLM:\\Software\AVD_Image_Version  -Name CreationDate -Value $imagedate -PropertyType String -Force | Out-Null
New-ItemProperty -Path HKLM:\\Software\AVD_Image_Version  -Name Creator -Value AzureDevOps_Packer -PropertyType String -Force | Out-Null

#########################################
#              Run BIS-F                #
#########################################
# Copy some fixed files - fix for sysprep/avd - $Global:ImageSW = $false
#Copy-Item -Path C:\Apps\Tools\Configs\BISF.psm1  -Destination "C:\Program Files (x86)\Base Image Script Framework (BIS-F)\Framework\SubCall\Global\BISF.psm1" -Force
Write-Host $(Get-Date -Format HH:mm:ss:) "run SysPrep`n"
Wait-Event -Timeout 5
Start-Process "C:\Program Files (x86)\Base Image Script Framework (BIS-F)\PrepareBaseImage.cmd" -NoNewWindow
#Start-Process PowerShell -Verb runAs -ArgumentList "-file C:\Program Files (x86)\Base Image Script Framework (BIS-F)\Framework\PrepBISF_Start.ps1"
Wait-Event -Timeout 5

Stop-Transcript

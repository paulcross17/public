#########################################
#           Output to Log file          #
#########################################
New-Item -Path "C:\_BUILD\SYSPREP_Test" -ItemType Directory -Force | Out-Null

$scriptName = $MyInvocation.MyCommand.Name
Start-Transcript -Path "C:\_BUILD\SYSPREP_Test\$scriptName.buildlog" -Append

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
#        Run SysPrep                    #
#########################################
#$SysPrepPath = "$ENV:WINDIR\System32\Sysprep\sysprep.exe"
#$SysPrepArgs = "/oobe /generalize /shutdown"   
#Start-Process -FilePath $SysPrepPath -ArgumentList $SysPrepArgs -Wait


Stop-Transcript

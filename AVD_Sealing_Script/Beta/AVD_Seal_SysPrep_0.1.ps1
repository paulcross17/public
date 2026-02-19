
function Clear-SysPrepLogs {
    Write-Host "Clear-SysPrepLogs Called"

    if ((Test-Path "$ENV:WINDIR\System32\SysPrep\Panther\setupact.log") -eq $true) {
        Remove-Item -Path "$ENV:WINDIR\System32\SysPrep\Panther\setupact.log" -Force
    }
    if ((Test-Path "$ENV:WINDIR\System32\SysPrep\Panther\setuperr.log") -eq $true) {
        Remove-Item -Path "$ENV:WINDIR\System32\SysPrep\Panther\setuperr.log" -Force
    }
}
function Recursive-SysPrep-AppX-Tidy {
    Write-Host "Recursive-SysPrep-AppX-Tidy Called"

    Run-SysPrep
    Write-Host "Sleep for 15 seconds to allow SysPrep to start and error if problem AppX packages are present" -ForegroundColor DarkYellow
    Start-Sleep -Seconds 15
    Remove-AppXPackages
}
function Run-SysPrep {
    Write-Host "Run-SysPrep Called"

    $SysPrepPath = "$ENV:WINDIR\System32\Sysprep\sysprep.exe"
    $SysPrepArgs = "/oobe /generalize /shutdown"   
    Start-Process -FilePath $SysPrepPath -ArgumentList $SysPrepArgs

}
function Remove-AppXPackages {

    Write-Host "Remove_AppXPackages Called"

    # Path to Sysprep's setupact.log
    $logPath = "C:\Windows\System32\Sysprep\Panther\setupact.log"

    # Pattern to detect problematic AppX packages
    $pattern = "SYSPRP Package (.*?) was installed for a user"

    # Extract and shorten AppX package names
    $matches = Select-String -Path $logPath -Pattern $pattern | ForEach-Object {
        if ($_ -match $pattern) {
            $fullName = $matches[1]
            $shortName = $fullName.Split('_')[0]
            $shortName
        }
    }

    if (-not $matches) {
        Write-Host "No problematic AppX packages detected in the log." -ForegroundColor Green
        return
    }
    else {
    
        # Remove duplicates
        $badApps = $matches | Sort-Object -Unique

        # Display detected AppX packages
        Write-Host ""
        Write-Host "Detected problematic AppX packages:"
        foreach ($app in $badApps) {
            Write-Host " - $app"
        }

        # Remove AppX packages for all users and from the system
        foreach ($app in $badApps) {
            Write-Host ""
            Write-Host "Removing: $app"
            Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }

        Recursive-SysPrep-AppX-Tidy 
    }
}

#########################################
#           Output to Log file          #
#########################################
New-Item -Path "C:\_BUILD\SYSPREP_Test" -ItemType Directory -Force | Out-Null

$scriptName = $MyInvocation.MyCommand.Name
Start-Transcript -Path "C:\_BUILD\SYSPREP_Test\$scriptName.buildlog" -Append

#########################################
#        Run DelProf2                   #
#########################################
$DelProf2Path = "$ENV:WINDIR\System32\DelProf2.exe"
$DelProf2Args = "/u"  
Start-Process -FilePath $DelProf2Path -ArgumentList $DelProf2Args -Wait

#########################################
#        Run SysPrep                    #
#########################################

#Recursive-SysPrep-AppX-Tidy 

Stop-Transcript

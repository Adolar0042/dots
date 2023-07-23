$oldTitle = $Host.UI.RawUI.WindowTitle
$Host.UI.RawUI.WindowTitle = "Windows Repair Tool"

function Invoke-Elevated {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ScriptBlock,
        [switch]$Wait
    )
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Start-Process powershell.exe "-ExecutionPolicy Bypass -Command & { $ScriptBlock }" -Verb RunAs -Wait:$Wait
    }
    else {
        & $ScriptBlock
    }
}
if (!(Get-InstalledModule -Name PSMenu -ErrorAction SilentlyContinue)) {
    Write-Host "Installing PSMenu Module, this is a necessary dependency of the tool ..."
    Install-Module PSMenu -ErrorAction Stop
}
Write-Host "Select the repair options you want to perform:`r`n"
$ans = Show-Menu -MenuItems @("SFC", "DISM Check", "DISM Scan", "DISM Restore") -MultiSelect -ReturnIndex
# check if the user selected any options and if so, create a script block to run the selected options in elevated mode
if ($ans.Count -gt 0) {
    if($ans -contains 0) {
        Invoke-Elevated -ScriptBlock {
            Write-Host "Running SFC ..."
            Write-Host ($Host | ConvertTo-Json)
            #Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
            sfc /scannow
            #Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
            Write-Host "SFC completed, press any key to exit ..."
            Read-Host | Out-Null
        }
    }
    if($ans -contains 1) {
        Invoke-Elevated -ScriptBlock {
            Write-Host "Running DISM Check ..."
            Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
            dism /online /cleanup-image /checkhealth
            Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
            Write-Host "DISM Check completed, press any key to exit ..."
            Read-Host | Out-Null
        }
    }
    if($ans -contains 2) {
        Invoke-Elevated -ScriptBlock {
            Write-Host "Running DISM Scan ..."
            Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
            dism /online /cleanup-image /scanhealth
            Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
            Write-Host "DISM Scan completed, press any key to exit ..."
            Read-Host | Out-Null
        }
    }
    if($ans -contains 3) {
        Invoke-Elevated -ScriptBlock {
            Write-Host "Running DISM Restore ..."
            Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
            dism /online /cleanup-image /restorehealth
            Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
            Write-Host "DISM Restore completed, press any key to exit ..."
            Read-Host | Out-Null
        }
    }
}
else {
    Write-Host "No options selected, exiting."
}

$Host.UI.RawUI.WindowTitle = $oldTitle

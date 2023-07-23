# Author: Adolar0042
# Description: This script will install most of the programs and tools I use on a new Windows machine.

# Restart this script in elevated mode if this user is not an administrator.
# ULTRA SUPER NON POWERSHELL-LIKE CODE AHEAD
# -------------------------------------------------------------------------
[Threading.Thread]::GetDomain().SetPrincipalPolicy([Security.Principal.PrincipalPolicy]::WindowsPrincipal)
$thread_security_principal = `
  [Security.Principal.WindowsPrincipal]([Threading.Thread]::CurrentPrincipal)
if ( -NOT $thread_security_principal.IsInRole("Administrators") ) {
    Write-Host "Restarting in elevated mode..." -ForegroundColor Yellow
    $argv = @($MyInvocation.MyCommand.Definition) + $args
    start-process "powershell.exe" -Arg $argv -Verb RunAs
    exit 2
}

$rawRepoUrl = "https://raw.githubusercontent.com/Adolar0042/dots/main"

Write-Host "Installing Cascadia Code Nerd Font ..."
Invoke-WebRequest "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip" -OutFile "$($env:TEMP)\CascadiaCode.zip"
Expand-Archive -Path "$($env:TEMP)\CascadiaCode.zip" -DestinationPath "$($env:TEMP)\CascadiaCode" -Force
foreach ($file in Get-ChildItem -Path "$($env:TEMP)\CascadiaCode" -Filter "*.ttf") {
    Copy-Item -Path $file.FullName -Destination "$($env:windir)\Fonts" -Force
}
Write-Host "Configuring Windows Terminal..."
Invoke-RestMethod -Uri "$rawRepoUrl/settings.json" -OutFile "$($env:LOCALAPPDATA)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

Write-Host "Installing Powershell Profile ..."
Invoke-RestMethod -Uri "$rawRepoUrl/user_profile.ps1" -OutFile "$($env:USERPROFILE)\.config\PowerShell\user_profile.ps1"
New-Item -Path $PROFILE -Value '. "$env:USERPROFILE\.config\PowerShell\user_profile.ps1"' 
Invoke-RestMethod -Uri "$rawRepoUrl/subscripts/Windows-Repair-Tool.ps1" -OutFile "$($env:USERPROFILE)\.config\PowerShell\subscripts\Windows-Repair-Tool.ps1"

Write-Host "Installing Chocolatey ..."
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Write-Host "Installing sudo ..."
choco install sudo -y

Write-Host "Installing Starship ..."
winget install --id Starship.Starship
Write-Host "Configuring Starship ..."
Invoke-RestMethod -Uri "$rawRepoUrl/starship.toml" -OutFile "$($env:USERPROFILE)\.config\starship.toml"
Write-Host "Note: You need to restart your terminal to see the changes."

Write-Host "Installing Git ..."
winget install --id Git.Git -e --source winget

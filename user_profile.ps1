#Author: Adolar0042
#Description: Profile script for PowerShell

# Alias
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias nano 'C:\Program Files\Nano\pkg_x86_64-w64-mingw32\bin\nano.exe'
Set-Alias lg lazygit

# Misc
# Nothin' here yet ¯\_( ͡° ͜ʖ ͡°)_/¯

#Region Functions
Function gh {
    Set-Location "E:\Programming\Github"
}
Function home {
    Set-Location $HOME
}
Function Format-Hyperlink {
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Uri] $Uri,
  
        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Label
    )
  
    if (($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) -and -not $Env:WT_SESSION) {
        # Fallback for Windows users not inside Windows Terminal
        if ($Label) {
            return "$Label ($Uri)"
        }
        return "$Uri"
    }
  
    if ($Label) {
        return "`e]8;;$Uri`e\$Label`e]8;;`e\"
    }
  
    return "$Uri"
}
Function repos {
    try {
        $repos = Get-ChildItem -Path "$env:USERPROFILE\Desktop\Github" -ErrorAction Stop
        $repos += Get-ChildItem -Path "E:\Programming\GitHub" -ErrorAction Stop
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red 
        break
    }
    $repos | ForEach-Object {
        if (Test-Path "$_\.git") {
            $info = Get-Content -Path "$($_.FullName)\.git\config" -ErrorAction SilentlyContinue
            $url = $info | Where-Object { $_ -like '*url = *' }
            $url = $url.Split(' = ')[1]
            $repo = $url -replace 'https://github.com/'

            Write-Host "`e[32m`e[0m " -ForegroundColor Gray -NoNewline
            Write-Host (Format-Hyperlink -Uri $url -Label $repo) -ForegroundColor Green
            Write-Host "  `e[32m`e[0m " -ForegroundColor Gray -NoNewline
            Write-Host (Format-Hyperlink -Uri $_.FullName -Label $_.FullName) -ForegroundColor Gray
            Write-Host "  `e[32m`e[0m $url`r`n" -ForegroundColor Gray
        }
        else {
            Write-Host "`e[32m`e[0m " -ForegroundColor Gray -NoNewline
            Write-Host "$($_.Name) [NO .git]" -ForegroundColor Yellow
            Write-Host "  `e[32m`e[0m " -ForegroundColor Gray -NoNewline
            Write-Host (Format-Hyperlink -Uri $_.FullName -Label $_.FullName)"`r`n" -ForegroundColor Gray
        }
    }
}
function clone {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidatePattern('^(https|http|git):\/\/github.com\/.*\/.*')]
        [string] $url,
        [Parameter(Position = 1)]
        [string] $branch = 'Default'
    )
    #TODO Add support for other git hosts and branches  
    begin {
        $filename = $url.Split("/")[$url.Split("/").Count - 1]
    }
    process {
        Write-Host "Cloning $filename branch $branch to ""E:\Programming\Github\$filename""" -ForegroundColor Blue
        if ($branch -eq "Default") { git clone $url "E:\Programming\Github\$filename" }
        else { git clone $url "E:\Programming\Github\$filename" -b $branch }
    }
    end {
        Invoke-Item "E:\Programming\Github\$filename"
    }
}
Function unclone([STRING]$url) {
    #TODO Make file path dynamic
    $filename = $url.Split("/")[$url.Split("/").Count - 1]
    $ans = $null
    Do {
        Write-Host "Do you want to delete the folder ""E:\Programming\Github\$filename""? " -ForegroundColor Red -NoNewline
        $ans = Read-Host "[Y/N]"
    } While ($ans -notin @("Y", "y", "N", "n"))
    if ($ans -in @("Y", "y")) {
        Write-Host "Deleting ""E:\Programming\Github\$filename""" -ForegroundColor Blue
        Remove-Item "E:\Programming\Github\$filename" -Recurse -Force
    }
    else { Write-Host "Aborted" -ForegroundColor Red }
}
Function Measure-Command {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [scriptblock] $ScriptBlock
    )
    begin {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
    }
    process {
        & $ScriptBlock
    }
    end {
        $sw.Stop()
        [PSCustomObject]@{
            Time   = [STRING](Convert-Stopwatch $sw)
            # Return Result if it's not null
            Result = $_
        }
    }
}
Function Convert-Stopwatch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [System.Diagnostics.Stopwatch] $Stopwatch
    )
    begin {
        $sw = $Stopwatch
    }
    process {
        $TotalSeconds = $sw.Elapsed.TotalSeconds
        if ($TotalSeconds -gt 60) {
            $TotalMinutes = $TotalSeconds / 60
            if ($TotalMinutes -gt 60) {
                $TotalHours = $TotalMinutes / 60
                if ($TotalHours -gt 24) {
                    $TotalDays = $TotalHours / 24
                    return "$TotalDays d"
                }
                return "$TotalHours h"
            }
            return "$TotalMinutes min"
        }
        return "$TotalSeconds s"
    }
    end {
        return $_
    }
}
function RepairCLI {
    . "$env:USERPROFILE\.config\powershell\subscripts\Windows-Repair-Tool.ps1"
}
function Enable-Win {
    Invoke-RestMethod https://massgrave.dev/get | Invoke-Expression
}
Function Get-Functions {    
    $functions = @()
    $functions += [PSCustomObject]@{
        Name        = "home"
        Description = "Go to home directory"
    }
    $functions += [PSCustomObject]@{
        Name        = "gh"
        Description = "Go to Github directory"
    }
    $functions += [PSCustomObject]@{
        Name        = "repos"
        Description = "List all repositories in ""~\Desktop\Github"""
    }
    $functions += [PSCustomObject]@{
        Name        = "clone"
        Description = "Clone a repository"
    }
    $functions += [PSCustomObject]@{
        Name        = "unclone"
        Description = "Delete a repository"
    }
    $functions += [PSCustomObject]@{
        Name        = "Measure-Command"
        Description = "Measure the time of a command"
    }
    $functions += [PSCustomObject]@{
        Name        = "Convert-Stopwatch"
        Description = "Convert a stopwatch to a string with a suitable unit"
    }
    $functions += [PSCustomObject]@{
        Name        = "RepairCLI"
        Description = "Run the repair script"
    }
    $functions += [PSCustomObject]@{
        Name        = "Get-Functions"
        Description = "List all functions"
    }
    # print the functions with good formatting
    $functions | Format-Table -AutoSize
}
function util {
    Invoke-RestMethod "christitus.com/win" | Invoke-Expression
}
# inline color formatting: https://www.alant.de/sonstiges1/tips-und-tricks/iexplorer/373-farbschema-für-die-echo-ausgabe-in-der-linux-bash.html
# https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences

function Add-ToPath ($file) {
    $env:path += ";$file"
}

function find-file {
    [Alias("ff")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string] $name
    )
    Get-ChildItem -recurse —filter "*${name}*" —ErrorAction SilentlyContinue | ForEach-Object {
        $item = Get-Item $_
        if ($item.ToString().Length -gt 100) {
            $dir = $item.ToString().Split('\')[-5..-1] -join '\'
        }
        else {
            $dir = $item.ToString()
        }
        if ($item.Attributes.ToString().Split(', ') -contains "Directory") {
            $dir = $dir -replace $name, "`e[30m`e[42m$name`e[0m"
            Write-Host " $(Format-Hyperlink -Uri $item.ToString() -Label $dir)`r`n"
        }
        else {
            $itemName = $dir -replace $name, "`e[30m`e[42m$name`e[0m"
            Write-Host " $(Format-Hyperlink -Uri $item.Directory.ToString() -Label $itemName)`r`n"
        }
        Remove-Variable dir
        Remove-Variable item
    }
    Write-Host "`a" -NoNewline
}
#Endregion Functions
#Region Prompt
Import-Module posh-git
Invoke-Expression (& starship init powershell --print-full-init | Out-String)

# PSReadLine
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

#$ErrorActionPreference = 'Stop'
#EndRegion Prompt
<#
Taking Control of PowerShell Profile Scripts
PowerShell Saturday Chattanooga 2018
Tim Warner (@TechTrainerTim)
#>

$profile | Get-Member -MemberType NoteProperty | Select-Object -Property Name, Definition | Format-List
cl
if (!(Test-Path -Path $profile.CurrentUserAllHosts))
{New-Item -ItemType File -Path $profile -Force}

$a = (Get-Host).UI.RawUI
$a.BackgroundColor = 'DarkBlue'
$a.ForegroundColor = 'Yellow'
Clear-Host
$a.WindowTitle = "PowerShell Desktop " + (Get-Host).Version

$buffer = $console.BufferSize
$buffer.Width = 80
$buffer.Height = 5000
$console.BufferSize = $buffer

$size = $console.WindowSize
$size.Width = 80
$size.Height = 25
$console.WindowSize = $size

New-Item alias:np -value "C:\Windows\System32\notepad.exe"
New-Item alias:st -value "C:\Program Files\Sublime Text 3\sublime_text.exe"

(Get-Command –Name Prompt).ScriptBlock

function prompt {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity

    $(if (test-path variable:/PSDebugContext) { '[DBG]: ' }
        elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) { "[ADMIN]: " }
        else { '' }
    ) + 'PS ' + $(Get-Location) +
    $(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '
}

function Get-Uptime {
    $os = Get-WmiObject win32_operatingsystem
    $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
    $Display = "Uptime: " + $Uptime.Days + " days, " + $Uptime.Hours + " hours, " + $Uptime.Minutes + " minutes"
    Write-Output $Display
}
Clear-Host
Get-Uptime

Connect-AzureRmAccount -Subscription 'Microsoft Azure Sponsorship' -Credential (BetterCredentials\Get-Credential -username 'tim@timw.info')

$s = New-PSSession `  –ComputerName srv1 `  –Credential (Get-Credential)

Invoke-Command –Session $s –FilePath $profile

Invoke-Command -Session $s -ScriptBlock {. "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"}

$ScriptFromGitHub = Invoke-WebRequest –Uri https://raw.githubusercontent.com/tomarbuthnot/Run-PowerShell-Directly-From-GitHub/master/Run-FromGitHub-SamplePowerShell.ps1
Add-Content -Path $profile -Value $($ScriptFromGitHub.Content)

# For authenticated Gists
Install-Module –Name PSGist –Repository PSGallery –Verbose
Get-Command –Module PSGist


az
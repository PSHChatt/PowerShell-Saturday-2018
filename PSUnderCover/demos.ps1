Write-Warning "This is a walk through demo."
return


#region Write-Progress

$i = 1..100
$i | foreach -Begin {$count = 0} -process {
$count++
write-progress -Activity "This is Write-Progress" -Status "Calculating" `
-CurrentOperation "processing $_" -PercentComplete $(($count/$i.count)*100)
start-sleep -Milliseconds 100

}
#try in the console

#change the color in the console host
$host.privatedata

#use in code
psedit .\New-HVHealthReport.ps1
#run in the console
.\New-HVHealthReport.ps1 -path c:\work\hvreport.html
#if you want to see the file
# start c:\work\hvreport.html

#use as a graphing tool
psedit .\Show-VMMemoryPressure.ps1

#run these together 
icm { $all = dir c:\ -file -Recurse -ErrorAction SilentlyContinue} -computername dom1 -asjo
icm {get-aduser -filter * -property * | export-clixml c:\users.xml} -computername dom1 -asjob
Show-VMMemoryPressure -VMName Dom1 -MaxSamples 20 -Interval 2

#Fun stuff
# Install-Module PSTimers

start-pscountdown -Minutes 1 -Message "Waiting for the bar to open"
cls
#endregion

#region PSDefaultParameterValues

#clear anything I might have running from my profile
$PSDefaultParameterValues.Clear()

$PSDefaultParameterValues.add("get-ciminstance:classname","Win32_Operatingsystem")
get-ciminstance
#unless
get-ciminstance win32_bios

#alternative
$PSDefaultParameterValues["Write-Host:Foregroundcolor"]="green"
write-host "I am the walrus"

#set for an entire group of commands
$PSDefaultParameterValues.Add("*-AD*:server","DOM1")
$adcred = Get-Credential company\artd
$PSDefaultParameterValues.Add("*-AD*:credential",$adcred)
get-addomain
get-aduser artd

#just a hashtable
$PSDefaultParameterValues
$PSDefaultParameterValues.Remove("get-ciminstance:classname")
#you can disable them
$PSDefaultParameterValues.disabled = $True
write-host "back to normal"
#re-enable
$PSDefaultParameterValues.disabled = $false #or delete it
write-host "back to enabled"

#use in a script - with caution
psedit .\SystemReport-markdown.ps1
.\SystemReport-markdown.ps1 -Computername SRV4
help about_Parameters_Default_Values

#endregion

#region Be Verbose

psedit .\HelpDesk\functions.ps1
psedit .\CreateVolumeReport.ps1

cls
.\CreateVolumeReport.ps1 -Path c:\work\vols.html -Verbose

#be verbose with verbose
#look at my meta information

#endregion

#region Trace-Command

help trace-command -online

Get-TraceSource

help trace-command -Examples
cls
Trace-Command -Name metadata,parameterbinding,cmdlet -Expression { 'bits','winrm' | Get-Service -ComputerName srv1 } -PSHost

Trace-Command -Name * -Expression { Get-Process power*,foo } -FilePath c:\work\trace.txt
psedit c:\work\trace.txt 

#endregion

#region Leveraging PSReadline

#mostly console only

Get-module psreadline
get-command -module psreadline
#searching command history
#key bindings


#endregion


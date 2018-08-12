
param(
[string]$Title = "System Configuration Report",
[string]$Computername = $env:COMPUTERNAME,
[ValidatePattern('\.md$')]
[string]$Filepath = "SystemReport.md"
)

. C:\scripts\Convertto-Markdown.ps1

$savedPV = $PSDefaultParameterValues.Clone()
$PSDefaultParameterValues.Clear()
$PSDefaultParameterValues.add("Get-Ciminstance:computername",$computername)
$PSDefaultParameterValues.add("Write-Host:foregroundcolor","cyan")

Write-Host "Creating system report for $($computername.toUpper())"

$pre = @"

This is a system configuration report for $($computername.toupper())
"@

$fragments = @()

$fragments+= ConvertTo-Markdown -Title $title -PreContent $pre

Write-Host "...computer system"
$prop = 'Manufacturer','Model','SystemFamily','SystemSKUNumber','SystemType','NumberOfLogicalProcessors','NumberofProcessors','TotalPhysicalMemory' 
$cs = Get-CimInstance Win32_Computersystem -ov c -Property $prop | Select-Object -Property $prop 

$class = ($c.cimclass.cimclassname.split("_")[1])
$fragments+= $cs | ConvertTo-Markdown -precontent "## $class"

Write-host "...volumes"
$vol = Get-CimInstance win32_volume -ov c| Select-Object Name,Label,Freespace,Capacity | Format-List
$class = ($c.cimclass.cimclassname.split("_")[1])
$fragments+= $vol | ConvertTo-Markdown -precontent "## $class"

write-host "...processor"
$cpu = Get-CimInstance win32_processor -ov c | 
Select-Object DeviceID,Name,Caption,MaxClockSpeed,*CacheSize,NumberOf*,SocketDesignation,*Width,Manufacturer
$class = ($c.cimclass.cimclassname.split("_")[1])
$fragments+= $cpu | ConvertTo-Markdown -PreContent "## $class"

write-host "...memory"
$mem = Get-CimInstance win32_physicalmemory -ov c| Select-Object BankLabel,Capacity,DataWidth,Speed
$class = ($c.cimclass.cimclassname.split("_")[1])
$fragments+= $mem | ConvertTo-Markdown -precontent "## $class"

write-host "...networkadapter"
$net = Get-NetAdapter -Physical -ov c | Select-Object Name,InterfaceDescription,LinkSpeed
$class="NetworkAdapter"
$fragments+= $net | ConvertTo-Markdown -precontent "## $class"

<#
#system drivers
$sysdrv = Get-CimInstance win32_systemdriver -ov c -filter "State='running'" | 
Select-Object Name,Description,State,StartMode,Started,Pathname,ServiceType | Sort State,Caption
$class = ($c.cimclass.cimclassname.split("_")[1])
$fragments+= $sysdrv | ConvertTo-Markdown -precontent "## $class"
#>

$fragments+= ConvertTo-Markdown -postcontent "_report run $(Get-Date)_"

write-host "saving file to $filepath"

$fragments | out-file -FilePath $filepath

#restore PSDefaultParameterValues
$PSDefaultParameterValues.clear()
$global:PSDefaultParameterValues = $savedPV
#requires -version 5.0
#requires -module Storage

#create a disk space report

#this version of the script includes Verbose output

[cmdletbinding()]
Param(
    #the name of the html file. Do not specify the path
    [string]$Path = "DiskReport.htm"
)

Write-Verbose "[$((Get-Date).Timeofday)] Starting $($myinvocation.mycommand)"
Write-Verbose "[$((Get-Date).Timeofday)] ****************************************************************"
Write-Verbose "[$((Get-Date).Timeofday)] Date     : $((Get-Date).ToShortDateString())"
Write-Verbose "[$((Get-Date).Timeofday)] User     : $($env:userdomain)\$($env:username)"
Write-Verbose "[$((Get-Date).Timeofday)] Computer : $env:computername"
Write-Verbose "[$((Get-Date).Timeofday)] OS       : $((Get-Ciminstance -classname win32_operatingsystem -property caption -verbose:$false).caption)"
Write-Verbose "[$((Get-Date).Timeofday)] Build    : $($psversiontable.buildVersion)"
Write-Verbose "[$((Get-Date).Timeofday)] PSVersion: $($PSVersionTable.PSVersion)"
Write-Verbose "[$((Get-Date).Timeofday)] PSEdition: $($PSVersionTable.PSEdition)"
Write-Verbose "[$((Get-Date).Timeofday)] Host     : $($host.name)"
Write-Verbose "[$((Get-Date).Timeofday)] IsAdmin  : $(Test-IsAdministrator)"
Write-Verbose "[$((Get-Date).Timeofday)] Storage  : $((Get-Module -Name Storage).version)"
Write-Verbose "[$((Get-Date).Timeofday)] ****************************************************************"

Write-verbose "[$((Get-Date).Timeofday)] Importing HelpDesk module"

#manually import the module because it isn't part of my
#usual %PSMODULEPATH% which you would use.
Import-Module $PSScriptRoot\helpdesk\helpdesk.psd1 -force

Write-Verbose "[$((Get-Date).Timeofday)] Importing domain computer list"
$Computername = $domaincomputers

Write-Verbose "[$((Get-Date).Timeofday)] Initializing fragments array"
$fragments = @("<h1>Company.pri</h1>")

$progParam = @{
    Activity         = "Domain Volume Report"
    Status           = "Querying domain members"
    Percentcomplete  = 0
    CurrentOperation = ""
}

Write-Verbose "[$((Get-Date).Timeofday)] Initialize a counter for the progress bar"
$i = 0

foreach ($computer in $Computername) {
    $i++
    $progParam.CurrentOperation = $Computer

    $progparam.percentcomplete = ($i / $computername.count) * 100
    Write-Progress @progParam

    Try {
        Write-Verbose "[$((Get-Date).Timeofday)] Querying $computer"

        #Verbose is not getting detected for my function so I have 
        #to be creative

        $disk = Get-volumeReport -computername $computer -Verbose:$($PSBoundParameters.ContainsKey("verbose"))
        Write-Verbose "[$((Get-Date).Timeofday)] Adding data to fragments"
        $fragments += "<H2>$($computer.toUpper())</H2>"
        $fragments += $disk | Select-object -property DriveLetter, HealthStatus,
        @{Name = "SizeGB"; Expression = {$_.size / 1gb -as [int]}},
        @{Name = "RemainingGB"; Expression = {$_.sizeremaining / 1gb }} |
            ConvertTo-Html

    }
    Catch {
        Write-warning "$_.Exception.message"
    }
} #foreach

If ($fragments.count -gt 0) {
    Write-Verbose "[$((Get-Date).Timeofday)] Creating HTML file $path"
    $head = @"
<title>Domain Volume Report</title>
<style>
Body {
font-family: "Tahoma", "Arial", "Helvetica", sans-serif;
background-color:#F0E68C;
}
table
{
border-collapse:collapse;
width:75%
}
td 
{
font-size:12pt;
border:1px #0000FF solid;
padding:2px 2px 2px 2px;
}
th 
{
font-size:14pt;
text-align:center;
padding-top:2px;
padding-bottom:2px;
padding-left:2px;
padding-right:2px;
background-color:#0000FF;
color:#FFFFFF;
}
name tr
{
color:#000000;
background-color:#0000FF;
}
h2
{
font-size:12pt;
}
</style>
"@

    $footer = @"
<h5><i>Run date: $(Get-Date)<br>
Computer: $env:computername<br>
Script: $((get-item $myinvocation.InvocationName).fullname.replace('\','\\'))</i></h5>
"@

    #define a hashtable of parameters to splat to ConvertTo-Html
    $cParams = @{
        Head        = $head
        Body        = $fragments 
        PostContent = $footer    
    }

    #create the HTML and save it to a file
    ConvertTo-Html @cParams | Out-File -FilePath $path -Encoding ascii
    Write-Host "See $path for your report." -ForegroundColor green 
}

Write-Verbose "[$((Get-Date).Timeofday)] Finishing $($myinvocation.MyCommand)"


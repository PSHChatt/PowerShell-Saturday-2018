

Function Show-VMMemoryPressure {
[cmdletbinding(DefaultParameterSetName="interval")]
Param(
[Parameter(Position = 0, Mandatory,HelpMessage = "Enter the name of a virtual machine")]
[alias("Name")]
[string]$VMName,
[Parameter(HelpMessage = "The name of the Hyper-V Host")]
[Alias("CN","vmhost")]
[string]$Computername = $env:computername,
[Parameter(HelpMessage = "The sample interval in seconds")]
[int32]$Interval = 5,
[Parameter(HelpMessage = "The maximum number of samples",ParameterSetName="interval")]
[ValidateScript({$_ -gt 0})]
[int32]$MaxSamples=2,
[Parameter(HelpMessage = "Take continuous measurements.",ParameterSetName="continous")]
[switch]$Continuous

)

Try {
    #verify VM
    Write-Verbose "Verifying $VMName on $Computername"
    $vm = Get-VM -ComputerName $Computername -Name $VMName -ErrorAction stop
    if ($vm.state -ne 'running') {
        $msg = "The VM {0} on {1} is not running. Its current state is {2}." -f $vmname.Toupper(),$Computername,$vm.state
        Write-Warning $msg
     }
    else {
        $counterparams = @{
            Counter = "Hyper-V Dynamic Memory VM($($vm.vmname))\Average Pressure" 
            ComputerName = $Computername 
            SampleInterval = $Interval
        }
        if ($Continuous) {
            $counterparams.Add("Continuous",$True)
        }
        else {
            $counterparams.Add("MaxSamples",$MaxSamples)
        }

        Write-Verbose "Getting counter data"
        $counterparams | Out-string | Write-Verbose
        Get-Counter @counterparams | foreach-Object {

        #scale values over 100
        $pct = ($_.CounterSamples.cookedvalue)*.8
        #if scaled value is over 100 then max out the percentage
        if ($pct -gt 100) {
            $pct = 100
        }

        $progparams = @{
            Activity = "Average Memory Pressure" 
            Status = $VM.vmname
            CurrentOperation = "Value: $($_.countersamples.cookedvalue) [$($_.Timestamp) ]" 
            PercentComplete = $pct
        }
        Write-Progress @progparams
        }

    } #else VM Verified
} #Try
Catch {
    Throw $_
} #Catch

}

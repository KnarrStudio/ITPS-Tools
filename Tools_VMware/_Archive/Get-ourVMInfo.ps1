function get-OurVMInfo{
[CmdletBinding()]
param(
    [Parameter(Mandatory,
                ValueFromPipeline,
                ValueFromPipelineByPropertyName)]
    [Alias('hostname')]
    [string[]]$computername,

[switch]$namelog
)
BEGIN {}
PROCESS {

foreach ($computer in $computername){
    Write-host $computer
}

}
END {}

}


Get-ourVMInfo -computername localhost
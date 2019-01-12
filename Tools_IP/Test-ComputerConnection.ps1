
$GoodCount = $BadCount = 0
$DateNow = Get-Date -UFormat %Y%m%d-%H%M
$ReportFile = ("$env:HOMEDRIVE\temp\{0}-Report.txt" -f $DateNow)


if(!(Test-Path "$env:HOMEDRIVE\Temp\SiteList.csv")){
    $ADSearchBase = 'OU=Clients-Desktop,OU=Computers,OU=SOUTH,DC=localdomain'
    get-adcomputer -filter * -SearchBase $ADSearchBase | select name | Export-Csv -Path "$env:HOMEDRIVE\Temp\SiteList.csv" -NoTypeInformation
    }

$WorkstationList = Import-Csv -Path "$env:HOMEDRIVE\Temp\SiteList.csv" -Header Name

foreach($OneWorkstation in $WorkstationList){
   $WorkstationName = $OneWorkstation.Name
   $Ping = Test-Connection $WorkstationName -Count 1 -Quiet
if($Ping -ne 'True'){
    $BadCount += 1
    $WorkstationProperties = Get-ADComputer -Identity $WorkstationName -Properties * | Select Name,LastLogonDate,Description
    if($BadCount -eq 1){
        $WorkstationProperties | export-csv $ReportFile -NoClobber -NoTypeInformation
    }
    else{
        $WorkstationProperties | Export-Csv $ReportFile -NoTypeInformation -Append
        }
    }
}

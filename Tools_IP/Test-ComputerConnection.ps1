
$WorkstationSiteList = "$env:HOMEDRIVE\Temp\SiteList.csv"
$GoodCount = 0
$BadCount = 0
$DateNow = Get-Date -UFormat %Y%m%d-%H%M
$ReportFile = ("$env:HOMEDRIVE\temp\{0}-Report.txt" -f $DateNow)


if(!(Test-Path -Path $WorkstationSiteList)){
   $ADSearchBase = 'OU=Clients-Desktop,OU=Computers,OU=SOUTH,DC=localdomain'
   get-adcomputer -filter * -SearchBase $ADSearchBase | Select-Object -ExpandProperty name | Export-Csv -Path $WorkstationSiteList -NoTypeInformation
}

$WorkstationList = Import-Csv -Path $WorkstationSiteList -Header Name

foreach($OneWorkstation in $WorkstationList){
   $WorkstationName = $OneWorkstation.Name
   $Ping = Test-Connection -ComputerName $WorkstationName -Count 1 -Quiet
   if($Ping -ne 'True'){
      $BadCount += 1
      $WorkstationProperties = Get-ADComputer -Identity $WorkstationName -Properties * | Select-Object -Property Name,LastLogonDate,Description
      if($BadCount -eq 1){
         $WorkstationProperties | export-csv -Path $ReportFile -NoClobber -NoTypeInformation
      }
      else{
         $WorkstationProperties | Export-Csv -Path $ReportFile -NoTypeInformation -Append
      }
   }
}

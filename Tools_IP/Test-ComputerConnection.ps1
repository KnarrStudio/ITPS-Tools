$WorkstationList = Import-Csv -Path $env:HOMEDRIVE\Temp\SiteList.csv -Header Name
$GoodCount = $BadCount = 0
$DateNow = Get-Date -UFormat %Y-%m-%d
$ReportFile = ("$env:HOMEDRIVE\temp\{0}-Report.txt" -f $DateNow)

foreach($OneWorkstation in $WorkstationList){

   $t = Test-Connection -ComputerName $OneWorkstation.Name -Count 1 -Quiet
   if($t -ne 'True'){
      $BadCount =+ 1

      $OneWorkstation.Name | Out-File -FilePath $ReportFile -NoClobber -Append
   }
   else{
      $GoodCount += 1
   }
}
 
$d = Import-Csv C:\Temp\SiteList.csv -Header Systems
$GoodCount = $BadCount = 0
$u = Get-Date -UFormat %Y-%m-%d
$ReportFile = "C:\temp\$u-Report.txt"

foreach($r in $d){

$t = Test-Connection $r.Systems -Count 1 -Quiet
if($t -ne 'True'){
    $BadCount =+ 1

    $r.Systems | Out-File $ReportFile -NoClobber -Append
    }
else{
    $GoodCount += 1
    }
}
 
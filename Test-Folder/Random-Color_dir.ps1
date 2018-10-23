$r = Get-ChildItem 
$t = ("red","blue",'yellow','green')
foreach($f in $r){
$y = Get-Random -Minimum 0 -Maximum 3
Start-Sleep -Seconds $y
Write-Host $f -ForegroundColor $t[$y]
}
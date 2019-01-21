$r = Get-ChildItem 
$t = ('red','blue','yellow','green','cyan')
foreach($f in $r){
$y = Get-Random -Minimum 0 -Maximum 4
Start-Sleep -Seconds ($y/5)
Write-Host ('File  {0}' -f $f) -ForegroundColor $t[$y]
}
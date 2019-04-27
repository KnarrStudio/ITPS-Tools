Clear-Host
Write-Output -InputObject 'Do While i is less than 10'
[int]$i = 0
do 
{
    Write-Output -InputObject "i = $i"
    $i++
}
 While($i -lt 10)

Write-Output -InputObject 'While j is less than 10 do'
[int]$j = 0
while ($j -lt 10)
{
    Write-Output -InputObject "j = $j"
    $j++
}

Write-Output -InputObject 'Do Until k is less than 10'
[int]$k = 0
do 
{
    Write-Output -InputObject "k = $k"
    $k++
}
 until ($k -lt 10)



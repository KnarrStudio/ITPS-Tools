clear
Write 'Do While i is less than 10'
[int]$i=0
do {
    write "i = $i"
    $i++
} While($i -lt 10)

Write 'While j is less than 10 do'
[int]$j=0
while ($j -lt 10){
    write "j = $j"
    $j++
}

Write 'Do Until k is less than 10'
[int]$k = 0
do {
    write "k = $k"
    $k++
} until ($k -lt 10)



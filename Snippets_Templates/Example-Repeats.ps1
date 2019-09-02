$services = Get-Service

foreach ($service in $services) {
    Write-Host "$($service.name)"
}

########

Get-Service | select Name

for([int]$i=0; $i -lt 10; $i++){
    write "i = $i"
    }


0..9 | ForEach-Object {write "i = $_ "}

switch -file ("fourteen") 
                               {
                                   1 {"It is one."; Break}
                                   2 {"It is two."; Break}
                                   3 {"It is three."; Break}
                                   4 {"It is four."; Break}
                                   3 {"Three again."; Break}
                                   "fo*" {"That's too many."}
                               }

Function Safety-Display{
    If ($WhatIfPreference -eq $true){
        Write-Host "Safety is ON" -ForegroundColor Green }
    else{
        Write-Host "Safety is OFF - Script will run" -ForegroundColor Red  }
}

Function Safety-Switch (){
 $COOPprocess
 $WhatIfPreference
 If ($COOPprocess -eq 0){    
    If ($WhatIfPreference -eq $true){
        $WhatIfPreference = $false}
    else{$WhatIfPreference = $true}
}
$COOPprocess
 return $WhatIfPreference
}
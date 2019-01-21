Param(
    [Parameter( Mandatory = $false)]
    $name = "JoBommo"    
)

& ((Split-Path $MyInvocation.InvocationName) + "\PrintName.ps1")  -printName $name
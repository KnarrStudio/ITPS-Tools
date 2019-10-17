function Test-FiberSatillite
{

  param
  (
    [Parameter(Position = 0)]
    [Object[]]
    $Sites = ('www.google.com', 'www.bing.com', 'www.cnn.com', 'www.facebook.com', 'www.yahoo.com')
  )
  
  $RttTotal = 0
  $TotalSites = $Sites.Count
    function Test-Verbose 
  {
    [Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
  }
  
    ForEach ($Site in $Sites)  
  {
    $PingReply = Test-NetConnection -ComputerName $Site 
    $RTT = $PingReply.PingReplyDetails.RoundtripTime
    $RttTotal = $RttTotal + $RTT
    
    Write-Verbose -Message ('{0} - RoundTripTime is {1} ms.' -f $PingReply.Computername, $RTT)
  }

  $RTT = $RttTotal/$TotalSites
    
  if(Test-Verbose)
  {
    if($RTT -gt 380)
    {
      Write-Host('Although not always the case this could indicate that you are on the Satellite backup circuit.') -BackgroundColor Red -ForegroundColor White
    }
    ElseIf($RTT -gt 90)
    {
      Write-Host ('Although not always the case this could indicate that you are on the Puerto Rico backup circuit.') -BackgroundColor Yellow -ForegroundColor White
    }
    ElseIf($RTT -gt 0)
    {
      Write-Host ('Round Trip Time is GOOD!') -BackgroundColor Green -ForegroundColor White
    }
  }
  Write-Output -InputObject ('Average RTT is {0} ms.' -f [int]$RTT)
}
# SIG # Begin signature block
# MIID7QYJKoZIhvcNAQcCoIID3jCCA9oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvl2K5Cb8IobldRdBJL489fyM
# SY6gggINMIICCTCCAXagAwIBAgIQyWSKL3Rtw7JMh5kRI2JlijAJBgUrDgMCHQUA
# MBYxFDASBgNVBAMTC0VyaWtBcm5lc2VuMB4XDTE3MTIyOTA1MDU1NVoXDTM5MTIz
# MTIzNTk1OVowFjEUMBIGA1UEAxMLRXJpa0FybmVzZW4wgZ8wDQYJKoZIhvcNAQEB
# BQADgY0AMIGJAoGBAKYEBA0nxXibNWtrLb8GZ/mDFF6I7tG4am2hs2Z7NHYcJPwY
# CxCw5v9xTbCiiVcPvpBl7Vr4I2eR/ZF5GN88XzJNAeELbJHJdfcCvhgNLK/F4DFp
# kvf2qUb6l/ayLvpBBg6lcFskhKG1vbEz+uNrg4se8pxecJ24Ln3IrxfR2o+BAgMB
# AAGjYDBeMBMGA1UdJQQMMAoGCCsGAQUFBwMDMEcGA1UdAQRAMD6AEMry1NzZravR
# UsYVhyFVVoyhGDAWMRQwEgYDVQQDEwtFcmlrQXJuZXNlboIQyWSKL3Rtw7JMh5kR
# I2JlijAJBgUrDgMCHQUAA4GBAF9beeNarhSMJBRL5idYsFZCvMNeLpr3n9fjauAC
# CDB6C+V3PQOvHXXxUqYmzZpkOPpu38TCZvBuBUchvqKRmhKARANLQt0gKBo8nf4b
# OXpOjdXnLeI2t8SSFRltmhw8TiZEpZR1lCq9123A3LDFN94g7I7DYxY1Kp5FCBds
# fJ/uMYIBSjCCAUYCAQEwKjAWMRQwEgYDVQQDEwtFcmlrQXJuZXNlbgIQyWSKL3Rt
# w7JMh5kRI2JlijAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUStgbO69iLVqBiGMggrHUiv6np5sw
# DQYJKoZIhvcNAQEBBQAEgYAdN45xQ2p+8X6/ViQGfQA+bPZ8/aVncHF58bLnwAoy
# nlPP6J/hTR867+oRMChygQlANiEfzjpe7j6/ydelt+3ZIml6YcVDv8dnyPvlFznU
# dm739lXnhbSwOyhJ9jjH4nJl0s4+6SG3oJbLWz2Y5TSRes1YzSJ7EO0BLD28ruDS
# pw==
# SIG # End signature block

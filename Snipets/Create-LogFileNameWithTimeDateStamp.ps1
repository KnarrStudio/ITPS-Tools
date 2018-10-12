function New-TimedStampFileName {
  <#
    .SYNOPSIS
    Creates a file where a time stamp in the name is needed

    .DESCRIPTION
    Allows you to create a file with a time stamp.  You provide the base name, extension, date format and it should do the rest.

    .PARAMETER baseNAME
    Describe parameter -baseNAME.

    .PARAMETER tailNAME
    Describe parameter -tailNAME.

    .PARAMETER StampFormat
    Describe parameter -StampFormat.

    .EXAMPLE
    New-TimedStampFileName -baseNAME TestFile -tailNAME ext -StampFormat 2
    This creates a file TestFile-20170316.ext 

    .NOTES
    This should be written in a way that will allow you to incert it into your script and use as a function


    .INPUTS
    Any authorized file name for the base and an extension that has some value to you.

    .OUTPUTS
    Filename-20181005.bat
  #>



  param
  (
    [Parameter(Mandatory,HelpMessage='Prefix of file or log name')]
    [alias('Prefix')]
    $baseNAME,
    [Parameter(Mandatory,HelpMessage='Extention of file.  txt, csv, log')]
    [alias('Extension')]
    $tailNAME,
    [Parameter(Mandatory,HelpMessage='Formatting Choice 1 to 4')]
    [alias('Choice')]
    [ValidateRange(1,4)]
    $StampFormat
  )

  switch ($StampFormat){
    1{$t = Get-Date -uformat '%y%m%d%H%M'} # 1703162145 YYMMDDHHmm
    2{$t = Get-Date -uformat '%Y%m%d'} # 20170316 YYYYMMDD
    3{$t = Get-Date -uformat '%d%H%M%S'} # 16214855 DDHHmmss
    4{$t = Get-Date -uformat '%y/%m/%d_%H:%M'} # 17/03/16_21:52
    default{'No time format selected'}
  }

  $baseNAME+'-'+$t+'.'+$tailNAME
}
# SIG # Begin signature block
# MIID7QYJKoZIhvcNAQcCoIID3jCCA9oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUeEvmr8G+AnTuDyV+5ne/HDo0
# 7segggINMIICCTCCAXagAwIBAgIQyWSKL3Rtw7JMh5kRI2JlijAJBgUrDgMCHQUA
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
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUDptMMKoomBNnLwEYNdB1LLWhED0w
# DQYJKoZIhvcNAQEBBQAEgYCNKNsOZfSOOcX3uLKG9L7ppwyx/SbY+FZsT27jI15q
# 67zx2p368ir0rl8fYQMt+v+5clF6c2iRNrZKG5I3GgHmaIfO12Mz7ywBp5soSNX0
# p941zjcgw7AdkA8lrOlbuEFw6maC/LNzEfpjdmxnGqcLvX5fHju/YWjaIXZTPxfH
# mQ==
# SIG # End signature block

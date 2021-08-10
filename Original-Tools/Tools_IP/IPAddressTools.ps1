#Requires -Version 3

<#
    .SYNOPSIS
    Use it to "work" with IP information, find subnet starting IP, ping for available addresses or find addresses in use.

    .DESCRIPTION
  

    .PARAMETER Available
    Returns a list of available addresses in the current subnet

    .PARAMETER Used
    Returns a list of addresses that are in use, in the current subnet

    .PARAMETER Names
    In conjunction with the 'Used' paramter, this will add the DNS Host names to the Used list

    .PARAMETER NetworkAddress
    Returns the network address of the current subnet

    .PARAMETER Broadcast
    Returns the broadcast address for the current subnet

    .PARAMETER 
    Returns a list of available addresses in the current subnet

    .INPUTS
    None

    .OUTPUTS
    Currently most of the the output is to the screen.  Future version might do reports.
    Log file stored in C:\Windows\Temp\<name>.log>

    .NOTES
    Version:        1.0
    Author:         Generik.1134
    Creation Date:  11/15/2018
    Purpose/Change: Initial script development
  
    .EXAMPLE
    <Example goes here. Repeat this attribute for more than one example>
#>

#----------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$GoodHostIpAddress = '192.168.1.7'
$IpAddressDot = '.'
$GoodHostDnsName = 'microsoft.com'
$BadHostIPAddress = '192.168.1.3'
$ErrorActionPreference = 'SilentlyContinue'

#Dot Source required Function Libraries
. "$env:HOMEDRIVE\Scripts\Functions\Logging_Functions.ps1"

#----------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#Log File Info
$sLogPath = "$env:windir\Temp"
$sLogName = '<script_name>.log'
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#---------------------[Functions]------------------------------------------------------------



function get-LocalActiveIpAddress 
{
  <#
      .SYNOPSIS
      Internal to script Get's ip information from most active NIC.
  #>

  [CmdletBinding()]
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue 'Getting the local IP, NIC and Subnet'
    $testBytes = $null
  }
  
  Process{
    Try
    {            
      $AllNetworkAdaptors = Get-NetAdapter | Where-Object -Property Status -EQ -Value Up
      if($AllNetworkAdaptors.count -ge 1)
      {
        foreach($CurrentAdaptor in $AllNetworkAdaptors)
        {
          $CurrentAdaptorStats = Get-NetAdapterStatistics -Name $CurrentAdaptor
          if($CurrentAdaptorStats.ReceivedBytes -gt $testBytes)
          {
            $testBytes = $CurrentAdaptorStats.ReceivedBytes
            $MostActiveAddapter = $CurrentAdaptor
          }
        }
      }
      $MostActiveAddapter = $AllNetworkAdaptors
      ($MostActiveAddapter | Get-NetIPAddress -AddressFamily IPv4).ipaddress
    }
    
    Catch
    {
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?)
    {
      Log-Write -LogPath $sLogFile -LineValue 'Completed Successfully.'
      Log-Write -LogPath $sLogFile -LineValue ' '
    }
  }
}



#---------- [Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#Script Execution goes here
#Log-Finish -LogPath $sLogFile

#$StartingIPAddress = get-LocalActiveIpAddress

[ipaddress]$StartingIPAddress = $GoodHostIpAddress
$NetworkAddress = ([ipaddress]($StartingIPAddress.Address -band ([ipaddress]'255.255.255.240').Address)).IPAddressToString
$NetworkAddress
$t = ($NetworkAddress.split($IpAddressDot)[0..3])
$ipadd = $t[0..2] -join $IpAddressDot

# $StartingIPAddress
[int]$i = $t[3]
do 
{ 
  $IpAddressToTest = ('{0}.{1}' -f $ipadd, $i)
  # "$ipadd.$i"
      
  if(!(Test-Connection -ComputerName $IpAddressToTest )) #-CommonTCPPort HTTP
  #Get-WmiObject -Class win32_pingstatus -Filter ("Address='{0}' and timeout=3000 and timetolive=255" -f $IpAddressToTest)).StatusCode -eq 11010)
  {
    ('{0} Free!' -f $IpAddressToTest)
  } 
  $i++
  $IpAddressToTest
} 
while ($i -lt ([int]$t[3]+16)) 


$GoodHostIpAddress = '70.160.25.172'
$IpAddressDot = '.'
$GoodHostDnsName = 'knarrstudio.com'
$BadHostIPAddress = '192.168.1.3'
$ErrorActionPreference = 'Continue'



Resolve-DnsName -QuickTimeout $GoodHostIpAddress
Resolve-DnsName -QuickTimeout $BadHostIPAddress
(Resolve-DnsName -QuickTimeout $BadHostIPAddress) | Test-NetConnection
Test-NetConnection -ComputerName '192.168.1.1'
#Resolve-DnsName -Name $GoodHostDnsName -Server 9.9.9.9 -Type A
#Get-NetRoute -Protocol Local -DestinationPrefix 192.168*
#Get-NetAdapter -Name wi-fi | Get-NetRoute
Test-NetConnection -ComputerName $GoodHostDnsName -TraceRoute
#Get-NetTCPConnection | Where-Object state -EQ Established

$masklength = (Get-NetIPAddress -InterfaceIndex 9 | Where-Object -Property AddressFamily -EQ -Value ipv4).PrefixLength
$ip.Address = ([uint32]::MaxValue -1)-shl (32 -$masklength) -shr (32 - $masklength)





Begin {


  function Find-InstalledHotFixes 
  {
    param
    (
      [Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = 'Data to process')]
      $InputObject,
      [Parameter(Mandatory = $true)][string]$DaysBack
    )
    process
    {
      if($InputObject.InstalledOn -gt ((Get-Date).AddDays(-$DaysBack)))
      {
$InputObject
}
    }
  }
  function Find-Gateway 
  {
    param
    (
      [Object]
      [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Data to filter')]
      $InputObject
    )

    if ($InputObject.DestinationPrefix -eq '0.0.0.0/0')
    {
$InputObject
}
  }

  Get-Module -Name NetAdapter, NetSecurity, NetTCPIP
  $Adaptors = Get-NetAdapter
  $Gateway = Get-NetRoute | Find-Gateway
  $r = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName 'LENOVA-11' | Where-Object -FilterScript {
$_.IPEnabled -eq $true -and $_.DHCPEnabled -eq $true
} 

  $NetworkAdapterConfiguration = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $env:COMPUTERNAME | Where-Object -FilterScript {
$_.IPEnabled -eq $true -and $_.DHCPEnabled -eq $true
} 
  
  
} # Begin Block
Process { 
  

  #Gateway Check
  foreach($adaptor in $Adaptors)
  {
    if(($adaptor.mediaconnectionstate) -eq 'Connected')
    {
      $GatewayPresent = Test-Connection -ComputerName $Gateway.NextHop -Count 1 -BufferSize 1000 -Quiet
      #$OutsideDNSPresent = Test-Connection -ComputerName $LocalHostName Count 1 -BufferSize 1000 -Quiet
      #$GatewayPresent = Test-Connection -ComputerName $LocalHostName Hop -Count 1 -BufferSize 1000 -Quiet
    }
  }
  

  <#  
      # Test External DNS
      $ResultsDNS = Test-Connection -ComputerName 9.9.9.9 -Count 1 -ErrorAction 0 # 0 is SilentlyContinue, 1 is Stop, 2 is Continue, 3 is Inquire, or 4 is Ignore.

      # Check if Firewall Enabled
      Get-NetFirewallProfile | Select-Object -Property Name,Enabled

      # Find if Updates were installed in the last 15 days
      Get-HotFix | Find-InstalledHotFixes -DaysBack 15 | Format-Table -AutoSize

      #Get-HotFix | Where-Object {$_.InstalledOn -gt ((get-date).AddDays(-15))}

      $r = Get-WMIObject -Class Win32_NetworkAdapterConfiguration -ComputerName 'LENOVA-11' | Where-Object{$_.IPEnabled -eq $true -and $_.DHCPEnabled -eq $true} 

      $r.IPAddress[0]
      $ResultsDNS

      $t = $r.DNSServerSearchOrder
      <#$DNSAvailableOutput = @{
      DNSServer = $r.DNSServerSearchOrder[0]
      Available = $true
      }


      $u = 0
      Write-Output -InputObject 'Checking DNS Servers... '
      Write-Output -InputObject 'This servers allow your computer to convert URL you know (http://google.com) to the IP Address (74.125.196.138) a computer knows.'
      foreach($e in $t){
      $DNSAvailable = Test-Connection -ComputerName $e -Count 1 -BufferSize 1000 -Quiet
      If($e.Length -gt $u){
      $u = ($e.Length + 1)
      Write-verbose -Message ('`$u = {0}' -f $u)
      }
      Write-Host ("{0,$u}{2}{1}" -f $e, $DNSAvailable,' is available: ')

  }#>
 
  
  
} # Process Block






End {
  # Gateway Output
  if ($GatewayPresent -eq $true)
  {
    Write-Host ('{0} ' -f 'Able to see the Gateway:') -NoNewline
    Write-Host $GatewayPresent -ForegroundColor Green
  }
  else
  {
Write-Host 'No gateway' -ForegroundColor Red
}

} # End Block
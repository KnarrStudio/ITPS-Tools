#Requires -Module NetAdapter, NetTCPIP 


begin{
   function Get-MyGateway
   {
      param
      (
         [Object]
         [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Data to filter')]
         $InputObject
      )
      process
      {
         if ($InputObject.DestinationPrefix -eq '0.0.0.0/0')
         {
            $InputObject
         }
      }
   }

   Function Get-MyNicStatus 
   {

      for($i = 0; $i -lt $MyNetAdapter.Length; $i++)
      {
         $NicName = $MyNetAdapter[$i].Name
         Write-Host ('NIC "{0}" is currently: ' -f $NicName) -NoNewline      
         if(($MyNetAdapter[$i].AdminStatus) -eq 'up')
         {         
            Write-Host ($MyNetAdapter[$i].AdminStatus) -ForegroundColor Green
         }
         else{
            Write-Host ($MyNetAdapter[$i].AdminStatus) -NoNewline -ForegroundColor Red
            Write-Host (' (This has been Disabled)') -ForegroundColor Yellow
         }
      }
   }


   function Test-MyGateway 
   {
      for($i = 0; $i -lt $MyNetAdapter.Length; $i++)
      {
         $NicName = $MyNetAdapter[$i].Name
      
         if(($MyNetAdapter[$i].mediaconnectionstate) -eq 'Connected'){
            $GatewayPresent = Test-Connection -ComputerName $MyGateway.NextHop -Count 1 -BufferSize 1000 -Quiet
            
            Write-Host ('NIC "{0}" can connect to {1}: ' -f $NicName,($MyGateway.NextHop)) -NoNewline -ForegroundColor cyan
         
            if ($GatewayPresent -eq $true){
               Write-Host $GatewayPresent -ForegroundColor Green
            }
            else{
               Write-Host $GatewayPresent -ForegroundColor Red
            }
         }
      }
   }

   function Get-MyActiveIpAddress {
      <#
            .SYNOPSIS
            Internal to script Get's ip information from most active NIC.
      #>

      [CmdletBinding()]
      Param()
  
      Begin{
         Log-Write -LogPath $IpLogFile -LineValue 'Getting the local IP, NIC and Subnet'
         $testBytes = $null
      }
  
      Process{
         Try{            
            $AllNetworkAdaptors = Get-NetAdapter | Where-Object Status -eq Up
            if($AllNetworkAdaptors.count -ge 1){
               foreach($CurrentAdaptor in $AllNetworkAdaptors){
                  $CurrentAdaptorStats = Get-NetAdapterStatistics -Name $CurrentAdaptor
                  if($CurrentAdaptorStats.ReceivedBytes -gt $testBytes){
                     $testBytes = $CurrentAdaptorStats.ReceivedBytes
                     $MostActiveAddapter = $CurrentAdaptor
                  }
               }
            }
            $MostActiveAddapter = $AllNetworkAdaptors
            ($MostActiveAddapter | Get-NetIPAddress -AddressFamily IPv4).ipaddress
         }
    
         Catch{
            Log-Error -LogPath $IpLogFile -ErrorDesc $_.Exception -ExitGracefully $True
            Break
         }
      }
  
      End{
         If($?){
            Log-Write -LogPath $IpLogFile -LineValue 'Completed Successfully.'
            Log-Write -LogPath $IpLogFile -LineValue ' '
         }
      }
   }

   $MyGateway = Get-NetRoute | Get-MyGateway
   $MyNetAdapter = Get-NetAdapter
}

process{
   Clear-Host
   Start-Transcript
   Get-MyNicStatus
   Write-Host ('The IP Address: {0}' -f (Get-MyActiveIpAddress))
   Test-MyGateway
}

end{}

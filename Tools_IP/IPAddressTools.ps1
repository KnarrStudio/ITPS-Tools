#Requires -Version 3
function Test-CurrentSubnetForAvailableIPs{

   function get-LocalActiveIpAddress {
      $testBytes = $null
      $AllNetworkAdaptors = Get-NetAdapter | Where-Object{$_.Status -eq 'Up'}
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

   #$StartingIPAddress = get-LocalActiveIpAddress


   [ipaddress]$StartingIPAddress = '192.168.3.183'

   $NetworkAddress = ([ipaddress]($StartingIPAddress.Address -band ([ipaddress]'255.255.255.240').Address)).IPAddressToString
   $NetworkAddress

   $t = ($NetworkAddress.split('.')[0..3])
   $ipadd = $t[0..2] -join '.'




   # $StartingIPAddress


   [int]$i = $t[3]
   do { 
      $z = ('{0}.{1}' -f $ipadd, $i)
      # "$ipadd.$i"
      
      if((Get-WmiObject -Class win32_pingstatus -Filter ("Address='{0}' and timeout=3000 and timetolive=255" -f $z)).StatusCode -eq 11010)
      { 
         ('{0} Free!' -f $z)
        } 
        $i++
        $z
   } 
   while ($i -lt ([int]$t[3]+16))


}
$Adaptors = Get-NetAdapter
$Gateway = Get-NetRoute | where {$_.DestinationPrefix -eq '0.0.0.0/0'}
foreach($adaptor in $Adaptors){

	if(($adaptor.mediaconnectionstate) -eq 'Connected'){
		$GatewayPresent = Test-Connection $Gateway.NextHop -Count 1 -BufferSize 1000 -Quiet

		if ($GatewayPresent -eq $true){
			Write-Host ('{0} ' -f 'Able to see the Gateway:') -NoNewline
			Write-Host $GatewayPresent -ForegroundColor Green
		}
		else{
			Write-Host 'No gateway' -ForegroundColor Red
		}
	}
}



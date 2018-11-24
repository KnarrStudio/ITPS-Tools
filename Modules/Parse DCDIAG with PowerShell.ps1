# Example : .\DCDiag.ps1 -DomainName "anilerduran.local" -HTMLFileName "C:\Scripts\Report.html" 


[CmdletBinding()]Param( 
	[Parameter(Mandatory=$True,Position=1)][string]$DomainName, 
	[Parameter(Mandatory=$True,Position=2)][string]$HTMLFileName 
) 

##################################### 
#            Functions                # 
##################################### 

function WMIDateStringToDate($Bootup) { 
	[System.Management.ManagementDateTimeconverter]::ToDateTime($Bootup) 
} 

function Test-Port{ 
[cmdletbinding( 
	DefaultParameterSetName = '', 
	ConfirmImpact = 'low' 
)] 
Param( 
	[Parameter( 
		Mandatory = $True, 
		Position = 0, 
		ParameterSetName = '', 
		ValueFromPipeline = $True)] 
	[array]$computer, 
	[Parameter( 
		Position = 1, 
		Mandatory = $True, 
		ParameterSetName = '')] 
	[array]$port, 
	[Parameter( 
		Mandatory = $False, 
		ParameterSetName = '')] 
	[int]$TCPtimeout = 1000, 
	[Parameter( 
		Mandatory = $False, 
		ParameterSetName = '')] 
	[int]$UDPtimeout = 1000, 
	[Parameter( 
		Mandatory = $False, 
		ParameterSetName = '')] 
	[switch]$TCP, 
	[Parameter( 
		Mandatory = $False, 
		ParameterSetName = '')] 
	[switch]$UDP 
) 
Begin { 
	If (!$tcp -AND !$udp) {$tcp = $True} 
	#Typically you never do this, but in this case I felt it was for the benefit of the function    
	#as any errors will be noted in the output of the report            
	$ErrorActionPreference = "SilentlyContinue" 
	$report = @() 
} 
Process { 
	ForEach ($c in $computer) { 
		ForEach ($p in $port) { 
			If ($tcp) { 
				#Create temporary holder     
				$temp = "" | Select Server, Port, TypePort, Open, Notes 
				#Create object for connecting to port on computer    
				$tcpobject = new-Object system.Net.Sockets.TcpClient 
				#Connect to remote machine's port                  
				$connect = $tcpobject.BeginConnect($c,$p,$null,$null) 
				#Configure a timeout before quitting    
				$wait = $connect.AsyncWaitHandle.WaitOne($TCPtimeout,$false) 
				#If timeout    
				If(!$wait) { 
					#Close connection    
					$tcpobject.Close() 
					Write-Verbose "Connection Timeout" 
					#Build report    
					$temp.Server = $c 
					$temp.Port = $p 
					$temp.TypePort = "TCP" 
					$temp.Open = "False" 
					$temp.Notes = "Connection to Port Timed Out" 
				} Else { 
					$error.Clear() 
					$tcpobject.EndConnect($connect) | out-Null 
					#If error    
					If($error[0]){ 
						#Begin making error more readable in report    
						[string]$string = ($error[0].exception).message 
						$message = (($string.split(":")[1]).replace('"',"")).TrimStart() 
						$failed = $true 
					} 
					#Close connection        
					$tcpobject.Close() 
					#If unable to query port to due failure    
					If($failed){ 
						#Build report    
						$temp.Server = $c 
						$temp.Port = $p 
						$temp.TypePort = "TCP" 
						$temp.Open = "False" 
						$temp.Notes = "$message" 
					} Else{ 
						#Build report    
						$temp.Server = $c 
						$temp.Port = $p 
						$temp.TypePort = "TCP" 
						$temp.Open = "True" 
						$temp.Notes = "" 
					} 
				} 
				#Reset failed value    
				$failed = $Null 
				#Merge temp array with report                
				$report += $temp 
			} 
			If ($udp) { 
				#Create temporary holder     
				$temp = "" | Select Server, Port, TypePort, Open, Notes 
				#Create object for connecting to port on computer    
				$udpobject = new-Object system.Net.Sockets.Udpclient 
				#Set a timeout on receiving message   
				$udpobject.client.ReceiveTimeout = $UDPTimeout 
				#Connect to remote machine's port                  
				Write-Verbose "Making UDP connection to remote server" 
				$udpobject.Connect("$c",$p) 
				#Sends a message to the host to which you have connected.   
				Write-Verbose "Sending message to remote host" 
				$a = new-object system.text.asciiencoding 
				$byte = $a.GetBytes("$(Get-Date)") 
				[void]$udpobject.Send($byte,$byte.length) 
				#IPEndPoint object will allow us to read datagrams sent from any source.    
				Write-Verbose "Creating remote endpoint" 
				$remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0) 
				Try { 
					#Blocks until a message returns on this socket from a remote host.   
					Write-Verbose "Waiting for message return" 
					$receivebytes = $udpobject.Receive([ref]$remoteendpoint) 
					[string]$returndata = $a.GetString($receivebytes) 
					If ($returndata) { 
						Write-Verbose "Connection Successful" 
						#Build report    
						$temp.Server = $c 
						$temp.Port = $p 
						$temp.TypePort = "UDP" 
						$temp.Open = "True" 
						$temp.Notes = $returndata 
						$udpobject.close() 
					} 
				} Catch { 
					If ($Error[0].ToString() -match "\bRespond after a period of time\b") { 
						#Close connection    
						$udpobject.Close() 
						#Make sure that the host is online and not a false positive that it is open   
						If (Test-Connection -comp $c -count 1 -quiet) { 
							Write-Verbose "Connection Open" 
							#Build report    
							$temp.Server = $c 
							$temp.Port = $p 
							$temp.TypePort = "UDP" 
							$temp.Open = "True" 
							$temp.Notes = "" 
						} Else { 
							<#   
                                It is possible that the host is not online or that the host is online,    
                                but ICMP is blocked by a firewall and this port is actually open.   
                                #> 
							Write-Verbose "Host maybe unavailable" 
							#Build report    
							$temp.Server = $c 
							$temp.Port = $p 
							$temp.TypePort = "UDP" 
							$temp.Open = "False" 
							$temp.Notes = "Unable to verify if port is open or if host is unavailable." 
						} 
					} ElseIf ($Error[0].ToString() -match "forcibly closed by the remote host" ) { 
						#Close connection    
						$udpobject.Close() 
						Write-Verbose "Connection Timeout" 
						#Build report    
						$temp.Server = $c 
						$temp.Port = $p 
						$temp.TypePort = "UDP" 
						$temp.Open = "False" 
						$temp.Notes = "Connection to Port Timed Out" 
					} Else { 
						$udpobject.close() 
					} 
				} 
				#Merge temp array with report                
				$report += $temp 
			} 
		} 
	} 
} 
End { 
	#Generate Report    
	$report 
} 
} 

function Get-SEPVersion { 
	# All registry keys: http://www.symantec.com/business/support/index?page=content&id=HOWTO75109 
	[CmdletBinding()] 
	param( 
		[Parameter(Position=0,Mandatory=$true,HelpMessage="Name of the computer to query SEP for", 
			ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
		[Alias('CN','__SERVER','IPAddress','Server')] 
		[System.String] 
		$ComputerName 
	) 
	# Create object to enable access to the months of the year 
	$DateTimeFormat = New-Object System.Globalization.DateTimeFormatInfo 
	#Set registry value to look for definitions path (depending on 32/64 bit OS) 
	$osType = Get-WmiObject Win32_OperatingSystem -ComputerName $computername| Select OSArchitecture 
	if ($osType.OSArchitecture -eq "32-bit") 
	{
		# Connect to Registry 
		$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$ComputerName) 
		# Set Registry keys to query 
		$SMCKey = "SOFTWARE\\Symantec\\Symantec Endpoint Protection\\SMC" 
		$AVKey = "SOFTWARE\\Symantec\\Symantec Endpoint Protection\\AV" 
		$SylinkKey = "SOFTWARE\\Symantec\\Symantec Endpoint Protection\\SMC\\SYLINK\\SyLink" 
		# Obtain Product Version value 
		$SMCRegKey = $reg.opensubkey($SMCKey) 
		$SEPVersion = $SMCRegKey.GetValue('ProductVersion') 
		# Obtain Pattern File Date Value 
		$AVRegKey = $reg.opensubkey($AVKey) 
		$AVPatternFileDate = $AVRegKey.GetValue('PatternFileDate') 
		# Convert PatternFileDate to readable date 
		$AVYearFileDate = [string]($AVPatternFileDate[0] + 1970) 
		$AVMonthFileDate = $DateTimeFormat.MonthNames[$AVPatternFileDate[1]] 
		$AVDayFileDate = [string]$AVPatternFileDate[2] 
		$AVFileVersionDate = $AVDayFileDate + " " + $AVMonthFileDate + " " + $AVYearFileDate 
		# Obtain Sylink Group value 
		#$SylinkRegKey = $reg.opensubkey($SylinkKey) 
		#$SylinkGroup = $SylinkRegKey.GetValue('CurrentGroup') 
	} 
	else 
	{
		# Connect to Registry 
		$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$ComputerName) 
		# Set Registry keys to query 
		$SMCKey = "SOFTWARE\\Wow6432Node\\Symantec\\Symantec Endpoint Protection\\SMC" 
		$AVKey = "SOFTWARE\\Wow6432Node\\Symantec\\Symantec Endpoint Protection\\AV" 
		$SylinkKey = "SOFTWARE\\Wow6432Node\\Symantec\\Symantec Endpoint Protection\\SMC\\SYLINK\\SyLink" 

		# Obtain Product Version value 
		$SMCRegKey = $reg.opensubkey($SMCKey) 
		$SEPVersion = $SMCRegKey.GetValue('ProductVersion') 

		# Obtain Pattern File Date Value 
		$AVRegKey = $reg.opensubkey($AVKey) 
		$AVPatternFileDate = $AVRegKey.GetValue("PatternFileDate") 

		# Obtain Pattern File Date Value 
		$AVRegKey = $reg.opensubkey($AVKey) 
		$AVPatternFileDate = $AVRegKey.GetValue('PatternFileDate') 

		# Convert PatternFileDate to readable date 
		$AVYearFileDate = [string]($AVPatternFileDate[0] + 1970) 
		$AVMonthFileDate = $DateTimeFormat.MonthNames[$AVPatternFileDate[1]] 
		$AVDayFileDate = [string]$AVPatternFileDate[2] 
		$AVFileVersionDate = $AVDayFileDate + " " + $AVMonthFileDate + " " + $AVYearFileDate 
	} 
	$MYObject = “” | Select-Object ComputerName,SEPProductVersion,SEPDefinitionDate 
	$MYObject.ComputerName = $ComputerName 
	$MYObject.SEPProductVersion = $SEPVersion 
	$MYObject.SEPDefinitionDate = $AVFileVersionDate 
	$MYObject 
} 


##################################### 
#        Forest and Domain Info        # 
##################################### 
Write-Host " ..... Forest and Domain Information ..... " -foregroundcolor green 
Import-Module ActiveDirectory 
$Domain = $DomainName 
$ADForestInfo = Get-ADforest -server $Domain 
$ADDomainInfo = Get-ADdomain -server $Domain 
$DCs = Get-ADDomainController -filter * -server "$Domain" 
$allDCs = $DCs | foreach {$_.hostname} 
$ADForestInfo.sites | foreach {$Sites += "$($_) "} 
Write-Host "Forest Information" 
$ForestResults = New-Object Object 
$ForestResults | Add-Member -Type NoteProperty -Name "Mode" -Value (($ADForestInfo.ForestMode) -replace "Windows", "") 
$ForestResults | Add-Member -Type NoteProperty -Name "DomainNamingMaster" -Value $ADForestInfo.DomainNamingMaster 
$ForestResults | Add-Member -Type NoteProperty -Name "SchemaMaster" -Value $ADForestInfo.SchemaMaster 
$ForestResults | Add-Member -Type NoteProperty -Name "ForestName" -Value $ADForestInfo.name 
$ForestResults | Add-Member -Type NoteProperty -Name "Sites" -Value $Sites 
Write-Host "Domain Information" 
$DomainResults = New-Object Object 
$DomainResults | Add-Member -Type NoteProperty -Name "Mode" -Value (($ADDomainInfo.DomainMode) -replace "Windows", "") 
$DomainResults | Add-Member -Type NoteProperty -Name "InfraMaster" -Value $ADDomainInfo.infrastructuremaster 
$DomainResults | Add-Member -Type NoteProperty -Name "Domain" -Value $ADDomainInfo.name 
$DomainResults | Add-Member -Type NoteProperty -Name "PDC" -Value $ADDomainInfo.pdcemulator 
$DomainResults | Add-Member -Type NoteProperty -Name "RID" -Value $ADDomainInfo.ridmaster 

##################### 
#        DCDIAG        # 
##################### 
Write-Host " ..... DCDiag ..... " -foregroundcolor green 
$AllDCDiags = @() 
foreach ($DC in $allDCs) 
{
	Write-Host "Processing $DC" 
	$Dcdiag = (Dcdiag.exe /s:$DC) -split ('[\r\n]') 
	$Results = New-Object Object 
	$Results | Add-Member -Type NoteProperty -Name "ServerName" -Value $DC 
	$Dcdiag | %{ 
		Switch -RegEx ($_) 
		{
			"Starting" { $TestName = ($_ -Replace ".*Starting test: ").Trim() } 
			"passed test|failed test" { If ($_ -Match "passed test") { 
					$TestStatus = "Passed" 
					# $TestName 
					# $_ 
				} 
				Else 
				{
					$TestStatus = "Failed" 
					# $TestName 
					# $_ 
				} } 
		} 
		If ($TestName -ne $Null -And $TestStatus -ne $Null) 
		{
			$Results | Add-Member -Name $("$TestName".Trim()) -Value $TestStatus -Type NoteProperty -force 
			$TestName = $Null; $TestStatus = $Null 
		} 
	} 
	$AllDCDiags += $Results 
} 
# $Results.ServerName 
# $Results.Connectivity 
# $Results.Advertising 
# $Results.FrsEvent 
# $Results.DFSREvent 
# $Results.SysVolCheck 
# $Results.KccEvent 
# $Results.KnowsOfRoleHolders 
# $Results.MachineAccount 
# $Results.NCSecDesc 
# $Results.NetLogons 
# $Results.ObjectsReplicated 
# $Results.Replications 
# $Results.RidManager 
# $Results.Services 
# $Results.SystemLog 
# $Results.VerifyReferences 
# $Results.CheckSDRefDom 
# $Results.CrossRefValidation 
# $Results.LocatorCheck 
# $Results.Intersite 

##################################### 
#        OS Info and Uptime            # 
##################################### 
Write-Host " ..... OS Info and Uptime ..... " -foregroundcolor green 
$AllDCInfo = @() 
foreach ($DC in $allDCs) 
{
	$Results = New-Object Object 
	$Results | Add-Member -Type NoteProperty -Name "ServerName" -Value $DC 
	Write-Host "Processing $DC" 
	$computers = Get-WMIObject -class Win32_OperatingSystem -computer $DC 
	foreach ($system in $computers) 
	{
		if(-not $computers) 
		{
			$uptime = "Server is not responding : !!!!!!!!!!!! : !!!!!!!!!!!! : !!!!!!!!!!!!" 
			"$DC : $uptime" 
			$TestStatus = "Failed" 
			$Results | Add-Member -Type NoteProperty -Name "Uptime" -Value $TestStatus 
			$Results | Add-Member -Type NoteProperty -Name "C-DriveFreeSpace" -Value $TestStatus 
			$Results | Add-Member -Type NoteProperty -Name "OSVersion" -Value $TestStatus 
		} 
		else 
		{
			$disk = ([wmi]"\\$DC\root\cimv2:Win32_logicalDisk.DeviceID='c:'") | ForEach-Object {[math]::truncate($_.freespace /1gb)} 
			#$OSVersion = $system.caption -replace "Microsoft® Windows ", "" 
			$Bootup = $system.LastBootUpTime 
			$LastBootUpTime = WMIDateStringToDate $bootup 
			$now = Get-Date 
			$Uptime = $now - $lastBootUpTime 
			$d = $Uptime.Days 
			$h = $Uptime.Hours 
			$m = $uptime.Minutes 
			$ms = $uptime.Milliseconds 
			$DCUptime = "{0} days {1} hours" -f $d,$h 
			$Results | Add-Member -Type NoteProperty -Name "Uptime" -Value $DCUptime 
			$Results | Add-Member -Type NoteProperty -Name "C-DriveFreeSpace" -Value $disk 
			#$Results | Add-Member -Type NoteProperty -Name "OSVersion" -Value $osversion 
		} 
	} 
	$AllDCInfo += $Results 
} 
# $Results.ServerName 
# $Results.DCUptime 
# $Results.disk 
# $Results.osversion 


##################################### 
#        OS Info and Uptime            # 
##################################### 
Write-Host " ..... Server Time ..... " -foregroundcolor green 
$Timeresults = @() 
foreach ($DC in $alldcs) 
{
	Write-Host "$DC " 
	$computers = Get-WMIObject -class Win32_OperatingSystem -computer $DC |Select-Object CSName,@{Name="LocalDateTime";Expression={$_.ConvertToDateTime($_.LocalDateTime)}} 
	$domaintimes = New-Object object 
	$domaintimes | add-member -type NoteProperty -Name "DCName" -Value $computers.csname 
	$domaintimes | add-member -type NoteProperty -Name "LocalDateTime" -Value $computers.LocalDateTime 
	$Timeresults += $domaintimes 
} 

##################################### 
#        DC Test Ports                # 
##################################### 
Write-Host " ..... Testing Ports ..... " -foregroundcolor green 
$AllPortResults = @() 
foreach ($DC in $allDCs) 
{
	Write-Host "Processing $DC" 
	$389 = test-port -comp $DC -port 389 -tcp 
	$ResultsPort = New-Object Object 
	$ResultsPort | Add-Member -Type NoteProperty -Name "ServerName" -Value $DC 
	$ResultsPort | Add-Member -Type NoteProperty -Name "LDAP389" -Value $389.open 

	$3268 = test-port -comp $DC -port 3268 -tcp 
	$ResultsPort | Add-Member -Type NoteProperty -Name "LDAP3268" -Value $3268.open 

	$53 = test-port -comp $DC -port 53 -udp 
	$ResultsPort | Add-Member -Type NoteProperty -Name "DNS53" -Value $53.open 

	$135 = test-port -comp $DC -port 135 -tcp 
	$ResultsPort | Add-Member -Type NoteProperty -Name "RPC135" -Value $135.open 

	$445 = test-port -comp $DC -port 445 -tcp 
	$ResultsPort | Add-Member -Type NoteProperty -Name "SMB445" -Value $445.open 

	$AllPortResults += $ResultsPort 
} 

######################################### 
#        DC Repadmin ReplSum                # 
######################################### 
Write-Host " ..... Repadmin /Replsum ..... " -foregroundcolor green 
$myRepInfo = @(repadmin /replsum * /bysrc /bydest /sort:delta /homeserver:$Domain) 
# Initialize our array. 
$cleanRepInfo = @() 
# Start @ #10 because all the previous lines are junk formatting 
# and strip off the last 4 lines because they are not needed. 
for ($i = 10; $i -lt ($myRepInfo.Count-4); $i++) { 
	if($myRepInfo[$i] -ne ""){ 
		# Remove empty lines from our array. 
		$myRepInfo[$i] -replace '\s+', " " | Out-Null 
		$cleanRepInfo += $myRepInfo[$i] 
	} 
} 
$finalRepInfo = @() 
foreach ($line in $cleanRepInfo) { 
	$splitRepInfo = $line -split '\s+',8 
	if ($splitRepInfo[0] -eq "Source") { $repType = "Source" } 
	if ($splitRepInfo[0] -eq "Destination") { $repType = "Destination" } 
	if ($splitRepInfo[1] -notmatch "DSA") { 
		# Create an Object and populate it with our values. 
		$objRepValues = New-Object System.Object 
		$objRepValues | Add-Member -type NoteProperty -name DSAType -value $repType # Source or Destination DSA 
		$objRepValues | Add-Member -type NoteProperty -name Hostname -value $splitRepInfo[1] # Hostname 
		$objRepValues | Add-Member -type NoteProperty -name Delta -value $splitRepInfo[2] # Largest Delta 
		$objRepValues | Add-Member -type NoteProperty -name Fails -value $splitRepInfo[3] # Failures 
		#$objRepValues | Add-Member -type NoteProperty -name Slash  -value $splitRepInfo[4] # Slash char 
		$objRepValues | Add-Member -type NoteProperty -name Total -value $splitRepInfo[5] # Totals 
		$objRepValues | Add-Member -type NoteProperty -name PctError -value $splitRepInfo[6] # % errors    
		$objRepValues | Add-Member -type NoteProperty -name ErrorMsg -value $splitRepInfo[7] # Error code 

		# Add the Object as a row to our array     
		$finalRepInfo += $objRepValues 

	} 
} 

##################################### 
#        SEP Version                    # 
##################################### 
Write-Host " ..... SEP Version ..... " -foregroundcolor green 
$AllSEPResults = @() 
foreach ($DC in $allDCs) 
{
	Write-Host "Processing $DC" 
	$SEPresult = Get-SepVersion -ComputerName $DC -ErrorAction silentlycontinue | Select-Object ComputerName,SEPProductVersion,SEPDefinitionDate 
	$AllSEPResults += $SEPresult 
} 

##################################### 
#        Compile HTML                # 
##################################### 
#$style = "<style>BODY{font-family: Arial; font-size: 10pt;}" 
$style = "<style>BODY{color:#717D7D;background-color:#F5F5F5;font-size:10pt;font-family:'trebuchet ms', helvetica, sans-serif;font-weight:normal;padding-:0px;margin:0px;overflow:auto;}" 
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}" 
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }" 
$style = $style + "TD{font-weight: bold; border: 1px solid black; padding: 5px; }" 
$style = $style + "</style>" 
$HTML = "<h2>Forest Information</h2></br>" 
$HTML += $ForestResults | ConvertTo-HTML -head $style 
$HTML += "</br><h2>Domain Information</h2></br>" 
$HTML += $DomainResults | ConvertTo-HTML -head $style 
$HTML += "</br><h2>Domain Controller Information</h2></br>" 
$HTML += $DCs | Select HostName,Site,Ipv4Address,OperatingSystem,OperatingSystemServicePack,IsGlobalCatalog | ConvertTo-HTML -head $style 
$HTML += "</br>" 
$HTML += $AllDCInfo | ConvertTo-HTML -head $style 
$HTML += "</br>" 
$HTML += $Timeresults | ConvertTo-HTML -head $style 
$HTML += "</br><h2>DCDiag Results</h2></br>" 
$HTML += $AllDCDiags | ConvertTo-HTML -head $style 
$HTML += "</br><h2>Replication Information</h2></br>" 
$HTML += $finalRepInfo | ConvertTo-HTML -head $style 
$HTML += "</br><h2>Port Tests</h2></br>" 
$HTML += $AllPortResults| ConvertTo-HTML -head $style 
$HTML += "</br><h2>SEP Versions</h2></br>" 
$HTML += $AllSEPResults | ConvertTo-HTML -head $style 
$HTML = $HTML -Replace ('failed', '<font color="red">Failed</font>') 
$HTML = $HTML -Replace ('passed', '<font color="green">Passed</font>') 
$HTML | Out-File $HTMLFileName
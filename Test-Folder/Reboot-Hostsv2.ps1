

function Reboot-VmHosts {
	<#
    .SYNOPSIS
    This script will move all the hosts from one server and reboot it.
    .DESCRIPTION
    <A detailed description of the script>
    .PARAMETER -Source
    Host to move servers from.  The first host to reboot
    .PARAMETER -Destination
    Host to move servers to.  If the "rebootBoth" switch is passed, it will be the second to reboot
    .PARAMETER -rebootBoth
    Select this to reboot both hosts
    .PARAMETER -nameLog
    For logging
    .EXAMPLE
    Reboot-VmHosts -Source "192.16.0.18" -Destination "192.16.0.19" -rebootBoth -nameLog   
#>
	[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true)]
		[Alias('Source')]
		[ValidateLength(8,16)]
		[string]$SourceVmHost,
		[Parameter(Mandatory=$true)][Alias('Destination')]
		[ValidateLength(8,16)]
		[string]$DestVmHost,
		[switch]$rebootBoth,
		[switch]$nameLog
	)
	BEGIN{
		if ($nameLog){
			Write-Verbose -Message 'Finding name log file'
			$i = 0
			Do {
				$logfile = ('.\names-{0}.txt' -f $i)
				$i++
			}while (Test-Path -Path $logfile)
		} else {
			Write-Verbose -Message 'Name log off'
		}
		Write-Debug -Message 'finished setting name log'
	}
	PROCESS{
		$i = 0
		if ($rebootBoth){
			$i = 2
		}
		do{
			$i++
			if($i -eq 2){
				$tempHost = $SourceVmHost
				$SourceVmHost = $DestVmHost
				$DestVmHost = $tempHost
			}

			Write-Debug -Message 'Starting Process'
			if($PSCmdlet.ShouldProcess($SourceVmHost)){
				Write-Verbose -Message ('Connecting to {0}' -f $SourceVmHost)
				if($nameLog){
					$SourceVmHost | Out-File -FilePath $logfile -Append
				}
				try {
					$continue = $true
					do{
						$servers = get-vm | Where-Object {$_.vmhost.name -eq $SourceVmHost}
						foreach($server in $servers){
							Write-Verbose -Message ('Moving {0} from {1} to {2}' -f $server, $SourceVmHost, $DestVmHost)
							move-vm $SourceVmHosts -Destination $DestVmHosts
						}
					}while((get-vm | Where-Object {$_.vmhost.name -eq $SourceVmHost}).count -ne 0)

					if((get-vm | Where-Object {$_.vmhost.name -eq $SourceVmHost}).count -eq 0){
						Set-VMHost $SourceVmHost -State Maintenance | Out-Null
						Restart-vmhost $SourceVmHost -confirm:$false | Out-Null 
					}
					do {Start-Sleep -Seconds 15
						$ServerState = (get-vmhost $SourceVmHost).ConnectionState
						Write-Verbose -Message ('Shutting Down {0}' -f $SourceVmHost)
					} while ($ServerState -ne 'NotResponding')
					Write-Verbose -Message ('{0} is Down' -f $SourceVmHost)

					do {Start-Sleep -Seconds 15
						$ServerState = (get-vmhost $SourceVmHost).ConnectionState
						Write-Verbose -Message 'Waiting for Reboot ...'
					} while($ServerState -ne 'Maintenance')
					Write-Verbose -Message ('{0} back online' -f $SourceVmHost)
					Set-VMHost $SourceVmHost -State Connected | Out-Null 

				}
				catch {
					$continue = $false
					$SourceVmHost | Out-File -FilePath '.\error.txt'
					#$myErr | Out-File '.\errormessages.txt'
				}
			}

		}Until($i -eq 2)
	}
	END{}
}
# SIG # Begin signature block
# MIID7QYJKoZIhvcNAQcCoIID3jCCA9oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTOfS1qaHzcyJLgE3a/VIGEyG
# IVmgggINMIICCTCCAXagAwIBAgIQyWSKL3Rtw7JMh5kRI2JlijAJBgUrDgMCHQUA
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
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUJTnovc+6tx1snc1DtI1Sb4GbRGIw
# DQYJKoZIhvcNAQEBBQAEgYBNe0fKpTFzeWxZ3vZOHX87Q7MwvnCVeJLr1QdvtiOv
# F7NSrTo+yyxcuxPgrKhsDCUtuZvx7rkSLAlOr2uL9NjbBXXUsX18L/Eec0afWzcU
# dYp3QiYdUaTGrExqalUfJTKtFkHXo/rOXEMtEA1Np7Z4WX/DzxPIydHOMc262MzD
# rA==
# SIG # End signature block

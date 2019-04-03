

function Restart-VmHosts {
   <#
         .SYNOPSIS
         This script will move all the hosts from one server and reboot it.
         .DESCRIPTION
         <A detailed description of the script>
         .PARAMETER -FirstHost
         Host to move servers from.  The first host to reboot
         .PARAMETER -LastHost
         Host to move servers to.  If the "rebootAll" switch is passed, it will be the last to reboot
         .PARAMETER -rebootAll
         Select this to reboot both hosts
         .PARAMETER -nameLog
         For logging
         .EXAMPLE
         Reboot-VmHosts -FirstHost "192.16.0.18" -LastHost "192.16.0.19" -rebootAll -nameLog   
   #>
   [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
   param(
      [Parameter(Mandatory=$true, ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true)]
      [Alias('FirstHost')]
      [ValidateLength(8,16)]
      [string[]]$HostsToReboot,
      [Parameter(Mandatory=$true)][Alias('LastHost')]
      [ValidateLength(8,16)]
      [string]$LastHostToReboot,
      [switch]$rebootAll,
      [switch]$nameLog
   )


   function Get-VmOnHost{
      param
      (
         [Object]
         [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Data to filter")]
         $InputObject
      )
      process
      {
         if ($InputObject.vmhost.name -eq $HostsToReboot)
         {
            $InputObject
         }
      }
   }
   function Start-MoveVmOffHost{
 
      do{
         $servers = get-vm | Get-VmOnHost
         foreach($server in $servers){
            Write-Verbose -Message ('Moving {0} from {1} to {2}' -f $server, $HostsToReboot, $LastHostToReboot)
            move-vm $server -Destination $LastHostToReboot
         }
      }while((get-vm | Get-VmOnHost).count -ne 0)

      if((get-vm | Get-VmOnHost).count -eq 0){
         Set-VMHost $HostsToReboot -State Maintenance | Out-Null
         Restart-vmhost $HostsToReboot -confirm:$false | Out-Null 
      }else{Start-MoveVM}
   
      do {Start-Sleep -Seconds 15
         $ServerState = (get-vmhost $HostsToReboot).ConnectionState
         Write-Verbose -Message ('Shutting Down {0}' -f $HostsToReboot)
      } while ($ServerState -ne 'NotResponding')
      Write-Verbose -Message ('{0} is Down' -f $HostsToReboot)

      do {Start-Sleep -Seconds 15
         $ServerState = (get-vmhost $HostsToReboot).ConnectionState
         Write-Verbose -Message 'Waiting for Reboot ...'
      } while($ServerState -ne 'Maintenance')
      Write-Verbose -Message ('{0} back online' -f $HostsToReboot)
      Set-VMHost $HostsToReboot -State Connected | Out-Null

   } # End - Start-MoveVmOffHost

   BEGIN{
      $HostCount = $HostsToReboot.count
      if ($HostCount -gt 1){
         $VmHosts = Get-VmHost # Suggest using a name switch
      }
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
   } #End - Begin
   
   PROCESS{
      Write-Debug -Message 'Starting Process'
      
      $i = 0
      if ($rebootAll){
         $i = $HostCount
         for($i to $HostCount){
            Start-MoveVmOffHost
         }
            }
         }
      }
      do{
         $i++
         if($i -eq $HostCount){
            $tempHost = $HostsToReboot
            $HostsToReboot = $LastHostToReboot
            $LastHostToReboot = $tempHost
         }

         if($PSCmdlet.ShouldProcess($HostsToReboot)){
            Write-Verbose -Message ('Connecting to {0}' -f $HostsToReboot)
            if($nameLog){
               $HostsToReboot | Out-File -FilePath $logfile -Append
            }
            try {
               $continue = $true
               Start-MoveVmOffHost
            }

            catch {
               $continue = $false
               $HostsToReboot | Out-File -FilePath '.\error.txt'
               #$myErr | Out-File '.\errormessages.txt'
            }
         }

      }Until($i -eq $HostCount)
   } #End - Process 
   END{} #End - End
}
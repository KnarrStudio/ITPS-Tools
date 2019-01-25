Function script:Info-COOPs-Snaps {
   <#
         .SYNOPSIS
         Returns a information about the VMs COOP and Snapshots 

         .OUTPUTS
         Snapshot information of all VM's in our vsphere.
         COOP'ed Servers with the Power ON.
         Regular VM's with the Power turned OFF.

   #>


   $DoubleLineBoarder = '============================='
   get-tag
   Write-Verbose -Message $DoubleLineBoarder
   Write-Verbose -Message `n 
   $PoweredOffVM = get-vm | Where-Object {($_.PowerState -eq 'PoweredOff') -and ($_.Name -notlike '*COOP*')}# | Format-Table -AutoSize
   If ($PoweredOffVM.count -ne 0){
      Write-Host `n "Regular VM's with the Power turned OFF."  -foreground Black -BackgroundColor Cyan
      Write-Host -sep `n $PoweredOffVM  -foregroundcolor Cyan #| Format-Table -AutoSize
      Write-Host $DoubleLineBoarder -foregroundcolor Cyan
      Write-Host -sep `n 
    }
   $COOPSinuse = get-vm | Where-Object {($_.Name -like '*COOP*') -and ($_.PowerState -eq 'PoweredOn')}
   If ($COOPSinuse.count -ne 0){
      Write-Host `n "COOP'ed Servers with the Power ON."  -foreground White -BackgroundColor Red
      Write-Host -sep `n $COOPSinuse -foregroundcolor Red
      Write-Host $DoubleLineBoarder -foregroundcolor Red
      Write-Host -sep `n 
    }
   $Snapshotinfo = get-vm | get-snapshot | Select-Object -Property VM,Name,Created | Sort-Object -Property Created,SizeGB -Descending #, id -AutoSize
   If ($Snapshotinfo.count -ne 0){
      Write-Host `n "Snapshot information of all VM's in our vsphere." -foreground Black -BackgroundColor Yellow
      $Snapshotinfo | Format-Table -Property VM,Name,Created,@{n='SizeGb';e={'{0:N2}' -f $_.SizeGb}}
      Write-Host $DoubleLineBoarder -foregroundcolor Yellow
    }
}

Function Remove-COOPs {

   
   function Get-COOPdVMs
   {
      param
      (
         [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Data to filter')]
         [Object]$InputObject
      )
      process
      {
         if ($InputObject.Name -match 'COOP')
         {
            $InputObject
         }
         if (($InputObject.Name -match 'COOPdate') -and ($InputObject.PowerState -eq 'PoweredOff'))
         {
            $InputObject
         }
      }
   }

   if ($COOPprocess -eq '2'){Clear-Host}

   #Get List of all VM's with "COOP" in the name. This will be used as the list of COOP's that will be deleted.
   $VMServers  = get-vm | Get-COOPdVMs
   get-vm | Get-COOPdVMs | Format-Table -Property Name

   #Enter the date of the COOP vms that you want to remove.  From the printout of the list above, you will be able to select the unwanted dates.
   $COOPdate = Read-Host -Prompt 'Enter the date of the COOP you want to remove (YYYYMMDD) '

   #Get List of the VM Clones you want to Remove.  This is similar to the first step, but uses the specific date you gave to search on.  This will be your list of systems to remove.
$VMSvr = $VMServers | Get-COOPdVMs } #| ft Name, ResourcePool  -AutoSize

Write-Host -sep `n "Preparing to remove ALL COOP'ed vm servers below." $VMSvr -foreground Red

#Set "$OkRemove" to "N" 
$OkRemove = 'N'
$OkRemove = Read-host -Prompt 'Is this Okay? [N] '

If ($OkRemove -eq 'Y'){
   #Remove older COOP's from the list you created in the early part of the script.
   foreach ($VMz in $VMSvr) {
      Write-Host -sep `n ('Checking to ensure {0} is Powered Off.' -f $VMz) #-foregroundcolor Red
      If (($VMz.PowerState -eq 'PoweredOff') -and ($VMz.Name -like '*COOP*')){
         Write-Host -sep `n $VMz 'is in a Powered Off state and will be removed. ' -foregroundcolor Blue 
         #Write-Host "Remove-VM $VMz -DeletePermanently -confirm:$true "
         Remove-VM $VMz -DeletePermanently -confirm:$true -runasync 

}}}
}

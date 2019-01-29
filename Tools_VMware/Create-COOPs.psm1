Function Create-COOPs {

   $DoubleBoarderLine = '============================='
if ($COOPprocess -eq '3'){Clear-Host}

   #get-vm *gm* -tag "COOPdr" | where {$_.powerstate -eq "PoweredOn"} | ft Name, ResourcePool -AutoSize
   #$VMServer  = get-vm *gm* | where {($_.powerstate -eq "PoweredOn") -and ($_.ResourcePool -like "Standard Server*") -and ($_.name -ne "rsrcngmfs02") -and ($_.name -ne "RSRCNGMNB01") -and ($_.name -ne "rsrcngmfs01") -and ($_.name -ne "rsrcngmcmps01")} | select Name, ResourcePool
   #get-vm *gm* | where {($_.powerstate -eq "PoweredOn") -and ($_.ResourcePool -like "Standard Server*") -and ($_.name -ne "rsrcngmfs02") -and ($_.name -ne "RSRCNGMNB01") -and ($_.name -ne "rsrcngmfs01") -and ($_.name -ne "rsrcngmcmps01")} | ft Name, ResourcePool -AutoSize

   $VMServer  = get-vm *gm* -tag 'COOPdr' | Where-Object {$_.powerstate -eq 'PoweredOn'}

   #Create Time/Date Stamp
   $TDStamp = Get-Date -UFormat '%Y%m%d' 

   #Prefix of Name of COOP
   $COOPPrefix = $TDStamp+'-COOP.' 

   Write-Host -Separator `n 
   Write-Host 'Information to be used to create the COOPs: ' -foregroundcolor black -backgroundcolor white #
   Write-Host -Separator `n $VMServer | Format-Table -Property Name,ResourcePool -AutoSize 
   Write-Host -Separator `n 
   Write-Host $DoubleBoarderLine -foregroundcolor Yellow
   Write-Host 'Writing to: '$DataStoreStore -foregroundcolor Yellow
   Write-Host 'On VM Host: '$VMHostIP -foregroundcolor Yellow
   Write-Host 'Example of COOP file name: '$COOPPrefix$($VMServer.Name[1]) -foregroundcolor Yellow
   Write-Host -Separator `n 

   #Set "$OkADD" to "N" and confirm addition of COOPs
   $OkADD = 'N'
   Write-Host 'Preparing to Create ALL New COOP servers with information above. ' -NoNewline
   $OkADD = Read-host -Prompt 'Is this Okay? Y,S,[N] '

   switch ($OkAdd){
      Y {
         foreach ($server in $VMserver) {
            Clear-Host
            Write-Host -Separator `n 'Completed'
            Write-Host $DoubleBoarderLine -foregroundcolor Yellow
            get-vm | Where-Object {$_.Name -like $TDStamp+'-COOP.*'} | Format-Table -Property Name
            Write-Host 'New COOP Name: '$COOPPrefix$($server) 'In ResourcePool: '$Server.ResourcePool -foregroundcolor Green -backgroundcolor black
            #Create the COOP copies with the information assigned to these var ($COOPPrefix, $VMserver, $dataStoreStore)
            #Write-Host "-name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -ResourcePool"$Server.ResourcePool
            New-vm -name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -ResourcePool $Server.ResourcePool  
      }}
      S {
         $server = Read-Host -Prompt 'Single COOP (ServerName) ' 
         $COOPPrefix+$server
         New-vm -name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -whatif
      }
      Default {Write-Host 'Exit'}
}}
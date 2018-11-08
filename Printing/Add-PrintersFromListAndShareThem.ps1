
Function Add-PortPrintersAndShares
{

   [cmdletbinding()]

   Param()

   $WorkingFolder = 'Printing'
   $WorkingFile = 'PrinterList.csv'
   $WorkingPath = "$env:HOMEDRIVE\Temp\Printing"

   $SleepTime = 500
   $i = 1 

   $ActivityText = 'Setting-Up Printers'
   $StatPrinterPort = 'Building Printer Ports'
   $StatPrinter = 'Building Printers'
   $StatPrinterShare = 'Sharing Printers'
   
   function Sleep-Now{if ($SleepTime -gt 0){ Start-Sleep -Milliseconds $SleepTime}}

   if(test-path -Path ($WorkingPath)){
      Set-Location -Path $WorkingPath
   
      if(test-path -Path ($WorkingFile)){

         $PrinterList = import-csv -Path $WorkingFile
         $PrinterListCount = $PrinterList.Count
         $SleepTime = $SleepTime - ($PrinterList.Count * 2)
         Write-Verbose -Message ('Printer Count {0}' -f $PrinterListCount)

         $TotalPercent = $PrinterListCount*3
         ForEach($Printer in $PrinterList){
            $portaddress = $Printer.portaddress
            $portname = $Printer.PortName
            Sleep-Now
            Add-PrinterPort -name $portname -printerhostaddress $portaddress -WhatIf
            Write-Progress -Activity $ActivityText -status ('{0} - {1}' -f $StatPrinterPort, $portname) -PercentComplete ($i / $TotalPercent*100)
            $i++
         }
   
         ForEach($Printer in $PrinterList){
            $PrinterName = $Printer.Name
            $Drivername = $Printer.DriverName
            $portname = $Printer.PortName
            $ShareName = $Printer.ShareName
            Sleep-Now
    
            Add-Printer -Name $PrinterName -DriverName $Drivername -PortName $portname -WhatIf
            Write-Progress -Activity $ActivityText -status ('{0} - {1}' -f $StatPrinter, $PrinterName) -PercentComplete ($i / $TotalPercent*100)
            $i++
         }

         ForEach($Printer in $PrinterList){
            $ShareName = $Printer.ShareName
            $PrinterName = $Printer.name
            Sleep-Now
   
            Set-Printer -name $PrinterName -Shared $true -ShareName $ShareName -Published $true -WhatIf
            Write-Progress -Activity $ActivityText -status ('{0} - {1}' -f $StatPrinterShare, $ShareName) -PercentComplete ($i / $TotalPercent*100)
            $i++
         }
      }
      else{
         New-Item -Path $WorkingPath -Name $WorkingFile -ItemType File
         Write-Warning -Message 'Working Location Not as expected. Move or Copy printerslist.csv to .\temp\Printing directory'
      }
   }
   else{
      Write-Warning -Message 'Working Location Not as expected. Move or Copy printers.csv to .\temp\Printing directory'
      New-Item -Path "$env:HOMEDRIVE\Temp\" -Name $WorkingFolder -ItemType Directory
      For($i = 1; $i -le 100){
         [Console]::Beep(($x*330), (50*$x))
         Write-Progress -Activity 'Building Directory' -PercentComplete ($i / 1)
         $x = (Get-Random -Minimum 2 -Maximum 11)
         $i = $i + $x
         [Console]::Beep(($x*800), (20*$x))
      }
   
   }
}

# Start Script
Add-PortPrintersAndShares -Verbose

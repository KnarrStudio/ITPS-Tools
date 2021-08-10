#requires -Version 2.0 -Modules PrintManagement

Function Add-PortPrintersAndShares
{
  <#
      .SYNOPSIS
      Imports the names, ports and share names of printers and installs them on the print server

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      Add-PortPrintersAndShares
      Opens the printerlist.csv and installs the printer s listed.

      .NOTES
      The printerlist.csv is formatted:
      Name,Datatype,DriverName,KeepPrintedJobs,Location,PortName,PortAddress,PrintProcessor,Priority,Published,Shared,ShareName
      testprinter34,RAW,Microsoft Print To PDF,FALSE,AV34,3.34_TestPrinter,192.168.3.34,winprint,1,FALSE,FALSE,Test-Printer_34
  #>

  param
  (
    [Parameter(Mandatory = $false, Position = 0)]
    [string]
    $WorkingFolder = 'Printing',
  
    [Parameter(Mandatory = $false, Position = 1)]
    [string]
    $WorkingFile = 'PrinterList.csv',
  
    [Parameter(Mandatory = $false, Position = 2)]
    [string]
    $WorkingPath = "$env:HOMEDRIVE\Temp\Printing"
  )

  $i = 1 
  
  $ActivityText = 'Setting-Up Printers'
  $StatPrinterPort = 'Building Printer Ports'
  $StatPrinter = 'Building Printers'
  $StatPrinterShare = 'Sharing Printers'
  
  function Invoke-Sleep
  {
    Param(
      [Parameter(Mandatory = $false)]
    [int]$SleepTime = 500)
    if ($SleepTime -gt 0)
    {
      Start-Sleep -Milliseconds $SleepTime
    }
  }
  
  if(Test-Path -Path ($WorkingPath))
  {
    Set-Location -Path $WorkingPath
  
    if(Test-Path -Path ($WorkingFile))
    {
      $PrinterList = Import-Csv -Path $WorkingFile
      $PrinterListCount = $PrinterList.Count
      $SleepTime = $SleepTime - ($PrinterList.Count * 2)
      Write-Verbose -Message ('Printer Count {0}' -f $PrinterListCount)
  
      $TotalPercent = $PrinterListCount*3
      ForEach($Printer in $PrinterList)
      {
        $portaddress = $Printer.portaddress
        $portname = $Printer.PortName
        Invoke-Sleep
        Add-PrinterPort -Name $portname -PrinterHostAddress $portaddress -WhatIf
        Write-Progress -Activity $ActivityText -Status ('{0} - {1}' -f $StatPrinterPort, $portname) -PercentComplete ($i / $TotalPercent*100)
        $i++
      }
      ForEach($Printer in $PrinterList)
      {
        $PrinterName = $Printer.Name
        $Drivername = $Printer.DriverName
        $portname = $Printer.PortName
        $ShareName = $Printer.ShareName
        Invoke-Sleep
  
        Add-Printer -Name $PrinterName -DriverName $Drivername -PortName $portname -WhatIf
        Write-Progress -Activity $ActivityText -Status ('{0} - {1}' -f $StatPrinter, $PrinterName) -PercentComplete ($i / $TotalPercent*100)
        $i++
      }
  
      ForEach($Printer in $PrinterList)
      {
        $ShareName = $Printer.ShareName
        $PrinterName = $Printer.name
        Invoke-Sleep
  
        Set-Printer -Name $PrinterName -Shared $true -ShareName $ShareName -Published $true -WhatIf
        Write-Progress -Activity $ActivityText -Status ('{0} - {1}' -f $StatPrinterShare, $ShareName) -PercentComplete ($i / $TotalPercent*100)
        $i++
      }
    }
    else
    {
      New-Item -Path $WorkingPath -Name $WorkingFile -ItemType File
      Write-Warning -Message 'Working Location Not as expected. Move or Copy printerslist.csv to .\temp\Printing directory'
    }
  }
  else
  {
    Write-Warning -Message 'Working Location Not as expected. Move or Copy printers.csv to .\temp\Printing directory'
    New-Item -Path "$env:HOMEDRIVE\Temp\" -Name $WorkingFolder -ItemType Directory
    For($i = 1; $i -le 100;$i++)
    {
      $x = (Get-Random -Minimum 1250 -Maximum 1600)
      [Console]::Beep($x, 85)
      Write-Progress -Activity 'Building Directory' -PercentComplete ($i)
    }
  }
}

# Start Script
Add-PortPrintersAndShares -Verbose

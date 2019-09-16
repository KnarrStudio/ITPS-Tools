#requires -Version 3.0 -Modules PrintManagement
function Add-NetworkPrinter
{
  <#
      .SYNOPSIS
      Retrieves all of the printers you are allowed to see on a print server that you designate.  
      Allows you to select it and adds the printer to your local workstation.

      .PARAMETER Servername
      Name of the print server you will be attaching to.

      .EXAMPLE
      Add-NetworkPrinterBySelection

      .NOTES
      Place additional notes here.
  #>
  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory,HelpMessage = 'Enter the printserver name')]
    [String]$PrintServer
  )
  if(!(Get-Module -Name PrintManagement))
  {
    Write-Verbose -Message 'Importing Print Management Module'
    Import-Module -Name PrintManagement
  }
  Write-Verbose -Message 'Print Management Module Imported'
  if(Test-Connection -ComputerName $PrintServer -Count 1 -Quiet)
  {
    $PrinterSelection = Get-Printer -ComputerName $PrintServer |
    Select-Object -Property Name, DriverName, PortName |
    Out-GridView -PassThru -Title "Printer Select-O-Matic!"
    Write-Verbose -Message ('Printer Selected {0}' -f $PrinterSelection)
   
    $PrinterName = $PrinterSelection.name
    Write-Verbose -Message ('Pritner Name {0}' -f $PrinterName)
   
    #$PrintServer = 'test'
    Add-Printer -ConnectionName ('\\{0}\{1}' -f $PrintServer, $PrinterName)  #-WhatIf
    Write-Verbose -Message ('Printer Connected \\{0}\{1}' -f $PrintServer, $PrinterName)
  }
  else
  {
    Write-Warning -Message ('Unable to connect to {0}.' -f $PrintServer)
  }
}

#Add-NetworkPrinter -PrintServer ServerName


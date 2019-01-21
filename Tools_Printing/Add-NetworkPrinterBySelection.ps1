  <#
      .SYNOPSIS
      Retrieves all of the printers you are allowed to see on a print server that you designate.  Allows you to select it and adds the printer to your local workstation.

      .PARAMETER Servername
      Name of the print server you will be attaching to.

      .EXAMPLE
      Add-NetworkPrinterBySelection
	
      .NOTES
      Place additional notes here.
  #>


$PrintServer = '\\Servername'

$PrinterSelection = get-printer <#-ComputerName $PrintServer#> | select Name, DriverName,PortName | Out-GridView -PassThru
Add-Printer -ConnectionName ('{0}\{1}' -f $PrintServer,$PrinterSelection.name) -whatif
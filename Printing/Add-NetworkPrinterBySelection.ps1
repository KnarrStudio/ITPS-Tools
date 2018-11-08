$PrintServer = '\\Servername'

$PrinterSelection = get-printer <#-ComputerName $PrintServer#> | select Name, DriverName,PortName | Out-GridView -PassThru
Add-Printer -ConnectionName ('{0}\{1}' -f $PrintServer,$PrinterSelection.name) -whatif
#requires -Version 3.0 -Modules PrintManagement


$PrintServer = 'PrintServer'
$PingReportFolder = '\\NetworkShare\Reports\PrinterStatus'
$BadCount = 0
$DateNow = Get-Date -UFormat %Y%m%d-%H%M%S
$ReportFile = (('{0}\{1}-PrinterReport.csv' -f $PingReportFolder, $DateNow))
$PrinterSiteList = (('{0}\{1}-FullPrinterList.csv' -f $PingReportFolder, $DateNow))
$i = 0
 
if(!(Test-Path -Path $PingReportFolder))
{
  New-Item -Path $PingReportFolder -ItemType Directory
}
 
Get-Printer -ComputerName $PrintServer |
Select-Object -Property Name, PrinterStatus, DriverName, PortName, Published |
Export-Csv -Path $PrinterSiteList -NoTypeInformation
 
$PrinterList = Import-Csv -Path $PrinterSiteList # -Header Name
$TotalPrinters = $PrinterList.count -1
 

if($TotalPrinters -gt 0)
{
  foreach($OnePrinter in $PrinterList)
  {
    $PrinterName = $OnePrinter.Name
    if ($PrinterName -ne 'Name')
    {
      $PortName = (get-printer -ComputerName $PrintServer -Name $PrinterName).PortName
      $PrinterIpAddress = Get-PrinterPort -ComputerName $PrintServer -Name $PortName | Select-Object -ExpandProperty PrinterHostAddress -ErrorAction SilentlyContinue
      if ($PrinterIpAddress -match '192.')
      {
        if(-not  $(Test-Connection -ComputerName $PrinterIpAddress -ErrorAction SilentlyContinue -Count 1))
        {
          Write-Host ('The printer {0} failed to respond to a ping!  ' -f $PrinterName) -f Red
        }
      }
    }

    #Start-Sleep -Seconds .5
    Write-Progress -Activity ('Testing {0}' -f $PrinterName) -PercentComplete ($i / $TotalPrinters*100)
    $i++
    if($OnePrinter.PrinterStatus -ne 'Normal')
    {
      $BadCount ++
      $PrinterProperties = $OnePrinter
      if($BadCount -eq 1)
      {
        $PrinterProperties | Export-Csv -Path $ReportFile -NoClobber -NoTypeInformation
      }
      else
      {
        $PrinterProperties | Export-Csv -Path $ReportFile -NoTypeInformation -Append
      }
    }
  }
}


#Clear-Host
Write-Host -Object ('Total Printers found: {0}' -f $TotalPrinters) -ForegroundColor Green
Write-Host -Object ('Total Printers not in a Normal Status: {0}' -f $BadCount) -ForegroundColor Red
Write-Host -Object "This test was run by $env:USERNAME from $env:COMPUTERNAME"
Write-Host -Object ('You can find the full report at: {0}' -f $ReportFile)





function Test-AdWorkstationConnections
{
  [CmdletBinding()]
  param
  (
    [Switch]$Bombastic
  )
  $ADSearchBase = 'OU=Clients-Desktop,OU=Computers,DC=Knarrstudio,DC=net'
  $PingReportFolder = '\\server\share\Reports\PingReport'
  $BadCount = 0
  $DateNow = Get-Date -UFormat %Y%m%d-%H%M
  $ReportFile = (('{0}\{1}-AdDesktopReport.csv' -f $PingReportFolder, $DateNow))
  $WorkstationSiteList = (('{0}\{1}-AdDesktopList.csv' -f $PingReportFolder, $DateNow))
  $i = 1

  if(!(Test-Path -Path $PingReportFolder))
  {
    New-Item -Path $PingReportFolder -ItemType Directory
  }

  Get-ADComputer -filter * -SearchBase $ADSearchBase -Properties * |
  Select-Object -Property Name, LastLogonDate, Description |
  Sort-Object -Property LastLogonDate -Descending |
  Export-Csv -Path $WorkstationSiteList -NoTypeInformation

  $WorkstationList = Import-Csv -Path $WorkstationSiteList -Header Name
  $TotalWorkstations = $WorkstationList.count -1

  if($TotalWorkstations -gt 0)
  {
    foreach($OneWorkstation in $WorkstationList)
    {
      $WorkstationName = $OneWorkstation.Name
      if ($WorkstationName -ne 'Name')
      {
        Write-Progress -Activity ('Testing {0}' -f $WorkstationName) -PercentComplete ($i / $TotalWorkstations*100)
        $i++
        $Ping = Test-Connection -ComputerName $WorkstationName -Count 1 -Quiet
        if($Ping -ne 'True')
        {
          $BadCount ++
          $WorkstationProperties = Get-ADComputer -Identity $WorkstationName -Properties * | Select-Object -Property Name, LastLogonDate, Description
          if($BadCount -eq 1)
          {
            $WorkstationProperties | Export-Csv -Path $ReportFile -NoClobber -NoTypeInformation
          }
          else
          {
            $WorkstationProperties | Export-Csv -Path $ReportFile -NoTypeInformation -Append
          }
        }
      }
    }
  }

  if ($Bombastic)
  {
    Write-Host ('Total workstations found in AD: {0}' -f $TotalWorkstations) -ForegroundColor Green
    Write-Host ('Total workstations not responding: {0}' -f $BadCount) -ForegroundColor Red
    Write-Host "This test was run by $env:USERNAME from $env:COMPUTERNAME"
    Write-Host ('You can find the full report at: {0}' -f $ReportFile)
  }
}

Test-AdWorkstationConnections -Bombastic
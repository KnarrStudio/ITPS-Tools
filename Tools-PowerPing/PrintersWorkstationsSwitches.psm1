#requires -Version 3.0 -Modules NetTCPIP, PrintManagement


function Test-PrinterStatus
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Test-PrinterStatus
      explains how to use the command
      can be multiple lines
      .EXAMPLE
      Test-PrinterStatus
      another example
      can have as many examples as you like
  #>
  param
  (
    [Parameter(Mandatory = $true,HelpMessage = 'Add PrintServer name', Position = 0)]
    [string]
    $PrintServer,
    
    [Parameter(Mandatory = $true,HelpMessage = '\\NetworkShare\Reports\PrinterStatus or c:\temp',Position = 1)]
    [string]
    $PingReportFolder
  )
  
  $BadCount = 0
  $DateStamp = Get-Date -UFormat %Y%m%d-%H%M%S
  $ReportFile = (('{0}\{1}-PrinterReport.csv' -f $PingReportFolder, $DateStamp))
  $PrinterSiteList = (('{0}\{1}-FullPrinterList.csv' -f $PingReportFolder, $DateStamp))
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
        $PrinterIpAddress = Get-PrinterPort -ComputerName $PrintServer -Name $PrinterName | Select-Object -Property PrinterHostAddress -ErrorAction SilentlyContinue
        if ($PrinterIpAddress)
        {
          $PingPortResult = Test-Connection -ComputerName $PrinterIpAddress -Count 1 -Quiet 
          if($PingPortResult -eq $false)
          {
            Write-Host ('The printer {0} failed to respond to a ping!  ' -f $PrinterName) -f Red
          }
          elseif($PingPortResult -eq $true)
          {
            Write-Host ('The printer {0} responded to a ping!  ' -f $PrinterName) -f Green
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
  
  Write-Verbose -Message ('Total Printers found: {0}' -f $TotalPrinters)
  Write-Verbose -Message ('Total Printers not in a Normal Status: {0}' -f $BadCount)
  Write-Verbose -Message "This test was run by $env:USERNAME from $env:COMPUTERNAME"
  Write-Verbose -Message ('You can find the full report at: {0}' -f $ReportFile)
}

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

function Test-FiberSatillite
{
  param
  (
    [Parameter(Position = 0)]
    [Object[]]
    $Sites = ('www.google.com', 'www.bing.com', 'www.cnn.com', 'www.facebook.com', 'www.yahoo.com')
  )
  
  $RttTotal = 0
  $TotalSites = $Sites.Count
  function Test-Verbose 
  {
    [Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
  }
  
  ForEach ($Site in $Sites)  
  {
    $PingReply = Test-NetConnection -ComputerName $Site 
    $RTT = $PingReply.PingReplyDetails.RoundtripTime
    $RttTotal = $RttTotal + $RTT
    
    Write-Verbose -Message ('{0} - RoundTripTime is {1} ms.' -f $PingReply.Computername, $RTT)
  }

  $RTT = $RttTotal/$TotalSites
    
  if(Test-Verbose)
  {
    if($RTT -gt 380)
    {
      Write-Host('Although not always the case this could indicate that you are on the Satellite backup circuit.') -BackgroundColor Red -ForegroundColor White
    }
    ElseIf($RTT -gt 90)
    {
      Write-Host ('Although not always the case this could indicate that you are on the Puerto Rico backup circuit.') -BackgroundColor Yellow -ForegroundColor White
    }
    ElseIf($RTT -gt 0)
    {
      Write-Host ('Round Trip Time is GOOD!') -BackgroundColor Green -ForegroundColor White
    }
  }
  <#  Write-Output -InputObject ('Average RTT is {0} ms.' -f [int]$RTT)
      if ($RTT -lt 380){
  Start-Process "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe" }#>
}

#Test-AdWorkstationConnections -Bombastic
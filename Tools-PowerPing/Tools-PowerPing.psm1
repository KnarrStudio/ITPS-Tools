#requires -Version 3.0 -Modules NetTCPIP, PrintManagement

function Test-PrinterStatus
{

  param
  (
    [Parameter(Mandatory = $true,HelpMessage = 'Add PrintServer name', Position = 0)]
    [string]$PrintServer,
    
    [Parameter(Mandatory = $true,HelpMessage = '\\NetworkShare\Reports\PrinterStatus or c:\temp',Position = 1)]
    [string]$PingReportFolder
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

  [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'Low')]
  param(

    [Parameter(Mandatory=$false, Position=1)]
    [String]
    $ADSearchBase = 'OU=Clients-Desktop,OU=Computers,DC=Knarrstudio,DC=net',
    
    [Parameter(Mandatory=$false, Position=0)]
    [String]
    $PingReportFolder = '\\server\share\Reports\PingReport',

        [Parameter(Mandatory=$false, Position=2)]
    [string]
    $OutputFileName = 'AdDesktop',
    
       [Switch]$Bombastic
  )
  
  $i = 1
  $BadCount = 0
  $DateNow = Get-Date -UFormat %Y%m%d-%H%M
  $OutputFileName = ('{0}\{1}-{2}_Results.csv' -f $PingReportFolder, $DateNow,$OutputFileName)
  $WorkstationSiteList = ('{0}\{1}-{2}_List.csv' -f $PingReportFolder, $DateNow,$OutputFileName)
  

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
            $WorkstationProperties | Export-Csv -Path $OutputFileName -NoClobber -NoTypeInformation
          }
          else
          {
            $WorkstationProperties | Export-Csv -Path $OutputFileName -NoTypeInformation -Append
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
    Write-Host ('You can find the full report at: {0}' -f $OutputFileName)
  }
}

function Test-FiberSatellite
{
  <#
      .SYNOPSIS
      "Pings" a group of sites or servers and gives a response in laymans terms.

      .DESCRIPTION
      This started due to our need to find out if we were running on Fiber or not.  There are some default off island sites that it will test, but you can pass them if you only want to check one or two sites.

      .PARAMETER Sites
      A single or list of sites or servers that you want to test against.

      .PARAMETER OneLineOutput
      Provides a single output line for those who just need answers.

      .EXAMPLE
      Test-FiberSatellite -Sites Value -OneLineOutput
      Tests the Value and displays the output as a single line of text

      .NOTES
      Place additional notes here.

      .LINK
      https://github.com/KnarrStudio/ITPS-Tools/wiki

      .OUTPUTS
      To console or screen at this time.
  #>

  param
  (
    [Parameter(Position = 0)]
    [Object[]] $Sites = ('LocalServer', 'localhost', 'www.google.com', 'www.bing.com', 'www.wolframalpha.com', 'www.yahoo.com'),
    [Switch]$OneLineOutput
  )
  
  $RttTotal = $NotRight = 0
  $TotalResponses = $TotalSites = $Sites.Count
  function Test-Verbose 
  {
    [Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
  }
    if(-not $OneLineOutput)
    {
    Write-Host ('The Ping-O-Matic Fiber Tester!') -BackgroundColor DarkYellow -ForegroundColor White}
  ForEach ($Site in $Sites)  
  {
    $PingReply = Test-NetConnection -ComputerName $Site 
    if($PingReply.PingSucceeded -eq $true)
    {
      $RTT = $PingReply.PingReplyDetails.RoundtripTime
      $RttTotal = $RttTotal + $RTT
    
      if($RTT -eq 0)
      {
        $TotalResponses = $TotalResponses - 1
        $NotRight = $NotRight + 1
      }
      Write-Verbose -Message ('{0} - RoundTripTime is {1} ms.' -f $PingReply.Computername, $RTT)
    }
    Else
    {
      $TotalResponses = $TotalResponses - 1
    }
  }

  $RTT = $RttTotal/$TotalResponses
  $TimeStamp = Get-Date -Format 'dd-MMM-yyyy HH:mm'
  if(-not $OneLineOutput)
  {
    <#    if(Test-Verbose)
    {#>
    if($RTT -gt 380)
    {
      Write-Host('Although not always the case this could indicate that you are on the Satellite backup circuit.') -BackgroundColor Red -ForegroundColor White
    }
    ElseIf($RTT -gt 90)
    {
      Write-Host ('Although not always the case this could indicate that you are on the Puerto Rico backup circuit.') -BackgroundColor Yellow -ForegroundColor White
    }
    ElseIf($RTT -gt 1)
    {
      Write-Host ('Round Trip Time is GOOD!') -BackgroundColor Green -ForegroundColor White
    }
    # }
  }
  Write-Host ('{1} - {3} tested {0} off island computers and {2} responded. The average response time:' -f $TotalSites, $TimeStamp, $TotalResponses, $env:USERNAME) -ForegroundColor DarkYellow -NoNewline
  Write-Output -InputObject (' {0} ms' -f [int]$RTT)

  if($NotRight -gt 0)
  {
    Write-Output -InputObject ('{0} Responded with 0 ms' -f $NotRight)
  }

  <#  Write-Output -InputObject ('Average RTT is {0} ms.' -f [int]$RTT)
      if ($RTT -lt 380){
  Start-Process "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe" }#>
}

<#Test-FiberSatellite -Verbose 
Test-PrinterStatus -Verbose
Test-AdWorkstationConnections -Bombastic
#>


function Test-AdWorkstationConnections
{
  param
  (
    [Parameter(Mandatory,HelpMessage='OU=Clients-Desktop,OU=Computers,DC=Knarrstudio,DC=net', Position = 0)]
    [string]
    $ADSearchBase,
    
    [Parameter(Mandatory,HelpMessage='\\server\share\Reports\PingReport', Position = 1)]
    [string]
    $PingReportFolder
  )

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
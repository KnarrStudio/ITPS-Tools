function Test-WorkstationConnection
{
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'Low')]

  param(
    [Parameter(Mandatory,HelpMessage = 'Add one or more computer namesage for user',
        ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('hostname')]
    [ValidateLength(7, 14)]
    [ValidateCount(1)]
    [string[]]$computername,

    [switch]$ReportLog
  )
  # Windows File names cannot contain \/:*?"<>|
  BEGIN {
    $null = 0
    $BadCount = 0
    $DateNow = Get-Date -UFormat %Y%m%d-%H%M
    $WorkstationSiteList = "$env:HOMEDRIVE\Temp\SiteList.csv"
    $ReportFile = "$env:HOMEDRIVE\temp\$DateNow-Report.txt"

    if(!(Test-Path -Path $WorkstationSiteList))
    {
      $ADSearchBase = 'OU=Clients-Desktop,OU=Computers,OU=SOUTH,DC=localdomain'
      get-adcomputer -filter * -SearchBase $ADSearchBase |
      Select-Object -ExpandProperty name |
      Export-Csv -Path $WorkstationSiteList -NoTypeInformation
    }

    $WorkstationList = Import-Csv -Path $WorkstationSiteList


    if($ReportLog)
    {
      Write-Verbose -Message 'Finding Report Log file' 
      $i = 0
      Do 
      { 
        $logFile = "names-$i.txt"
        $i ++
      } While (Test-Path -Path $logFile)
      Write-Verbose -Message "Log file name will be $name-$i.txt"
    }
    else
    {
      Write-Verbose -Message 'Name Logging off'
    }
  }

  PROCESS {
    Write-Debug -Message 'Starting Process Block'

    Write-Debug -Message 'Starting For Loop'

    foreach($OneWorkstation in $WorkstationList)
    {
      if($PSCmdlet.ShouldProcess($computer))
      {
        Write-Verbose -Message "Connecting to $computer"
        Write-Debug -Message "All computers $computer.name"

        if ($ReportFile)
        {
          $WorkstationProperties | Export-Csv -Path $ReportFile -NoTypeInformation -Append
        }

        try
        {
          $continue = $true
          # Meat and Potatos - - - Get-WmiObject -ErrorAction 'Stop' -class win32_bios | select serialnumber

          $WorkstationName = $OneWorkstation.Name
          $Ping = Test-Connection -ErrorAction 'stop' -ComputerName $WorkstationName -Count 1 -Quiet
          if($Ping -ne 'True')
          {
            $BadCount += 1
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
        catch
        {
          $continue = $false
          $WorkstationProperties | Export-Csv -Path $ReportFile -NoTypeInformation -Append
        }
      }
    }
    END {

    }

  }
}

get-OurVMInfo -computername localhost, test2 -Verbose -namelog

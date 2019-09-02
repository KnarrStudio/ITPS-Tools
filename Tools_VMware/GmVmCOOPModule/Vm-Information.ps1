function get-OurVMInfo
{
  <#
      .SYNOPSIS
      Describe purpose of "get-OurVMInfo" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER computername
      Describe parameter -computername.

      .PARAMETER namelog
      Describe parameter -namelog.

      .EXAMPLE
      get-OurVMInfo -computername Value -namelog
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online get-OurVMInfo

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'Low')]

  param(
    [Parameter(Mandatory,HelpMessage = 'Add one or more computer namesage for user',
        ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('hostname')]
    [ValidateLength(3, 14)]
    [ValidateCount(1, 10)]
    [string[]]$computername,

    [switch]$namelog
  )

  BEGIN {

    if($namelog)
    {
      Write-Verbose -Message 'Finding Name Log file' 
      $i = 0
      Do 
      { 
        $logFile = ('names-{0}.txt' -f $i)
        $i ++
      } While (Test-Path -Path $logFile)
      Write-Verbose -Message ('Log file name will be {0}-{1}.txt' -f $name, $i)
    }
    else
    {
      Write-Verbose -Message 'Name Logging off'
    }
  }

  PROCESS {
    Write-Debug -Message 'Starting Process Block'
      
    Write-Debug -Message 'Starting For Loop'

    foreach ($computer in $computername)
    {
      if($PSCmdlet.ShouldProcess($computer))
      {
        Write-Verbose -Message ('Connecting to {0}' -f $computer)
        Write-Host ('All computers {0}' -f $computername)

        if ($namelog)
        {
          $computer | Out-File -FilePath $logFile -Append
        }

        try
        {
          $continue = $true
          Get-WmiObject -ErrorAction 'Stop' -Class win32_bios | Select-Object -Property serialnumber
        }
        catch
        {
          $continue = $false
          $computer | Out-File -FilePath .\ErrorLog.txt
        }
      }
    }
    END {

    }

  }
}


get-OurVMInfo -computername localhost, test2 -Verbose -namelog

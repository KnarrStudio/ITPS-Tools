function Uninstall-Software  
{
  <#
      .SYNOPSIS
      Uninstall unneeded or unwanted software
  #>

  [CmdletBinding(SupportsShouldProcess)]
  param
  (
    [Parameter(Mandatory,HelpMessage = 'Software DisplayName', Position = 0)]
    [String]$SoftwareName
  )
    
  function Get-SoftwareGUID
  {
    param
    (
      [Object]
      [Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = 'Data to filter')]
      $InputObject
    )
    process
    {
      if ($InputObject.IdentifyingNumber -match $GUID)
      {
        $InputObject
      }
    }
  }

  $HKLMPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
  
  $SoftwareList = (Get-ChildItem -Path $HKLMPath   |
    Get-ItemProperty  | 
    Where-Object -FilterScript {
      $_.DisplayName -match $SoftwareName
    } | Select-Object -Property DisplayName, UninstallString)
    
    $SoftwareList = $SoftwareList | Out-GridView -PassThru -Title "Varify Software to Remove"
    

  #$SoftwareList

  $MSIExecCount = 0
  $EXECount = 0
  foreach ($app in $SoftwareList) 
  {
  if(($app.UninstallString) -match 'MSIEXEC'){
  Write-host "MSIEXEC"
  $MSIExecCount = $MSIExecCount + 1
  $MSIExecCount
  }
  elseif(($app.UninstallString) -match 'EXE'){
  Write-host "EXE $($app.UninstallString)"
  $EXECount = $EXECount + 1
  $EXECount
  }
  }

    Write-Verbose -Message ('App - {0}' -f $app)
    #$App.UninstallString
    If ($app.UninstallString) 
    {
      Write-Verbose -Message ('App Uninstall - {0}' -f $app.UninstallString)

      $uninst = ($app.UninstallString)
      Write-Verbose -Message ('UninstallString - {0}'  -f  $uninst)

      $GUID = ($uninst.split('{')[1]).trim('}')
      Write-Verbose -Message ('App GUID - {0}' -f  $GUID)

      $app = Get-WmiObject -Class Win32_Product -ComputerName $env:COMPUTERNAME| Get-SoftwareGUID
      #$app.Uninstall()
      #Start-Process -FilePath 'msiexec.exe' -ArgumentList "/X $GUID /passive" -Wait

      #Write-Host $uninst
    }
  }
}





Uninstall-Software -SoftwareName 'Java 8 Update 161' -Verbose
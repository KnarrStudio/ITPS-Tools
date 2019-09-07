#requires -Version 3.0
function Test-SafetySwitch
{
  for($i = 1;$i -le 3;$i++)
  {
    $p = New-Item -Path . -Name ('efa-testfile{0}{1}.txt' -f (Get-Date -UFormat %M%S), $i) -ItemType 'file' #-WhatIf:$false
    Get-ChildItem -Path . |
    Format-Table -Property Name |
    Out-File -FilePath $p #-WhatIf:$false
  }
}


Function Invoke-SetSafetyLoop
{
  param(
    [Parameter(Mandatory,
        ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('toggle')]
    [Switch]$ToggleSwitch
  )

  Do 
  {
    $ToggleSwitch = [int](Read-Host -Prompt 'Toggle')
    if ($ToggleSwitch -eq 0)
    {
      if($script:WhatIfPreference -eq $true)
      {
        $script:WhatIfPreference = 'False'
        Write-Host 'Safety Off' -BackgroundColor Red
      }
      Else
      {
        $script:WhatIfPreference = 'True'
        Write-Host 'Safety On' -BackgroundColor Green
      }
    }
    Clear-Host
  }
  While ($ToggleSwitch -eq 0)
}

Function Set-SafetySwitch
{
  [CmdletBinding()]
  param(
    [Alias('toggle')]
    [Switch]$ToggleSwitch
  )

  Write-Verbose -Message ('What if Preference 1: {0}' -f $script:WhatIfPreference)
  <#  If ($ToggleSwitch)
  {    #>
  If ($script:WhatIfPreference -eq $true)
  {
    Write-Verbose -Message 'Setting the WhatIfPreference to False'
    $script:WhatIfPreference = $false
  }
  else
  {
    Write-Verbose -Message 'Setting the WhatIfPreference to True'
    $script:WhatIfPreference = $true
  }
  #}
  # Write-Verbose "Toggle Switch: $ToggleSwitch"
  Write-Verbose -Message ('What if Preference 2: {0}' -f $script:WhatIfPreference)
  
  #return $WhatIfPreference
}

#requires -Version 3.0

function Repair-FolderRedirection
{
  #Content
  <#
      .Synopsis
      Changes the Location on the Profile folders to match network profile
      
      .EXAMPLE
      Repair-FolderRedirection

      .EXAMPLE
      Repair-FolderRedirection -RemotePath 'H:\_MyComputer'
  #>
  
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'High')]
  [OutputType([int])]
  Param
  (
    # $RemotePath Path to the Users's 'H:' drive
    [Parameter(Mandatory = $false,
        ValueFromPipelineByPropertyName,
    Position = 0)]
    [string]$RemotePath = 'H:\_MyComputer'
  )
  
  Begin
  {
    $FolderList = @{
      'Desktop'   = 'Desktop'
      'Favorites' = 'Favorites'
      'My Music'  = 'Music'
      'My Pictures' = 'Pictures'
      'My Video'  = 'Videos'
      'Personal'  = 'Documents'
    }
    $Keys = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders', 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders'
    $RemotePath = $Env:USERPROFILE
  }
  Process
  {
    foreach($FolderKey in $FolderList.keys)
    {
      $FolderName = $FolderList.Item($FolderKey)
      $OldPath = ('{0}\{1}' -f $RemotePath, $FolderName)
      $NewPath = ('{0}\{1}' -f $RemotePath, $FolderName)

      If(-Not(Test-Path -Path $NewPath ))
      {
        New-Item -Path $NewPath -ItemType Directory -WhatIf
      }

      Copy-Item -Path $OldPath -Destination $RemotePath -Recurse -WhatIf
      
      foreach($RegKey in $Keys)
      {
        Get-ItemProperty -Path $RegKey -Name $FolderKey

        #Test Path - Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
        Write-Verbose -Message $FolderKey
        Write-Verbose -Message $FolderName


        Set-ItemProperty -Path $RegKey -Name $FolderKey -Value $NewPath
      }
    }
  }
}
End
{

}
 
Repair-FolderRedirection -RemotePath 'H:\_MyComputer'





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
    [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName,Position = 0)]
    [string]$RemotePath = "$env:HOMEDRIVE\_MyComputer"
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
    $LocalPath = $Env:USERPROFILE
    $errorlog = "ErrorLog-$(Get-Date -UFormat %d%S).txt"
  }
  Process
  {
    foreach($FolderKey in $FolderList.keys)
    {
      $FolderName = $FolderList.Item($FolderKey)
      $OldPath = ('{0}\{1}' -f $LocalPath, $FolderName)
      $NewPath = ('{0}\{1}' -f $RemotePath, $FolderName)
      Write-Verbose -Message ('FolderName = {0}' -f $FolderName)
      Write-Verbose -Message ('OldPath = {0}' -f $OldPath)
      Write-Verbose -Message ('NewPath = {0}' -f $NewPath)
            
      If(-Not(Test-Path -Path $NewPath ))
      {
        Write-Verbose -Message ('NewPath = {0}' -f $NewPath)
        New-Item -Path $NewPath -ItemType Directory
      }

      Write-Verbose -Message ('OldPath = {0}' -f $OldPath)
      try
      {
        Copy-Item -Path $OldPath -Destination $RemotePath -Recurse -ErrorAction stop  # -ErrorAction SilentlyContinue
      }
      catch
      {
        $OldPath + $_.Exception.Message | Out-File -FilePath ('{0}\{1}' -f $RemotePath, $errorlog) -Append
      }
      
      foreach($RegKey in $Keys)
      {
        Write-Verbose -Message ('FolderKey = {0}' -f $FolderKey)
        Write-Verbose -Message ('FolderName = {0}' -f $FolderName)

        Write-Verbose -Message ('RegKey = {0}' -f $RegKey)
        Get-ItemProperty -Path $RegKey -Name $FolderKey

        #Test Path - Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
 
        Set-ItemProperty -Path $RegKey -Name $FolderKey -Value $NewPath
      }
    }
  }
}
 
Repair-FolderRedirection -RemotePath 'H:\_MyComputer' -Verbose




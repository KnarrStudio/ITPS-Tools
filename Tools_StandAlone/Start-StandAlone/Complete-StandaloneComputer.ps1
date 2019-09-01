#Requires -RunAsAdministrator
#Requires -Modules Microsoft.PowerShell.LocalAccounts

<#
    .SYNOPSIS
    This script is to help out with the building of the stand alone systems.
    It should be able to do the following by the time it is completed.

    .DESCRIPTION
    1. Add new user[s] 
    2. Add users to specific groups
    3. Uninstall unneeded software
    4. Build a standard folder structure that will be used for the care and feeding
    5. Make registry changes as required by the function of the device *Later versions

    .EXAMPLE
    Complete-StandaloneComputer.ps1

#>

# Add new users
Begin{
  $NewUsers = @{
    OMCuser    = @{
      FullName            = 'OMC User'
      Description         = 'Standard local Account'
      AccountGroup        = 'Users'
      AccountNeverExpires = $true
      Password            = '1qaz@WSX3edc$RFV'
    }
    OMCAdmin   = @{
      FullName            = 'OMC Admin'
      Description         = 'Local Admin Account for IT'
      AccountGroup        = 'Administrators'
      AccountNeverExpires = $true
      Password            = 'OMC@dm!nP@$$!!'
    }
    CRTech     = @{
      FullName            = 'Court Room Tech User'
      Description         = 'Standard Court Room Account'
      AccountGroup        = 'Users'
      AccountNeverExpires = $true
      Password            = '1qaz@WSX3edc$RFV'
    }
    CRAdmin    = @{
      FullName            = 'Court Room Administrator'
      Description         = 'Court Room Admin Account'
      AccountGroup        = 'Administrators'
      AccountNeverExpires = $true
      Password            = '1qaz@WSX3edc$RFV'
    }
    NineOneOne = @{
      FullName            = '911'
      Description         = 'Emergancy Access PW in "KeePass"'
      AccountGroup        = 'Administrators'
      AccountNeverExpires = $true
      Password            = '1qaz@WSX3edc$RFV'
    }
  }



  # Variables
  $NewGroups = @('OMC_Users', 'OMC_Admins', 'TestGroup')
  # $Password911 = Read-Host "Enter a 911 Password" -AsSecureString
  #$PasswordUser = Read-Host -Prompt 'Enter a User Password' -AsSecureString
  #$CurrentUsers = Get-LocalUser
  #$CurrentGroups = Get-LocalGroup
  
  # House keeping

  function New-Folder  
  {
    $NewFolderInfo = [ordered]@{
      CyberUpdates = @{
        Path       = 'C:\CyberUpdates'
        ACLGroup   = 'Administrators'
        ACLControl = 'Full Control'
        ReadMeText = 'This is the working folder for the monthly updates and scanning.'
        ReadMeFile = 'README.TXT'
      }
      ScanReports  = @{
        Path       = 'C:\CyberUpdates\ScanReports'
        ACLGroup   = 'Administrators'
        ACLControl = 'Full Control'
        ReadMeText = 'This is where the "IA" scans engines and reports will be kept.'
        ReadMeFile = 'README.TXT'
      }
    }

    foreach($ItemKey in $NewFolderInfo.keys)
    {
      $NewFolderPath = $NewFolderInfo.$ItemKey.Path
      $NewFile = $NewFolderInfo.$ItemKey.ReadMeFile
      $FileText = $NewFolderInfo.$ItemKey.ReadMeText
    
      If(-not (Test-Path -Path $NewFolderPath))
      {
        New-Item -Path $NewFolderPath -ItemType Directory -Force -WhatIf
        $FileText | Out-File -FilePath $NewFolderPath"\"$NewFile -WhatIf
      }
    }
  }


  function Add-UsersAndGroups  
  {
    <#
        .SYNOPSIS
        Short Description
    #>
    ForEach($NewGroup in $NewGroups)
    {
      $GroupExists = Get-LocalGroup -Name $NewGroup -ErrorAction SilentlyContinue
      if(-not $GroupExists)
      {
        New-LocalGroup -Name $NewGroup -Description $NewGroup -WhatIf
      }
    }
  
    ForEach ($UserName in $NewUsers.Keys) 
    {
      $UserInfo = $NewUsers[$UserName]
      $UserExists = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

      $SecurePassword = ConvertTo-SecureString -String ($UserInfo.Password) -AsPlainText -Force

      If (-not $UserExists)
      {
        $UserDescription = ($UserInfo.Description)
        $UserFullName = ($UserInfo.FullName)

        Write-Verbose -Message ('Creating {0} Account' -f $UserFullName)
        New-LocalUser -Name $UserName -Description $UserDescription -FullName ($UserInfo.FullName) -Password $SecurePassword -WhatIf -Verbose
      }
      $UserExists = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
      If ($UserExists)
      {
        Add-LocalGroupMember -Group $UserInfo.AccountGroup -Member $UserName -WhatIf
      }
    }
  }
  function Uninstall-Software  
  {
    <#
        .SYNOPSIS
        Uninstall unneeded or unwanted software
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
      [Parameter(Mandatory, Position = 0)]
      [String]$SoftwareName
    )
  
    
    function Get-SoftwareList
    {
      param
      (
        [Object]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = 'Data to filter')]
        $InputObject
      )
      process
      {
        if ($InputObject.DisplayName -match $SoftwareName)
        {
          $InputObject
        }
      }
    }

    $SoftwareList = $null

    $app = (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
      Get-ItemProperty | 
      Get-SoftwareList |
    Select-Object -Property DisplayName, UninstallString)
    

    #$SoftwareList

    ForEach ($app in $SoftwareList) 
    {
      #$App.UninstallString
      If ($app.UninstallString) 
      {
        $uninst = ($app.UninstallString)
        $GUID = ($uninst.split('{')[1]).trim('}')
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/X $GUID /passive" -Wait
        #Write-Host $uninst
      }
    }
  }
  function Set-WallPaper  
  {
    <#
        .SYNOPSIS
        Change Desktop picture/background
    #>
 
    param
    (
      [Parameter(Position = 0)]
      #[string]$BackgroundSource = "$env:HOMEDRIVE\Windows\Web\Wallpaper\Windows\img0.jpg",
      #[string]$BackupgroundDest = "$env:PUBLIC\Pictures\BG.jpg"
    [string]$BackgroundSource = "$env:HOMEDRIVE\Windows\Web\Wallpaper\Windows\img0.jpg",
      [string]$BackupgroundDest = "$env:HOMEDRIVE\Windows\Web\Wallpaper\Windows\img0.jpg"
    )
    If ((Test-Path -Path $BackgroundSource) -eq $false)
    {
      Copy-Item -Path $BackgroundSource -Destination $BackupgroundDest -Force -WhatIf
    }
    
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name Wallpaper -Value $BackupgroundDest 
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name TileWallpaper -Value '0'
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value '10' -Force
  }
  function Set-CdLetterToX  
  {
    <#
        .SYNOPSIS
        Test for a CD and change the drive Letter to X:
    #>
    param
    (
      [Parameter(Position = 0)]
      [Object]$CdDrive = (Get-WmiObject -Class Win32_volume -Filter 'DriveType=5'|   Select-Object -First 1)
    )
  
   
    If ($CdDrive)
    {
      if(-not (Test-Path -Path X:\))
      {
        Write-Verbose -Message ('Changing{0} drive letter to X:' -f ([string]$CdDrive.DriveLetter))
        $CdDrive | Set-WmiInstance -Arguments @{
          DriveLetter = 'X:'
        }
      }
    }
  }
}
  
Process{
  New-Folder 
  #Add-UsersAndGroups
  #Set-CdLetterToX
  #Set-WallPaper
  #Uninstall-Software

}
End{}



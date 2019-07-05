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
      AccountGroup        = 'OMC_Users'
      AccountNeverExpires = $true
    }
    AVuser     = @{
      FullName            = 'AV User'
      Description         = 'Standard AV Account'
      AccountGroup        = 'OMC_Users'
      AccountNeverExpires = $true
    }
    AVadmin    = @{
      FullName            = 'AV Administrator'
      Description         = 'AV Admin Account'
      AccountGroup        = 'Administrators'
      AccountNeverExpires = $true
    }
    NineOneOne = @{
      FullName            = '911'
      Description         = 'Emergancy Access PW in "KeePass"'
      AccountGroup        = 'Administrators'
      AccountNeverExpires = $true
    }
  }


# Variables
  $NewGroups = 'OMC_Users'
  #$Password911 = Read-Host "Enter a 911 Password" -AsSecureString
  $PasswordUser = Read-Host -Prompt 'Enter a User Password' -AsSecureString
  $CurrentUsers = Get-LocalUser
  $CurrentGroups = Get-LocalGroup
  


# House keeping
function New-Folder
{
  <#
      .SYNOPSIS
      Add new folders with built in testing for existance.

  #>
  param
  (
    [Parameter(Position = 0)]
    [string] $NewFolder = "$env:HOMEDRIVE\temp\CyberUpdates"
  )
  
    If (-not (Test-Path -Path $_))
    {
      New-Item -Path $_ -ItemType Directory -Force 
      #Set-Acl 
    }

}
  function Add-UsersAndGroups
  {
    <#
        .SYNOPSIS
        Short Description

    #>
    foreach($NewGroup in $NewGroups)
    {
      If ($NewGroup -notin $CurrentGroups)
      {
        New-LocalGroup -Name $NewGroup -Description $NewGroups -WhatIf
      }
    }
  
    ForEach ($UserName in $NewUsers.Keys)
    {
      $UserInfo = $NewUsers[$UserName]
    
      If ($UserName -notin $CurrentUsers)
      {
        $null = $UserInfo.Description
        $null = $UserInfo.FullName
      
        New-LocalUser -Name $UserName -Description $UserInfo.Description -FullName $UserInfo.FullName -Password $PasswordUser -WhatIf -Verbose
      }
      If ($UserName -in $CurrentUsers)
      {
        Add-LocalGroupMember -Group $UserInfo.AccountGroup -Member $UserName -WhatIf
      }
    }
  }

function Uninstall-Software
{
  <#
    .SYNOPSIS
    Short Description
    .DESCRIPTION
    Detailed Description
    .EXAMPLE
    Uninstall-Software
    explains how to use the command
    can be multiple lines
    .EXAMPLE
    Uninstall-Software
    another example
    can have as many examples as you like

  Unistall software
    #>
  $caInstalledSoftware = Get-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* #| Select-Object DisplayName,UninstallString  -Last 10
  $caInstalledSoftware 
}
 
 
  Function Set-WallPaper
  {
    <#
        .SYNOPSIS
        Change Desktop picture/background
    #>
 
    param
    (
      [Parameter(Position = 0)]
      [string]$BackgroundSource = 'c:Temp\Pictures\BG.jpg',
      [string]$BackupgroundDest = "$env:PUBLIC\Pictures\BG.jpg"
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
      Write-Verbose -Message ('Changing{0} drive letter to X:' -f ([string]$CdDrive.DriveLetter))
      $CdDrive | Set-WmiInstance -Arguments @{
        DriveLetter = 'X:'
      }
    }
  }
}

Process{
  New-Folder -NewFolder  "$env:HOMEDRIVE\CyberUpdates"
  Add-UsersAndGroups
  #Set-CdLetterToX
  #Set-WallPaper
  #Uninstall-Software

}




End{}



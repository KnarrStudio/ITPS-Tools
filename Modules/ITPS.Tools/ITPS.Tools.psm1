# Compares Two Folders 
function Compare-Folders 
{
  <#
      .SYNOPSIS
      Compare two folders for clean up

      .EXAMPLE
      Compare-Folders -FolderSource "C:\Temp" -FolderDest"\\Network\Fileshare" -Verbose
      
      .PARAMETER FirstFolder
      The source folder -FirstFolder.

      .PARAMETER SecondFolder
      The Destination -SecondFolder.

  #>
    

  [Cmdletbinding()]
  
  Param
  (
    [Parameter(Mandatory, Position = 0,ValueFromPipeline, ValueFromPipelineByPropertyName)] [Alias('Source','OldFolder')]
    [string]$FirstFolder,
    [Parameter(Mandatory=$False)][Alias('Destination','Staging')]
  [string]$SecondFolder = $null  )

  function Get-FolderStats
  {
    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory = $true, Position = 0)]
      [Object]$InputItem
    )
    $folderSize = (Get-ChildItem -Path $InputItem -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue)
    '{0:N2} MB' -f ($folderSize.Sum / 1MB)
    Write-Debug -Message ('{0} = {1}' -f $InputItem, $('{0:N2} MB' -f ($folderSize.Sum / 1MB)))
    Write-Verbose -Message ('Folder Size = {0}' -f $('{0:N2} MB' -f ($folderSize.Sum / 1MB)))
  }
  
  function Get-Recursed 
  {
    Param
    (
      [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
      [String]$InputItem
    )
    Process
    {
      $SelectedFolderItems = Get-ChildItem -Path $InputItem -Recurse -Force

      Write-Debug -Message ('Get-Recursed = {0}' -f $InputItem)
      Write-Verbose -Message ('Get-Recursed = {0}' -f $InputItem)
      if($SelectedFolderItems -eq $null){
        $SelectedFolderItems = Get-ChildItem -Path $InputItem -Recurse -Force
      }
      Return $SelectedFolderItems = Get-ChildItem -Path $InputItem -Recurse -Force
  }}
  
  function Select-FolderToCompare
  {
    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory = $true, Position = 0)][String]$InputItem,
      [Parameter(Mandatory = $true, Position = 1)][String]$Title
    )
    $FolderSelected = (Get-ChildItem -Path $InputItem |
      Select-Object -Property Name, FullName |
    Out-GridView -Title $Title -OutputMode Single ).fullname

    Write-Verbose -Message ('FolderSourceSelected  = {0}' -f $FolderSelected)
    Write-Debug -Message ('FolderSourceSelected  = {0}' -f $FolderSelected)
    
    Return $FolderSelected
  }

  if(-not $SecondFolder){
    $SecondFolder = [String]$FirstFolder
  }

  $FirstFolderSelected = Select-FolderToCompare  -InputItem $FirstFolder -Title 'Select Folder to Compare' 
  if($FirstFolderSelected -eq $null)
  {
    $FirstFolderSelected = 'Nothing Selected'
    Break
  }
  Write-Debug -Message ('FirstFolderSelected  = {0}' -f $FirstFolderSelected)
  
  $SecondFolderSelected = Select-FolderToCompare -InputItem $SecondFolder -Title "Compare to $FirstFolderSelected"
  if($SecondFolderSelected -eq $null)
  {
    $SecondFolderSelected = 'Nothing Selected'
    Break
  }
  Write-Debug -Message ('SecondFolderSelected  = {0}' -f $SecondFolderSelected)


  #$FirstCompare = Get-ChildItem -Path $FirstFolderSelected -Recurse -Force # 
  $FirstCompare = Get-Recursed -InputItem $FirstFolderSelected
  Write-Debug -Message ('FirstCompare  = {0}' -f $FirstCompare)

  #$SecondCompare = Get-ChildItem -Path $SecondFolderSelected -Recurse -Force #
  $SecondCompare = Get-Recursed -InputItem $SecondFolderSelected
  Write-Debug -Message ('SecondCompare  = {0}' -f $SecondCompare)

  Compare-Object -ReferenceObject $FirstCompare -DifferenceObject $SecondCompare
  

  Write-Verbose -Message ('FolderSourceSize = {0}' -f $(Get-FolderStats -InputItem $FirstFolderSelected))
  Write-Verbose -Message ('FolderDestSize = {0}' -f $(Get-FolderStats -InputItem $SecondFolderSelected))
  Write-Verbose -Message ("'<=' only in {0} " -f $FirstFolderSelected) 
  Write-Verbose -Message ("'=>' only in {0} " -f  $SecondFolderSelected) 
}

# Adds a network printer
function Add-NetworkPrinter
{
  <#
    .SYNOPSIS
    Retrieves all of the printers you are allowed to see on a print server that you designate.  
      Allows you to select it and adds the printer to your local workstation.

    .PARAMETER PrintServer
    Name of the print server you will using.

    .PARAMETER Location
    The location as indicated on the printer properties

    .EXAMPLE
    Add-NetworkPrinter -PrintServer Value -Location Value
    Finds all of the printers with the location set to the value indicated.

    .OUTPUTS
    Connection to a networked printer
  #>


  #requires -Version 3.0 -Modules PrintManagement


  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory,HelpMessage = 'Enter the printserver name',Position=0)]
    [String]$PrintServer,
    [Parameter(HelpMessage = 'Location of printer',Position=1)]
    [AllowNull()]
    [String]$Location
  )
  

try
  {
    if(!(Get-Module -Name PrintManagement))
    {
      Write-Verbose -Message 'Importing Print Management Module'
      Import-Module -Name PrintManagement
    }
    Write-Verbose -Message 'Print Management Module Imported'
    if(Test-Connection -ComputerName $PrintServer -Count 1 -Quiet)
    {
      if($Location)
      {
        $PrinterSelection = Get-Printer -ComputerName $PrintServer |
        Select-Object -Property Name, Location, DriverName, PortName |
        Where-Object{$_.location -match $Location} |
        Out-GridView -PassThru -Title 'Printer Select-O-Matic!' -ErrorAction Stop
        Write-Verbose -Message ('Printer Selected {0}' -f $PrinterSelection)
      }
      else
      {
        $PrinterSelection = Get-Printer -ComputerName $PrintServer |
        Select-Object -Property Name, DriverName, PortName | 
        Out-GridView -PassThru -Title 'Printer Select-O-Matic!' -ErrorAction Stop
        Write-Verbose -Message ('Printer Selected {0}' -f $PrinterSelection)
      }
      $PrinterName = $PrinterSelection.name
      Write-Verbose -Message ('Pritner Name {0}' -f $PrinterName)
   
      #$PrintServer = 'test'
      Add-Printer -ConnectionName ('\\{0}\{1}' -f $PrintServer, $PrinterName) -ErrorAction Stop
      Write-Verbose -Message ('Printer Connected \\{0}\{1}' -f $PrintServer, $PrinterName)
    }
    else
    {
      Write-Warning -Message ('Unable to connect to {0}.' -f $PrintServer)
    }
 

    #Add-NetworkPrinter -PrintServer ServerName
  }
  # NOTE: When you use a SPECIFIC catch block, exceptions thrown by -ErrorAction Stop MAY LACK
  # some InvocationInfo details such as ScriptLineNumber.
  # REMEDY: If that affects you, remove the SPECIFIC exception type [Microsoft.Management.Infrastructure.CimException] in the code below
  # and use ONE generic catch block instead. Such a catch block then handles ALL error types, so you would need to
  # add the logic to handle different error types differently by yourself.
  catch [Microsoft.Management.Infrastructure.CimException]
  {
    # get error record
    [Management.Automation.ErrorRecord]$e = $_

    # retrieve information about runtime error
    $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
    }
  
    # output information. Post-process collected info, and log info (optional)
    $info
  }
}

# Repairs Folder Redirection to location of your choice
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

# Get the installed software on the workstation as a list or specific to find the version
Function Get-InstalledSoftware
{
  <#
      .SYNOPSIS
      "Get-InstalledSoftware" collects all the software listed in the Uninstall registry.

      .PARAMETER SortList
      This will provide a list of installed software from the registry.

      .PARAMETER SoftwareName
      This wil provide the installed date, version, and name of the software in the "value".

      .PARAMETER File
      Will output to a file, but this is currently now working

      .EXAMPLE
      Get-InstalledSoftware -SortList DisplayName

      InstallDate  DisplayVersion   DisplayName 
      -----------  --------------   -----------
      20150128     6.1.1600.0       Windows MultiPoint Server Log Collector 
      02/06/2007   3.1              Windows Driver Package - Silicon Labs Software (DSI_SiUSBXp_3_1) USB  (02/06/2007 3.1) 
      07/25/2013   10.30.0.288      Windows Driver Package - Lenovo (WUDFRd) LenovoVhid  (07/25/2013 10.30.0.288)


      .EXAMPLE
      Get-InstalledSoftware -SoftwareName 'Mozilla Firefox',Green,vlc 

      Installdate  DisplayVersion  DisplayName                     
      -----------  --------------  -----------                     
                   69.0            Mozilla Firefox 69.0 (x64 en-US)
      20170112     1.2.9.112       Greenshot 1.2.9.112             
                   2.1.5           VLC media player  
  #>



  [cmdletbinding(DefaultParameterSetName = 'SortList',SupportsPaging = $true)]
  Param(
    [Parameter(Mandatory,HelpMessage = 'Get list of installed software by installed date or alphabetically', Position = 0,ParameterSetName = 'SortList')]
    [ValidateSet('InstallDate', 'DisplayName')] [Object]$SortList,
    
    [Parameter(Mandatory = $true,HelpMessage = 'At least part of the software name to test', Position = 0,ParameterSetName = 'SoftwareName')]
    [String[]]$SoftwareName,
    [Parameter(Mandatory = $false,HelpMessage = 'At least part of the software name to test', Position = 1,ParameterSetName = 'SoftwareName')]
    [Parameter(ParameterSetName = 'SortList')]
    [Switch]$File
 
  )
  
  Begin{ }
  
  Process {
    Try 
    {
      $InstalledSoftware = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*)
      if($SortList) 
      {
        $InstalledSoftware |
        Sort-Object -Descending -Property $SortList |
        Select-Object -Property @{Name='Date Installed';Exp={$_.Installdate}},@{Name='Version';Exp={$_.DisplayVersion}}, DisplayName #, UninstallString 
      }
      Else 
      {
        foreach($Item in $SoftwareName)
        {
          $InstalledSoftware |
          Where-Object -Property DisplayName -Match -Value $Item |
          Select-Object -Property @{Name='Version';Exp={$_.DisplayVersion}}, DisplayName
        }
      }
    }
    Catch 
    {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
      
      # output information. Post-process collected info, and log info (optional)
      $info
    }
  }
  
  End{ }
}
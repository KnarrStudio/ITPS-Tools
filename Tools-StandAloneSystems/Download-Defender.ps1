#requires -Version 3.0
#Download_Defender.ps1

# Functions
#=======================
Function f_tdFileName
{
  param
  (
    $baseNAME
  )
  $t = Get-Date -UFormat '%d%H%M%S'
  return  $baseNAME + '_' + $t + '.bkp'
}

Function f_verFileName
{
  param
  (
    $baseNAME
  )
  $t = (Get-Item -Path $baseNAME).VersionInfo.FileVersion
  return  $baseNAME + '_' + $t + '.bkp'
}
#f_verFileName $FileDL

Function f_tstFile
{
  param
  (
    $TestFileName
  )
}

Function f_FileDownload ()
{
  Invoke-WebRequest -Uri $Site -OutFile $FileDL
}
    

# User Modifications
#=======================
$Site = 'http://go.microsoft.com/fwlink/?LinkID=87341'
$FileName = 'mpam-feX64'
$FileExt = 'exe'
$FileLocal = 'c:\temp\Defender'



# Begin Script
# =================

# Test and create path for download location
if(!(Test-Path -Path $FileLocal))
{
  Write-Verbose -Message 'Creating Folder'
  New-Item -Path $FileLocal -ItemType Directory
}

# Change the working location
Write-Verbose -Message "Setting location to $FileLocal"
Set-Location $FileLocal

# Get file information from Internet
Write-Verbose -Message "Downloading $FileName file information"
#$FileTst = Invoke-WebRequest -URI $Site 
#$OnlineFileVer = $FileTst.versionInfo.FileVersion

$OnlineFileVer = (Get-Item -Path '.\Copy mpam-feX64 - Copy.exe').versionInfo.FileVersion  #Testing

#Get file information from local file
$LocalFileVer = (Get-Item -Path "$FileName.$FileExt").versionInfo.FileVersion

<# Test to see if the file exists. 
Download it if it does not and test to see if the latest version. #>
if($LocalFileVer -ne $OnlineFileVer)
{
  Write-Verbose -Message 'Getting New filename'
  $NewName = f_verFileName "$FileName.$FileExt"

  if (Test-Path -Path "$FileName.$FileExt")
  {
    Write-Verbose -Message 'Rename local file'
    Rename-Item "$FileName.$FileExt" $NewName
  }

  Write-Verbose -Message 'There is an update available.  Starting Download'
  #Invoke-WebRequest $Site -OutFile "$FileName.$FileExt" 
}

Write-Verbose -Message 'Finished!'

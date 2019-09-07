#requires -version 3

<#
    .SYNOPSIS
    Report of the installed software on a Windows Compter

    .DESCRIPTION
    Creates a Report of the software in the Windows system's "uninstall" Registry path

    .OUTPUTS
    The report file stored in C:\Windows\Temp\InstalledSoftware.log
    
    .EXAMPLE
    <Example goes here. Repeat this attribute for more than one example>
    
    .NOTES
    Author:         
    Editors:    Arnesen
    Creation Date:  3/6/2018
    GitHub Location: ITPS-Tools/Modules/Get-InstalledSoftware.ps1
 
 #>

#----------------------[ Initializations ]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Dot Source required Function Libraries
. "$env:USERPROFILE\Documents\GitHub\OgJAkFy8\ITPS-Tools\Modules\Logging_Functions.ps1"

#----------------------[ Declarations ]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#Log File Info
$sLogPath = "$env:HOMEDRIVE\Temp\Logs"
$sLogName = 'InstalledSoftware.log'
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#---------------------[Functions]------------------------------------------------------------

Function Get-InstalledSoftware
{
  <#
      .SYNOPSIS
      "Get-InsalledSoftware" collects all the software listed in the Uninstall registry.
  #>
  Param(
    [Parameter(Mandatory,HelpMessage='Get list of installed software by installed date or abc')]
    [ValidateSet('InstallDate', 'DisplayName','DisplayVersion')] 
    [String]$SortList
  )
  Begin
  {
    Log-Write -LogPath $sLogFile -LineValue 'Finding installed software'
  }
  Process 
  {
    Try
    {
      $InstalledSoftware = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*)
      $InstalledSoftware | Sort-Object -Descending -Property $SortList |  Select-Object -Property Installdate,DisplayVersion,DisplayName
    }
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
    End
  {
    If($?)
    {
      Log-Write -LogPath $sLogFile -LineValue 'Completed Successfully.'
      Log-Write -LogPath $sLogFile -LineValue ' '
    }
  }
}


#---------- [Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

Get-InstalledSoftware -SortList 'InstallDate' | Format-Table -AutoSize

Log-Finish -LogPath $sLogFile



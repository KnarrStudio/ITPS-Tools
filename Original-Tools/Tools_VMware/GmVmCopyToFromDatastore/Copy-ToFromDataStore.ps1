#Requires -runasadministrator

# Re quires PowerCli

Function Copy-ToFromDatastore 
{
  <#
      .SYNOPSIS
      Allows the user to copy files from or to a vm datastore

      .DESCRIPTION
      This scripts does the following:
      - Ask the user for a server name.  If no name is input, then it uses the primary DataStore (hard coded)
      - It sets the working location to the C:\Temp folder
      - The script will create a PSdrive named DS: and set-location to it.
      - It displays the files on the datastore and then asks you the direction to copy and selected file.
         
      .EXAMPLE
      Copy-ToFromDatastore -dsname abc
      Copies files from c:\temp to abc:\

      .EXAMPLE
      Copy-ToFromDatastore -dsname abc -Source "$env:HOMEDRIVE\coding" -Verbose
      Copies files from c:\coding to abc:\ writes verbose 

      .EXAMPLE
      Copy-ToFromDatastore -dsname abc -LocalFolder"$env:HOMEDRIVE\coding"  -CopyToLocalSystem
      Using the "CopyToLocalSystem" switch copies files from abc:\ to c:\coding 

      .NOTES
      Script Name: Copy-ToFromDatastore.ps1
      Author Name: Erik 

         
      Versions
      1.0 New Script
      1.1 Added a confirm statement
      2.0 Major rewrite. Changed to Advanced Function

      .INPUTS
      From pipeline or parameter - Source or LocalFolder.
      From pipeline or parameter - PS-Drive name ($dsname) 

      .OUTPUTS
      Only copies files, so no Output
  #>


  [CmdletBinding(DefaultParameterSetName = 'CopyToDatastore',SupportsShouldProcess,ConfirmImpact = 'High')]
  param(
    [Parameter(Position  = 0,HelpMessage = 'VCenter Server to perform work against', Mandatory = $true)]
    [String]$VCenterIPAddress,
    [Parameter(Position = 1,mandatory,helpmessage = 'This is the custom name of the drive you can remember.  ex. Mon,Tue,Wed' )]
    [ValidateLength(1,3)]
    [Alias('RemoteName')][string]$dsname,
      
    [Parameter(Position = 2,ValueFromPipeline)]
    [Alias('Source')]
    [String]$LocalFolder = "$env:homedrive\Temp" ,
      
    [Parameter(ParameterSetName = 'CopyToDatastore')]
    [Switch]$CopyToDatastore,
      
    [Parameter(ParameterSetName = 'CopyToLocalSystem')]
    [Switch]$CopyToLocalSystem
      
  )
   
  Connect-viserver -Server $VCenterIPAddress

  #$datastore = Get-Datastore | Select-Object -ExpandProperty Name | Out-GridView -PassThru

  if(-not $dsname)
  {
    $dsname = Read-Host -Prompt ('Enter first three (3) charactors of the day. (Mon,Tue,Wed)')
  }
   
  # New-PSDrive -Location  $datastore -name $dsName -PSProvider VimDatastore -Root ''

  $RemoteLocation = $dsname + ':\'
   
  Write-Verbose -Message ('Parameter Set Name = {0}.ParameterSetName' -f $psCmdlet)
  Switch ($psCmdlet.ParameterSetName){
    

    'CopyToDatastore'
    {
      Write-Verbose -Message 'Copy Files from the Local system to the Datastore'
      
      $SourceFolder = $LocalFolder
      $DestinationFolder = $RemoteLocation
      Write-Verbose -Message ('Source Folder = {0}' -f $SourceFolder)
      Write-Verbose -Message ('Destination Folder = {0}' -f $DestinationFolder)
    }
      
    'CopyToLocalSystem'
    {
      Write-Verbose -Message 'Copy Files from the Datastore to the Local system'
      
      $SourceFolder = $RemoteLocation
      $DestinationFolder = $LocalFolder
      Write-Verbose -Message ('Source Folder = {0}' -f $SourceFolder)
      Write-Verbose -Message ('Destination Folder = {0}' -f $DestinationFolder)
    }
  }

  #$SourceFileFolder = Get-ChildItem -Path $SourceFolder | Select-Object -ExpandProperty Name | Out-GridView -PassThru
  Write-Verbose -Message ('Source File Selected {0}' -f $SourceFolder)
   
  #Copy-DatastoreItem -Item $SourceFolder+"\*" -Destination $DestinationFolder -Force -Recurse
  Write-Verbose -Message 'Copy-DatastoreItem'

  #Remove-PSDrive -Name $dsName -Confirm
  Write-Verbose -Message 'Remove-PSDrive'
}

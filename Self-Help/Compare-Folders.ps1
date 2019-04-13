#Requires -version 5.0
#quires -RunAsAdministrator

<#
    .Synopsis
    Short description
    .DESCRIPTION
    Long description
    .EXAMPLE
    Example of how to use this cmdlet
    .EXAMPLE
    Another example of how to use this cmdlet
#>


$FolderSource = "$env:USERPROFILE\Documents\GitHub\OgJAkFy8\ITPS-Tools\" 
$FolderDest = "$env:USERPROFILE\Documents\GitHub\PS-Scripts\"
#$FolderSource = '\\rsrcngmfs02\OMC-CA_Org\OMC-S\IT' 
#$FolderDest = '\\rsrcnfs08\OMC-CA_Org\OMC-S\IT'

   
function Compare-Folders 
{
  <#
      .SYNOPSIS
      Compare two folders for clean up

      .PARAMETER FolderSource
      The source folder -FolderSource.

      .PARAMETER FolderDest
      The Destination -FolderDest.

  #>


  [Cmdletbinding()]
  
  Param(
    [Parameter(Mandatory = $true,ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('Source','OldFolder')]
    [string]$FolderSource,
        
    [Parameter(Mandatory = $true)][Alias('Destination','Staging')]
    [string]$FolderDest
  )

  function Get-FolderStats
  {
    [OutputType([int])]
    Param
    (
      # Param1 help description
      [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position = 0)]
      [String]$InputItem
    )
  
    Process {
      Write-debug -Message $InputItem 
      $InputItem |
          Measure-Object -Sum -Property Length | 
          Select-Object -Property count, Sum
        }
  }
  function Get-Recursed 
  {
    [OutputType([int])]
    Param
    (
      # Param1 help description
      [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
      [Object]$FolderSelected
    )
    Process {
      Get-ChildItem -Path $FolderSelected.FullName -Recurse
    }
  }
  
  $FolderSourceSelected = Get-ChildItem -Path $FolderSource |
  Where-Object -FilterScript {
    $_.Name -in $(Get-ChildItem -Path $FolderDest).Name
  } |
  Select-Object -Property Name, FullName |
  Out-GridView -Title 'Select Folder to Compare' -OutputMode Single 
  #$FolderDestSelected = Get-ChildItem $FolderDest  | select Name,FullName | Out-GridView -Title "Compare to '$($FolderSourceSelected.Name)'" -OutputMode Single 
  
  $FolderDestSelected = Get-ChildItem -Path $FolderDest  | Where-Object -Property Name -EQ -Value $($FolderSourceSelected.Name ) #select Name,FullName | Out-GridView -Title "Compare to '$($FolderSourceSelected.Name)'" -OutputMode Single 
  Write-Debug -Message ('FolderSourceSelected  = {0}' -f $FolderSourceSelected)
  Write-Debug -Message ('FolderDestSelected = {0}' -f $FolderDestSelected)
  
  $FolderSourceRecurse = Get-Recursed -FolderSelected $FolderSourceSelected
  $FolderDest_InputObject = Get-Recursed -FolderSelected $FolderDestSelected
  Write-Debug -Message ('FolderSourceRecurse = {0}' -f $FolderSourceRecurse)
  Write-Debug -Message ('FolderDest_InputObject = {0}' -f $FolderDest_InputObject)
  
  <#
      $FolderSourceSize = Get-FolderStats -InputItem $FolderSourceRecurse
      $FolderDestSize = Get-FolderStats -InputItem $FolderDestSelected
      Write-Debug "FolderSourceSize = $FolderSourceSize"
      Write-Debug "FolderDestSize = $FolderDestSize"
  #> 
  
  Compare-Object -ReferenceObject $FolderSourceRecurse -DifferenceObject $FolderDest_InputObject #| Out-Null

  Write-Verbose -Message ("'<=' only in {0} " -f $FolderSourceSelected.FullName) 
  Write-Verbose -Message ("'=>' only in {0} " -f $FolderDestSelected.FullName) 
  #Write-Verbose -Message $FolderSourceSize
  #Write-Verbose -Message $FolderDestSize
}

Clear-Host
Compare-Folders -FolderSource $FolderSource  -FolderDest $FolderDest -Verbose



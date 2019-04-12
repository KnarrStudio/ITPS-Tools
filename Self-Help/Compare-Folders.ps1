#requires -version 3.0

#$FolderSource = "\\rsrcnfs08\OMC-CA_Org\MCAA\1606 (Info Technology)\_Staging"
   
function Compare-Folders {
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
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('Source','OldFolder')]
    [string]$FolderSource = '\\rsrcngmfs02\OMC-CA_Org\OMC-S\IT',
    #$F = 'C:\Temp'
    
    [Alias('Destination','Staging')]
    [string]$FolderDest = '\\rsrcnfs08\OMC-CA_Org\OMC-S\IT'
  )

  $FolderSourceSelected = Get-ChildItem -Path $FolderSource | Where-Object {$_.Name -in $(Get-ChildItem -Path $FolderDest).Name} | Select-Object -Property Name,FullName | Out-GridView -Title 'Select Folder to Compare' -OutputMode Single 
  #$FolderDestSelected = Get-ChildItem $FolderDest  | select Name,FullName | Out-GridView -Title "Compare to '$($FolderSourceSelected.Name)'" -OutputMode Single 
  $FolderDestSelected = Get-ChildItem -Path $FolderDest  | Where-Object Name -eq $($FolderSourceSelected.Name ) #select Name,FullName | Out-GridView -Title "Compare to '$($FolderSourceSelected.Name)'" -OutputMode Single 


  Function Get-Recursed {
    [CmdletBinding()]
    Param(
      [Alias('Source','OldFolder')]
      [string]$FolderPath
    )
    
    $FullFolder = $FolderPath #.FullName
    Get-ChildItem -Path $FullFolder -Recurse 
  }

  $FolderSourceRecurse =   Get-ChildItem -Path $FolderSourceSelected.FullName -Recurse
  $FolderDest_InputObject =  Get-ChildItem -Path $FolderDestSelected.FullName -Recurse

  $FolderSourceSize = $FolderSourceRecurse | Measure-Object -Sum -Property Length | Select-Object -Property count,Sum 
  $FolderDestSize = $FolderDest_InputObject | Measure-Object -Sum -Property Length | Select-Object -Property count,Sum


  Clear-Host
  Compare-Object -ReferenceObject $FolderSourceRecurse -DifferenceObject $FolderDest_InputObject #| Wait-Process

  Write-Verbose -Message ("'<=' only in {0} " -f $FolderSourceSelected.FullName) 
  Write-Verbose -Message ("'=>' only in {0} " -f $FolderDestSelected.FullName) 
  $FolderSourceSize
  $FolderDestSize

  #Get-ChildItem -Directory -Recurse -Depth 2 | ForEach-Object{if($_.LastAccessTime -lt $(get-date).AddDays(-720)){$_ | select Parent,BaseName,CreationTime,Attributes | Export-Csv c:\temp\software.csv}} 

  

}


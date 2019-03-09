
Function Test-ComputerConnection 
{
   <#
         .SYNOPSIS
         Describe purpose of "Test-ComputerConnection" in 1-2 sentences.

         .DESCRIPTION
         Add a more complete description of what the function does.

         .EXAMPLE
         Test-ComputerConnection
         Describe what this call does

         .NOTES
         Place additional notes here.

         .LINK
         URLs to related sites
         The first link is opened by Get-Help -Online Test-ComputerConnection

         .INPUTS
         List of input types that are accepted by this function.

         .OUTPUTS
         List of output types produced by this function.
   #>

   [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low')]
   param(
      [Parameter(
            ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('hostname')]
      [ValidateLength(4,14)]
      [string[]]$WorkstationList,
            
      [switch]$nameLog
   )
   $WorkstationSiteList = "$env:HOMEDRIVE\Temp\SiteList.csv"
   $GoodCount = 0
   $BadCount = 0
   $DateNow = Get-Date -UFormat %Y%m%d-%H%M
   $ReportFile = ("$env:HOMEDRIVE\temp\{0}-Report.txt" -f $DateNow)


   if(!(Test-Path -Path $WorkstationSiteList)){
      $ADSearchBase = 'OU=Clients-Desktop,OU=Computers,OU=SOUTH,DC=localdomain'
      get-adcomputer -filter * -SearchBase $ADSearchBase | Select-Object -ExpandProperty name | Export-Csv -Path $WorkstationSiteList -NoTypeInformation
   }

<#   if(-not $WorkstationList){
      $WorkstationList = Import-Csv -Path $WorkstationSiteList -Header Name
   }
   Else{$WorkstationSiteList = $WorkstationList}#>
   
   foreach($OneWorkstation in $WorkstationList){
      $WorkstationName = $OneWorkstation.Name
      $Ping = Test-Connection -ComputerName $WorkstationName -Count 1 -Quiet
      if($Ping -ne 'True'){
         $BadCount += 1
         $WorkstationProperties = Get-ADComputer -Identity $WorkstationName -Properties * | Select-Object -Property Name,LastLogonDate,Description
         if($BadCount -eq 1){
            $WorkstationProperties | export-csv -Path $ReportFile -NoClobber -NoTypeInformation
         }
         else{
            $WorkstationProperties | Export-Csv -Path $ReportFile -NoTypeInformation -Append
         }
      }
   }

}

Export-ModuleMember -Function Test-ComputerConnection
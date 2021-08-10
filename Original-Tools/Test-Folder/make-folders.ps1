function make-folders{

   param ($foldername,
      [Parameter(Mandatory=$true)]
      [ValidateRange(1,9)]$depth
   )
   
   Set-Location 'C:\temp\NestedFolders'
   
   $FolderPath = '.\simpsons\'
  
   for($i=1;$i -le $depth;$i++){
      Write-Debug "Top Inc $i"
      $FolderPath = '.\simpsons\'
  
      for($k=1;$k -le $depth;$k++){
   
         $j = [string]$i*$k
      
         $FolderPath += "$foldername-$j\"
         
         if ($k -eq $depth){     
         $FolderPath}
      
}}
Clear-Host
make-folders -foldername 'FolderTest' -depth 3

<#      $FolderPath | Out-File ".\simpsons\$foldername.txt" -Append
      
      $FolderPath # | Export-Csv ".\simpsons\$foldername.csv" -NoTypeInformation -Append
      
Write-Debug "Folder Path $folderpath"

$r = Get-ChildItem | select -Property FullName
foreach($t in $r){
   $g = [string]$t.FullName
   $gcount = (Select-String "\\" -InputObject $g -AllMatches).Matches.Count
      
   }



#>


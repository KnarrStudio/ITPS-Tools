$Filelist = Get-ChildItem | where name -Match '_' 
#$name1,$name2 = $filelist.name -split '_' 

$newname = ForEach($file in $filelist){
    $name1,$name2 = $file.name -split '.' 
    new-object psobject -Property @{
        FileName = $file.Name
        Building = $name2
        Room = $name1
    }
}
$newname | select Filename,Room,Building | export-csv .\test-split.csv -NoTypeInformation

$path = Resolve-Path "folders.csv"
set-location env: -passthru 
$Folders = Import-Csv .\folders.csv
 
ForEach ($Folder in $Folders) { 
    if (!(test-path -Path $Folder)){
        write-host $folder.Name -ForegroundColor Cyan
        write-host $path($Folder.Name) -ForegroundColor Yellow
        New-Item $Folder.Name -type directory 
}} 
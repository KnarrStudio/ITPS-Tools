<#
 .SYNOPSIS
   Exports files and keeps a running size log

 .DESCRIPTION
   Performs the following tasks:
       1. Moves files to new location
       2. Deletes old files at destination
       3. Builds a log file in CSV format to track backup sizes

 .NOTES
   File Name      : Export-DBBackups.ps1
   Authors        : Alex F. (https://github.com/afflom)
                  : Erik A. (https://github.com/OgJAkFy8)
   Prerequisite   : PowerShell V2 over Vista and upper.
   Copyright 2018 - Alex F. & Erik A.

 .LINK
   Script posted over:
   https://github.com/afflom/quick-scripts
#>
function Export-Backups{
    param(
        [Parameter(Mandatory=$True,Position=0)]
        $SourceFolder,

        [Parameter(Mandatory=$True,Position=1)]
        $FileType,

        [Parameter(Mandatory=$True,Position=2)]
        $DestinationFolder,

        [Parameter(Mandatory=$True,Position=3)]
        $deleteAfterDays,

        [Parameter(Mandatory=$True,Position=4)]
        $LogDestination
    )
        #Convert DeleteAfterDays to a negative
        $deleteAfterDays = "-$deleteAfterDays"

        #Get Backup Directories
        $folderList = (Get-ChildItem -Path "$SourceFolder").fullname

        #Declare obsolete backups
        $old = (Get-date).addDays("$deleteAfterDays")
    
        #Loop through the directories
        foreach($folder in $folderList){
            #Find Backup in folder
            $var = Get-ChildItem -Path $folder
            #Get Backup Name
            $name = $var.BaseName
            #Get Backup size
            $size = $var.Length
            #Get Backup time
            $date = $var.CreationTime
            #Setup .CSV column names
            $outputList = [PSCustomObject]@{
                Name = $name
                Size = $size
                Date = $date
            }
            #Add to backup log
            $outputList | Export-Csv -NoTypeInformation -Path "$LogDestination\backups.csv" -Delimiter ','  -Append
            #Export backup to share
            Move-Item -Path "$Folder\*.$FileType" -Destination "$DestinationFolder"

        }
        #Delete old backups
        Get-ChildItem -Path "$DestinationFolder" | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $old } | Remove-Item -Force
}

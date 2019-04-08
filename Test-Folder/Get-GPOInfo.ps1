# r eq uires -module GroupPolicy

if(-not (Get-Module GroupPolicy)){
    Write-Verbose "Group Policy module not installed.  Importing now..."
    Import-Module GroupPolicy
}


$Selection = Read-Host "Enter HTM or XML"

switch ($Selection){
  'HTML' {
        # Get HTML report of all GPO's
        Get-GPO -All | % {$_.GenerateReport('html') | Out-File "$env:USERPROFILE\Documents\GPOReports\$($_.DisplayName).htm"}
    }
  'HTM' {
        Get-GPOReport -All -Domain "sales.contoso.com" -Server "DC1" -ReportType HTML -Path "$env:USERPROFILE\Documents\GPOReports\GPOReport1.html"
        #Get-GPOReport -All -Domain "sales.contoso.com" -Server "DC1" -ReportType HTML -Path "C:\GPOReports\GPOReport1.html"
    }
  'XML' {
        # Get XML Report of all GPO's
        Get-GPO -All | % {$_.GenerateReport('xml') | Out-File "$env:USERPROFILE\Documents\GPOReports\$($_.DisplayName).xml"}
    }

  Default {Write-Host 'Exit'}
}






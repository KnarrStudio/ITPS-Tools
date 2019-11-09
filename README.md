# ITPS-Tools

## IT PowerShell - Tools:
The idea behind these tools are as follows:
1. Create a series of tools that can be used to help in the day to day tasks or troubleshooting.  
1. These will be made into modules so the whole tool set can be loaded "imported" at one time.  The tech would have all the tools they need for the "day"
1. Some might be a menu system.
1. Others would be only be "commands".
2. Colaborate on tools or troubleshooting.
3. Give a home to scripts and remove the bad, unused or "v1.,v2,v3,org,good" versioning from the workplace share or c:\temp
4. Better learn the value of GitHub

## Master, Branches and templates 
- ### Master Branch: 
  This should be kept as close to working tools as possible.  It should be sanitized from any possible company related information.
    
- ### Development Branch:
  Primary branch that most will work from.  This is also where testing wouuld be done.

- ### Branches:
  Used to create new tools or work on ones that are in progress.  The branches should be titled something meaningful, so that the work being done can be focused.
    
- ### Templates:
  All scripts, modules and functions need to use the template, so that others who run accross the script can find source and possible updates.
```
          <#
         .SYNOPSIS
          Quick blurb about the script 

        .DESCRIPTION
        Use this for larger scripts that need more details.  Just use the SYNOPSIS for short scripts

        .OUTPUTS
        Discribe the way you will get the output.  Screen, Console, or file and location
 
        .EXAMPLE
        <Example goes here. Repeat this attribute for more than one example>
 
        .NOTES
        Author:         Your Name - Take credit if it is yours, give credit if it was isn't
        Editors:    Your Namme - Take the credit
        Last Edit Date:  3/6/2018
        GitHub Location: ITPS-Tools/Modules/Get-InstalledSoftware.ps1
        #>
```
    
    

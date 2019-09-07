Function Log-Start{
  <#
      .SYNOPSIS
      Creates log file

      .DESCRIPTION
      Creates log file with path and name that is passed. Checks if log file exists, and if it does deletes it and creates a new one.
      Once created, writes initial logging data

      .PARAMETER LogPath
      Mandatory. Path of where log is to be created. Example: C:\Windows\Temp

      .PARAMETER LogName
      Mandatory. Name of log file to be created. Example: Test_Script.log
      
      .PARAMETER ScriptVersion
      Mandatory. Version of the running script which will be written in the log. Example: 1.5

      .INPUTS
      Parameters above

      .OUTPUTS
      Log file created

      .NOTES
      Version:        1.0
      Author:         Luca Sturlese
      Creation Date:  10/05/12
      Purpose/Change: Initial function development

      Version:        1.1
      Author:         Luca Sturlese
      Creation Date:  19/05/12
      Purpose/Change: Added debug mode support

      .EXAMPLE
      Log-Start -LogPath "C:\Windows\Temp" -LogName "Test_Script.log" -ScriptVersion "1.5"
  #>
    
  
  Param ([Parameter(Mandatory=$true,HelpMessage='Path of where log is to be created. Example: C:\Windows\Temp')]
    [string]$LogPath, 
    [Parameter(Mandatory=$true,HelpMessage='Name of log file to be created. Example: Test_Script.log')]
    [string]$LogName, 
    [Parameter(Mandatory=$true,HelpMessage='Version of the running script which will be written in the log. Example: 1.5')]
  [string]$ScriptVersion)
  
  Process{
    $RunningProcess = 'Running script version [{0}].'
    $StartProcessing = "Started processing at [$([DateTime]::Now)]."
    $StarLineBox = '***************************************************************************************************'
    $sFullPath = $LogPath + '\' + $LogName
    
    #Check if file exists and delete if it does
    If((Test-Path -Path $sFullPath)){
      Remove-Item -Path $sFullPath -Force
    }
    
    #Create file and start logging
    New-Item -Path $LogPath -Value $LogName -ItemType File
    
    Add-Content -Path $sFullPath -Value $StarLineBox
    Add-Content -Path $sFullPath -Value $StartProcessing
    Add-Content -Path $sFullPath -Value $StarLineBox
    Add-Content -Path $sFullPath -Value ''
    Add-Content -Path $sFullPath -Value ($RunningProcess -f $ScriptVersion)
    Add-Content -Path $sFullPath -Value ''
    Add-Content -Path $sFullPath -Value $StarLineBox
    Add-Content -Path $sFullPath -Value ''
  
    #Write to screen for debug mode
    Write-Debug -Message $StarLineBox
    Write-Debug -Message $StartProcessing
    Write-Debug -Message $StarLineBox
    Write-Debug -Message ''
    Write-Debug -Message ($RunningProcess -f $ScriptVersion)
    Write-Debug -Message ''
    Write-Debug -Message $StarLineBox
    Write-Debug -Message ''
  }
}

Function Log-Write{
  <#
      .SYNOPSIS
      Writes to a log file
      .DESCRIPTION
      Appends a new line to the end of the specified log file
      .PARAMETER LogPath
      Mandatory. Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log
      .PARAMETER LineValue
      Mandatory. The string that you want to write to the log
      .NOTES
      Version:        1.0
      Author:         Luca Sturlese
      Creation Date:  10/05/12
      Purpose/Change: Initial function development
      Version:        1.1
      Author:         Luca Sturlese
      Creation Date:  19/05/12
      Purpose/Change: Added debug mode support
      .EXAMPLE
      Log-Write -LogPath "C:\Windows\Temp\Test_Script.log" -LineValue "This is a new line which I am appending to the end of the log file."
  #>
  Param (
    [Parameter(Mandatory=$true,HelpMessage='Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log')]
    [string]$LogPath, 
    [Parameter(Mandatory=$true,HelpMessage='The string that you want to write to the log')]
    [string]$LineValue
  )
  Process{
    Add-Content -Path $LogPath -Value $LineValue
    #Write to screen for debug mode
    Write-Debug -Message $LineValue
  }
}

Function Log-Error
{
  <#
      .SYNOPSIS
      Writes an error to a log file

      .DESCRIPTION
      Writes the passed error to a new line at the end of the specified log file
  
      .PARAMETER LogPath
      Mandatory. Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log
  
      .PARAMETER ErrorDesc
      Mandatory. The description of the error you want to pass (use $_.Exception)
  
      .PARAMETER ExitGracefully
      Mandatory. Boolean. If set to True, runs Log-Finish and then exits script

      .INPUTS
      Parameters above

      .OUTPUTS
      None

      .NOTES
      Version:        1.0
      Author:         Luca Sturlese
      Creation Date:  10/05/12
      Purpose/Change: Initial function development
    
      Version:        1.1
      Author:         Luca Sturlese
      Creation Date:  19/05/12
      Purpose/Change: Added debug mode support. Added -ExitGracefully parameter functionality

      .EXAMPLE
      Log-Error -LogPath "C:\Windows\Temp\Test_Script.log" -ErrorDesc $_.Exception -ExitGracefully $True
  #>
  
  Param (
    [Parameter(Mandatory=$true,HelpMessage='Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log')]
    [string]$LogPath, 
    [Parameter(Mandatory=$true,HelpMessage="The description of the error you want to pass (use $_.Exception)")]
    [string]$ErrorDesc, 
    [Parameter(Mandatory=$true,HelpMessage='If set to True, runs Log-Finish and then exits script')]
    [bool]$ExitGracefully
  )
  
  Process
  {
    $ErrorMessage = 'Error: An error has occurred [{0}].'
    Add-Content -Path $LogPath -Value ($ErrorMessage -f $ErrorDesc)
    #Write to screen for debug mode
    Write-Debug -Message ($ErrorMessage -f $ErrorDesc)
    #If $ExitGracefully = True then run Log-Finish and exit script
    If ($ExitGracefully -eq $True){
      Log-Finish -LogPath $LogPath
      Break
    }
  }
}

Function Log-Finish
{
  <#
      .SYNOPSIS
      Write closing logging data & exit

      .DESCRIPTION
      Writes finishing logging data to specified log and then exits the calling script
  
      .PARAMETER LogPath
      Mandatory. Full path of the log file you want to write finishing data to. Example: C:\Windows\Temp\Test_Script.log

      .PARAMETER NoExit
      Optional. If this is set to True, then the function will not exit the calling script, so that further execution can occur
  
      .INPUTS
      Parameters above

      .OUTPUTS
      None

      .NOTES
      Version:        1.0
      Author:         Luca Sturlese
      Creation Date:  10/05/12
      Purpose/Change: Initial function development
    
      Version:        1.1
      Author:         Luca Sturlese
      Creation Date:  19/05/12
      Purpose/Change: Added debug mode support
  
      Version:        1.2
      Author:         Luca Sturlese
      Creation Date:  01/08/12
      Purpose/Change: Added option to not exit calling script if required (via optional parameter)

      .EXAMPLE
      Log-Finish -LogPath "C:\Windows\Temp\Test_Script.log"

      .EXAMPLE
      Log-Finish -LogPath "C:\Windows\Temp\Test_Script.log" -NoExit $True
  #>
  
  
  Param (
    [Parameter(Mandatory=$true,HelpMessage='Full path of the log file you want to write finishing data to')]
    [string]$LogPath, 
    [Parameter(Mandatory=$true,HelpMessage='If this is set to True, then the function will not exit the calling script, so that further execution can occur')]
    [string]$NoExit
  )
  
  Process
  {
    $FinishedProcessing = "Finished processing at [$([DateTime]::Now)]."
    $StarLineBox = '***************************************************************************************************'
    Add-Content -Path $LogPath -Value ''
    Add-Content -Path $LogPath -Value $StarLineBox
    Add-Content -Path $LogPath -Value $FinishedProcessing
    Add-Content -Path $LogPath -Value $StarLineBox
  
    #Write to screen for debug mode
    Write-Debug -Message ''
    Write-Debug -Message $StarLineBox
    Write-Debug -Message $FinishedProcessing
    Write-Debug -Message $StarLineBox
  
    #Exit calling script if NoExit has not been specified or is set to False
    If(!($NoExit) -or ($NoExit -eq $False)){
      Exit
    }    
  }
}

Function Log-Email
{
  <#
      .SYNOPSIS
      Emails log file to list of recipients

      .DESCRIPTION
      Emails the contents of the specified log file to a list of recipients
  
      .PARAMETER LogPath
      Mandatory. Full path of the log file you want to email. Example: C:\Windows\Temp\Test_Script.log
  
      .PARAMETER EmailFrom
      Mandatory. The email addresses of who you want to send the email from. Example: "admin@9to5IT.com"

      .PARAMETER EmailTo
      Mandatory. The email addresses of where to send the email to. Seperate multiple emails by ",". Example: "admin@9to5IT.com, test@test.com"
  
      .PARAMETER EmailSubject
      Mandatory. The subject of the email you want to send. Example: "Cool Script - [" + (Get-Date).ToShortDateString() + "]"

      .INPUTS
      Parameters above

      .OUTPUTS
      Email sent to the list of addresses specified

      .NOTES
      Version:        1.0
      Author:         Luca Sturlese
      Creation Date:  05.10.12
      Purpose/Change: Initial function development

      .EXAMPLE
      Log-Email -LogPath "C:\Windows\Temp\Test_Script.log" -EmailFrom "admin@9to5IT.com" -EmailTo "admin@9to5IT.com, test@test.com" -EmailSubject "Cool Script - [" + (Get-Date).ToShortDateString() + "]"
  #>
  
  
  Param (
    [Parameter(Mandatory=$true)]
    [string]$LogPath, 
    [Parameter(Mandatory=$true)]
    [string]$EmailFrom, 
    [Parameter(Mandatory)]
    [string]$EmailTo, 
    [Parameter(Mandatory)]
    [string]$EmailSubject
  )
  
  Process
  {
    Try
    {
      $sBody = (Get-Content -Path $LogPath | out-string)
      
      #Create SMTP object and send email
      $sSmtpServer = 'smtp.yourserver'
      $oSmtp = new-object -TypeName Net.Mail.SmtpClient -ArgumentList ($sSmtpServer)
      $oSmtp.Send($EmailFrom, $EmailTo, $EmailSubject, $sBody)
      Exit 0
    }
    
    Catch{
      Exit 1
    } 
  }
}
Function Set-VmStigSettings 
{
  <#
      .SYNOPSIS
      This script sets all STIG settings for a Virtual machine. 

      .DESCRIPTION
      This script sets all STIG settings for a Virtual machine. With the exception of removing VM devices (EG Floppy Drive) which reuqire the VM to be powered off.  It utilizes the VmStigSettings.csv to set them. It has the capability to run against one VM or all VMs located on a host. When conducting all VMs the script will do one STIG against all VMs and then proceeds onto the next.It will also produce an output file when accomplishing all tasks.

      .PARAMETER VmServer
      This parameter will accept one to 50 virtual machines to be acted on.

      .PARAMETER ReportOutput
      Describe parameter -ReportOutput.

      .PARAMETER LogEvents
      Describe parameter -LogEvents.

      .EXAMPLE
      Set-VmStigSettings -VmServer Value -ReportOutput -LogEvents
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Set-VmStigSettings

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'High')]
  param(
    [Parameter(Mandatory,HelpMessage = 'Enter or Pass a Virtual Machine Name to Stig', ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('vm')]
    [ValidateLength(4,14)]
    [ValidateCount(1,50)]
    [string[]]$VmServerName,
    [Switch]$ReportOutput,
    [switch]$LogEvents
  )

  # Set input & output files
  $VmStigSettings = Import-Csv -Path '.\VmStigSettings.csv' -Header Name, Value
  $VmStigSettingOutput = '.\VmStigSettingOutput.csv'


  BEGIN{
    if ($LogEvents)
    {
      Write-Verbose -Message 'Finding error log file'
      $i = 0
      Do 
      {
        $logfile = ('.\VmStigErrorLog({0}).txt' -f $i)
        $i++
      }while (Test-Path -Path $logfile)
    } else 
    {
      Write-Verbose -Message 'Name log off'
    }
    Write-Debug -Message 'Finished setting error log'
  }
   
  PROCESS -Name { 
    Write-Debug -Message 'Starting Process'

    foreach ($VmServer in $VmServerName)
    {
      if($PSCmdlet.ShouldProcess($VmServer))
      {
        Write-Verbose -Message ('Connecting to {0}' -f $VmServer)
        if($LogEvents)
        {
          $VmServer | Out-File -FilePath $logfile -Append
        }
        try 
        {
          $continue = $true
          # APPLY TO ALL VM
          get-vm -name $VmServer | Where-Object -Property PowerState -EQ -Value 'poweredon'
        } 
        catch 
        {
          $continue = $false
          $VmServer | Out-File -FilePath '.\error.txt'
          #$myErr | Out-File '.\errormessages.txt'
        }
        if($continue) 
        {
          # Apply STIG settings to a VM 
          Write-Verbose -Message ('Starting to STIG {0}' -f $VmServer)
          foreach ($line in $VmStigSettings) 
          {
            New-AdvancedSetting -Entity $VmServer -Name ($line.Name) -value($line.value) -Force -Confirm:$false | Select-Object -Property Entity, Name, Value
          }
        }
      }
    }
  }
}
END{

}

Set-VmStigSettings -VmServerName Foo, bar



# https://www.vmware.com/files/xls/vSphere_6_0_Hardening_Guide_GA_15_Jun_2015.xls


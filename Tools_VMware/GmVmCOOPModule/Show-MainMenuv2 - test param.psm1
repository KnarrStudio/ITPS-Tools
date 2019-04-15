function script:Create-Menu 
{
  <#
      .SYNOPSIS
      Describe purpose of "Create-Menu" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER Title
      Describe parameter -Title.

      .PARAMETER MenuItems
      Describe parameter -MenuItems.

      .PARAMETER TitleColor
      Describe parameter -TitleColor.

      .PARAMETER LineColor
      Describe parameter -LineColor.

      .PARAMETER MenuItemColor
      Describe parameter -MenuItemColor.

      .EXAMPLE
      Create-Menu -Title Value -MenuItems Value -TitleColor Value -LineColor Value -MenuItemColor Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Create-Menu

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>
  param([Parameter(Mandatory,HelpMessage='The tile of the menu.')]
    [String]$Title, 
    [Parameter(Mandatory,HelpMessage='Add one or more items you want in your menu.')][String[]]$MenuItems, 
    [Parameter(Mandatory,HelpMessage='Title text color')][String]$TitleColor, 
    [Parameter(Mandatory,HelpMessage='Outline box color')][String]$LineColor, 
    [Parameter(Mandatory,HelpMessage='Menu items color')][String]$MenuItemColor
  )
  

  Clear-Host
  [string]$Title = "$Title"
  $TitleCount = $Title.Length
  $LongestMenuItem = ($MenuItems | Measure-Object -Maximum -Property Length).Maximum
  if  ($TitleCount -lt $LongestMenuItem)
  {
    $reference = $LongestMenuItem
  }
  else

  {
    $reference = $TitleCount
  }
  $reference = $reference + 40
   
   
  $Line = '═'*$reference
  $TotalLineCount = $Line.Length
  $RemaniningCountForTitleLine = $reference - $TitleCount
  $RemaniningCountForTitleLineForEach = $RemaniningCountForTitleLine / 2
  $RemaniningCountForTitleLineForEach = [math]::Round($RemaniningCountForTitleLineForEach)
  $LineForTitleLine = "`0"*$RemaniningCountForTitleLineForEach
  $Tab = "`t"
  Write-Host '╔' -NoNewline -f $LineColor
  Write-Host $Line -NoNewline -f $LineColor
  Write-Host '╗' -f $LineColor
  if($RemaniningCountForTitleLine % 2 -eq 1)
  {
    $RemaniningCountForTitleLineForEach = $RemaniningCountForTitleLineForEach +1
    $LineForTitleLine2 = "`0"*$RemaniningCountForTitleLineForEach
    Write-Host '║' -f $LineColor -nonewline
    Write-Host $LineForTitleLine -nonewline -f $LineColor
    Write-Host $Title -f $TitleColor -nonewline
    Write-Host $LineForTitleLine2 -f $LineColor -nonewline
    Write-Host '║' -f $LineColor
  }
  else
  {
    Write-Host '║' -nonewline -f $LineColor
    Write-Host $LineForTitleLine -nonewline -f $LineColor
    Write-Host $Title -f $TitleColor -nonewline
    Write-Host $LineForTitleLine -nonewline -f $LineColor
    Write-Host '║' -f $LineColor
  }
  Write-Host '╠' -NoNewline -f $LineColor
  Write-Host $Line -NoNewline -f $LineColor
  Write-Host '╣' -f $LineColor
  $i = 1
  foreach($menuItem in $MenuItems)
  {
    $number = $i++
    $RemainingCountForItemLine = $TotalLineCount - $menuItem.Length -5
    $LineForItems = "`0"*$RemainingCountForItemLine
    Write-Host '║' -nonewline -f $LineColor 
    Write-Host $Tab -nonewline
    Write-Host $number"." -nonewline -f $MenuItemColor
    Write-Host $menuItem -nonewline -f $MenuItemColor
    Write-Host $LineForItems -nonewline -f $LineColor
    Write-Host '║' -f $LineColor
  }
  Write-Host '╚' -NoNewline -f $LineColor
  Write-Host $Line -NoNewline -f $LineColor
  Write-Host '╝' -f $LineColor
}


#Create-Menu -Title "THIS IS TITLE" -MenuItems "Exchange Server","Active Directory","Sytem Center Configuration Manager","Lync Server","Microsoft Azure" -TitleColor Red -LineColor Cyan -MenuItemColor Yellow
Create-Menu -Title 'Welcome to the Maintenance Center' -MenuItems 'Set Safety On/Off', 'EXIT', "Move all VM's to one host", 'Reboot Empty host', "Balance all VM's per 'tag'", 'Move and Reboot and Balance VM environment', 'VM/Host information', 'Exit' -TitleColor Red -LineColor Cyan -MenuItemColor Yellow


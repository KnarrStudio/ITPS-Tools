function Show-AsciiMenu
{
  <#
      .SYNOPSIS
      Describe purpose of "Show-AsciiMenu" in 1-2 sentences.

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
      Show-AsciiMenu -Title Value -MenuItems Value -TitleColor Value -LineColor Value -MenuItemColor Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Show-AsciiMenu

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  [CmdletBinding()]
  param
  (
    [string]$Title = 'Title',

    [String[]]$MenuItems = 'None',

    [string]$TitleColor = 'Red',

    [string]$LineColor = 'Yellow',

    [string]$MenuItemColor = 'Cyan'
  )
  Begin{
    # Set Variables
    $i = 1
    $Tab = "`t"
    $VertLine = '║'
  
    function Write-HorizontalLine
    {
      param
      (
        [Parameter(Position = 0)]
        [string]
        $DrawLine = 'Top'
      )
      Switch ($DrawLine) {
        Top 
        {
          Write-Host ('╔{0}╗' -f $HorizontalLine) -ForegroundColor $LineColor
        }
        Middle 
        {
          Write-Host ('╠{0}╣' -f $HorizontalLine) -ForegroundColor $LineColor
        }
        Bottom 
        {
          Write-Host ('╚{0}╝' -f $HorizontalLine) -ForegroundColor $LineColor
        }
      }
    }
    function Get-Padding
    {
      param
      (
        [Parameter(Mandatory, Position = 0)]
        [int]$Multiplier 
      )
      "`0"*$Multiplier
    }
    function Write-MenuTitle
    {
      Write-Host ('{0}{1}' -f $VertLine, $TextPadding) -NoNewline -ForegroundColor $LineColor
      Write-Host ($Title) -NoNewline -ForegroundColor $TitleColor
      if($TotalTitlePadding % 2 -eq 1)
      {
        $TextPadding = Get-Padding -Multiplier ($TitlePaddingCount + 1)
      }
      Write-Host ('{0}{1}' -f $TextPadding, $VertLine) -ForegroundColor $LineColor
    }
    function Write-MenuItems
    {
      foreach($menuItem in $MenuItems)
      {
        $number = $i++
        $ItemPaddingCount = $TotalLineWidth - $menuItem.Length - 6 #This number is needed to offset the Tab, space and 'dot'
        $ItemPadding = Get-Padding -Multiplier $ItemPaddingCount
        Write-Host $VertLine  -NoNewline -ForegroundColor $LineColor
        Write-Host ('{0}{1}. {2}{3}' -f $Tab, $number, $menuItem, $ItemPadding) -NoNewline -ForegroundColor $LineColor
        Write-Host $VertLine -ForegroundColor $LineColor
      }
    }
  }

  Process
  {
    $TitleCount = $Title.Length
    $LongestMenuItemCount = ($MenuItems | Measure-Object -Maximum -Property Length).Maximum
    Write-Debug -Message ('LongestMenuItemCount = {0}' -f $LongestMenuItemCount)

    if  ($TitleCount -gt $LongestMenuItemCount)
    {
      $ItemWidthCount = $TitleCount
    }
    else
    {
      $ItemWidthCount = $LongestMenuItemCount
    }

    if($ItemWidthCount % 2 -eq 1)
    {
      $ItemWidth = $ItemWidthCount + 1
    }
    else
    {
      $ItemWidth = $ItemWidthCount
    }
    Write-Debug -Message ('Item Width = {0}' -f $ItemWidth)
   
    $TotalLineWidth = $ItemWidth + 10
    Write-Debug -Message ('Total Line Width = {0}' -f $TotalLineWidth)
  
    $TotalTitlePadding = $TotalLineWidth - $TitleCount
    Write-Debug -Message ('Total Title Padding  = {0}' -f $TotalTitlePadding)
  
    $TitlePaddingCount = [math]::Floor($TotalTitlePadding / 2)
    Write-Debug -Message ('Title Padding Count = {0}' -f $TitlePaddingCount)

    $HorizontalLine = '═'*$TotalLineWidth
    $TextPadding = Get-Padding -Multiplier $TitlePaddingCount
    Write-Debug -Message ('Text Padding Count = {0}' -f $TextPadding.Length)


    Write-HorizontalLine -DrawLine Top
    Write-MenuTitle
    Write-HorizontalLine -DrawLine Middle
    Write-MenuItems
    Write-HorizontalLine -DrawLine Bottom
  }

  End
  {}
}

#Show-AsciiMenu -Title 'THIS IS THE TITLE' -MenuItems 'Exchange Server', 'Active Directory', 'Sytem Center Configuration Manager', 'Lync Server' -TitleColor Red  -MenuItemColor green
#Show-AsciiMenu -Title 'THIS IS THE TITLE' -MenuItems 'Exchange Server', 'Active Directory', 'Sytem Center Configuration Manager' #-Debug


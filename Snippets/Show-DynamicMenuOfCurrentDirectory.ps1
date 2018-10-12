Function Show-DynamicMenu
{
  <#
      .SYNOPSIS
      Creates a menu of folders or files

      .DESCRIPTION
      Looks at the folder shows a list of numbered options based on the items in the folder.  
      By default it shows folders, but you can pass a "a" and get a list of files

      .EXAMPLE
      Show-DynamicMenu
      Shows Menu base on the Directories in the current locations

      .NOTES
      Handly way to provide a selection if you want to have a menu that needs to be dynamic

      .INPUTS
      A - To get a menu of files

      .OUTPUTS
      Passes or prints the selection of the menu as a name
  #>
  param
  (
    [Parameter(Mandatory=$false)]
    [string]$ChildItemMode = 'D'
  )
  
  
  function Optimize-List
  {
    param
    (
      [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Data to filter')]
      $InputObject
    )
    process
    {
      if ($InputObject.mode -match $ChildItemMode)
      {
        $InputObject
      }
    }
  }
  $DirectoryItems = Get-ChildItem | Optimize-List
  $menu = @{}
  $folderCount = $DirectoryItems.Count-1
  for($i = 0;$i -lt $DirectoryItems.count;$i++)
  {
    if($i -eq 0)
    {
      Write-Host ('{0}. {1}' -f $i, 'Exit')
      $i++
    }
    Write-Host ('{0}. {1}' -f $i, $DirectoryItems[$i].name)
    $menu.Add($i,($DirectoryItems[$i].name))
  }
  $ans = 99
  do{[int]$ans = Read-Host -Prompt 'Select number'
    if($ans -ge $folderCount )
    {
      Write-Host ('Select a number {0} or below' -f $folderCount)
    }
  } while($ans -notin 0..$folderCount)
  $selection = $menu.Item($ans)
  
  # Visual output for Testing
  Write-host 'You selected: '$selection -ForegroundColor Magenta
}
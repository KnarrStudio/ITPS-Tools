function Show-GuiMenu
{
  <#
      .SYNOPSIS
      Describe purpose of "Show-GuiMenu" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      Show-GuiMenu
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Show-GuiMenu

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>

  param
  (
    [Parameter(Mandatory = $true,HelpMessage = 'Add a single or multiple functions comma separated')]
    [string[]]$computerNames,
    [string]$ButtonText = 'Start Process'
  )
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing

  $Form1 = New-Object -TypeName System.Windows.Forms.Form
  $Form1.ClientSize = New-Object -TypeName System.Drawing.Size -ArgumentList (407, 390)
  $Form1.topmost = $true

  $comboBox1 = New-Object -TypeName System.Windows.Forms.ComboBox
  $comboBox1.Location = New-Object -TypeName System.Drawing.Point -ArgumentList (25, 55)
  $comboBox1.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (350, 310)
  foreach($computer in $computerNames)
  {
    $comboBox1.Items.add($computer)
  }
  $Form1.Controls.Add($comboBox1)

  $Button = New-Object -TypeName System.Windows.Forms.Button
  $Button.Location = New-Object -TypeName System.Drawing.Point -ArgumentList (25, 20)
  $Button.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (98, 23)
  $Button.Text = $ButtonText
  $Button.add_Click({
      $label.Text = $comboBox1.SelectedItem.ToString()
  })
  $Form1.Controls.Add($Button)

  $label = New-Object -TypeName System.Windows.Forms.Label
  $label.Location = New-Object -TypeName System.Drawing.Point -ArgumentList (70, 90)
  $label.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (98, 23)
  $label.Text = ''
  $Form1.Controls.Add($label)

  $null = $Form1.showdialog()
}

#Show-GuiMenu -computerNames test1, test2
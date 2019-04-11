# This script is only to demonstrate calling modules and scripts from another

$name = '_________ Menu System _________'
$menu = Get-Content -Path .\Menu.txt

# Imports the menu module
import-module -Name .\show-mainmenu.psm1


# Call the function in the module using the variable $menu, but could be "item1",'item2','item3' obviously, the latter does not scale well 
# The next can only be done becuse create-menu is a function in the show-mainmenu module
Create-Menu -Title 'Welcome to the Maintenance Center' -MenuItems $menu -TitleColor Red -LineColor Cyan -MenuItemColor Yellow

# Demonstrates passing a switch to from one script to another. 
# Using the split-path method, you have to have both scripts in the same folder.  
# The $MyInvocation finds the path that the script is in and uses it 
& ((Split-Path -Path $MyInvocation.InvocationName) + '\PrintName.ps1') -printName $name

& ((Split-Path -Path $MyInvocation.InvocationName) + '\Show-DynamicMenuOfCurrentDirectory.ps1')

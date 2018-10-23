
$name = "_________ Menu System _________"
$menu = Get-Content .\Menu.txt

import-module .\show-mainmenu.psm1

#& ((Split-Path $MyInvocation.InvocationName) + "\Show-MainMenu.ps1")
#Create-Menu -Title 'Welcome to the Maintenance Center' -MenuItems 'Set Safety On/Off','EXIT',"Move all VM's to one host",'Reboot Empty host',"Balance all VM's per 'tag'",'Move and Reboot and Balance VM environment','VM/Host information','Exit' -TitleColor Red -LineColor Cyan -MenuItemColor Yellow
Create-Menu -Title 'Welcome to the Maintenance Center' -MenuItems $menu -TitleColor Red -LineColor Cyan -MenuItemColor Yellow

#& ((Split-Path $MyInvocation.InvocationName) + "\PrintName2.ps1")
& ((Split-Path $MyInvocation.InvocationName) + "\PrintName.ps1") -printName $name

& ((Split-Path $MyInvocation.InvocationName) + "\Show-DynamicMenuOfCurrentDirectory.ps1")

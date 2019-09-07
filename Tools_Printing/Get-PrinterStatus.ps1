  # Needs to be integrated into the "Printer Ping!"                                                                                                                                                             
                                                                                                                                                                  
                                                                                                                                             
                                                                                                                 
$t = ($r.portname | ForEach-Object{Get-PrinterPort $_ | select -Property PrinterHostAddress})                                                                                                             
ForEach($pport in $t){if ($pport.PrinterHostAddress -match '192.'){$pport.PrinterHostAddress}}                                                                                                            

                                                                                                 
  28 ForEach($pport in $t){if ($pport.PrinterHostAddress -match '192.'){Test-Connection $pport.PrinterHostAddress}}                                                                                            
  30 Test-Connection 192.168.1.3                                                                                                                                                                               
  31 Add-PrinterPort -Name TestIP -PrinterHostAddress 192.168.1.3                                                                                                                                              

                                                                                                                                                                   
                                                                                                           
$r.portname | ForEach-Object{Get-PrinterPort $_ | select -Property PrinterHostAddress}                                                                                                                    
ForEach($pport in $t){if ($pport.PrinterHostAddress -match '192.'){$pport.PrinterHostAddress}}                                                                                                            
$t = (Get-PrinterPort $_ | select -Property PrinterHostAddress)                                                                                                                                           
$t = (Get-PrinterPort | select -Property PrinterHostAddress)                                                                                                                                              
$t                                                                                                                                                                                                        
  
$r = get-printer | select -Property *
$t = ($r.portname | ForEach-Object{Get-PrinterPort $_ | select -Property PrinterHostAddress})   
ForEach($pport in $t){if ($pport.PrinterHostAddress -match '192.'){Test-Connection $pport.PrinterHostAddress -ErrorAction SilentlyContinue -Count 1}}
     
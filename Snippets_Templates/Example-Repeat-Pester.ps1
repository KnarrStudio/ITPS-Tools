$services = Get-Service

foreach ($service in $services) 
{
  Write-Verbose -Message ('{0}' -f $service.name)
}

########

Get-Service | Select-Object -ExpandProperty Name

for([int]$i = 0; $i -lt 10; $i++)
{
  Write-Output -InputObject ('i = {0}' -f $i)
}


0..9 | ForEach-Object -Process {
  Write-Output -InputObject ('i = {0} ' -f $_)
}

switch -file ('fourteen') 
{
  1 
  {
    'It is one.'
    Break
  }
  2 
  {
    'It is two.'
    Break
  }
  3 
  {
    'It is three.'
    Break
  }
  4 
  {
    'It is four.'
    Break
  }
  3 
  {
    'Three again.'
    Break
  }
  'fo*' 
  {
    "That's too many."
  }
}

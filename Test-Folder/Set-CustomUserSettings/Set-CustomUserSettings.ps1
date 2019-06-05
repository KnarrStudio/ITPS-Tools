
Configuration SetCustomUserSettings {
  Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
  
  Node localhost {

    Registry CustomUserSettings {
      Ensure = 'Present'
      Key = 'HKLM:\SOFTWARE\Microsoft\Office\15.0\User Settings\MyCustomUserSettings'
      ValueName = 'Count'
      ValueData = '1'
    ValueType = 'Dword' }


    Registry BootedRTM {
      Ensure = 'Present'
      Key = 'HKLM:\SOFTWARE\Microsoft\Office\15.0\User Settings\MyCustomUserSettings\Create\Software\Microsoft\Office\15.0\FirstRun'
      ValueName = 'BootedRTM'
      ValueData = '1'
    ValueType = 'Dword' }

    Registry disablemovie {
      Ensure = 'Present'
      Key = 'HKLM:\SOFTWARE\Microsoft\Office\15.0\User Settings\MyCustomUserSettings\Create\Software\Microsoft\Office\15.0\FirstRun'
      ValueName = 'disablemovie'
      ValueData = '1'
    ValueType = 'Dword' } 

    Registry shownfirstrunoptin {
      Ensure = 'Present'
      Key = 'HKLM:\SOFTWARE\Microsoft\Office\15.0\User Settings\MyCustomUserSettings\Create\Software\Microsoft\Office\15.0\Common\General'
      ValueName = 'shownfirstrunoptin'
      ValueData = '1'
    ValueType = 'Dword' }
        
    Registry ShownFileFmtPrompt {
      Ensure = 'Present'
      Key = 'HKLM:\SOFTWARE\Microsoft\Office\15.0\User Settings\MyCustomUserSettings\Create\Software\Microsoft\Office\15.0\Common\General'
      ValueName = 'ShownFileFmtPrompt'
      ValueData = '1'
    ValueType = 'Dword' }

    Registry PTWOptIn{
      Ensure = 'Present'
      Key = 'HKLM:\SOFTWARE\Microsoft\Office\15.0\User Settings\MyCustomUserSettings\Create\Software\Microsoft\Office\15.0\Common\PTWatson'
      ValueName = 'PTWOptIn'
      ValueData = '1'
    ValueType = 'Dword' }

    Registry qmenable{
      Ensure = 'Present'
      Key = 'HKLM:\SOFTWARE\Microsoft\Office\15.0\User Settings\MyCustomUserSettings\Create\Software\Microsoft\Office\15.0\Common'
      ValueName = 'qmenable'
      ValueData = '1'
    ValueType = 'Dword' }
  }
}


SetCustomUserSettings  -output C:\temp\clientConfig\SetCustomUserSettings 

Start-DscConfiguration -Path C:\temp\clientConfig\SetCustomUserSettings  -Wait -Force -Verbose

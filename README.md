# install_app_script
Powershell script for install software

* You need to install PSEXEC on the purpose PC
* After you can start the installation script

Commands inserts in the Powershell command line
1. Copy on the purpose PC the installation script
```
psexec -u useradmindomainname \\PurposePC "NetworkFolderpathWithNewSoft" LocalPath /S
```
2. Allow local PowerShell scripts to be run
```
psexec \\PurposePC powershell "Set-ExecutionPolicy Unrestricted -Force"
```
3. Start the installation script
```
psexec -u useradmindomainname \\PurposePC powershell "LocalPath\install_app_script.ps1"
```

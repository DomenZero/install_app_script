<#
.VERSION 0.0.1
.AUTHORS Maksim Merkulov <merkulovmx@gmail.com>
.COPYRIGHT
.TAGS
.LICENSEURI
.PROJECTURI
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
v 0.0.1:
- Compare the old version of the software with the new version
- Copy new Zip with the software
- Unzip copied file 
- Uninstall the old version of the software
- Install a new version from the local directory in the silent mode
#>
<#
.DESCRIPTION
 Install MSI software new and uninstall old
#>

$logpath = "C:\log\Powershell\InstallationScripts\logs"

Function WriteLog($logppath, $str) {
    ((Get-Date -UFormat "%Y.%m.%d %T") + " " + $str) >> $logpath
}

# Return full path to log file
Function ErrDirLog {
    $logpath = $env:LOCALAPPDATA + "\logfile.log"
    If (-not (Test-Path -path $logpath)) {
        # create file if empty
        $logpath = New-Item -Path $logpath -ItemType "file"
    }
    Return $logpath
}
$logpath = ErrDirLog

Add-Type -Assembly "System.IO.Compression.FileSystem" ;

function UnzipSoft
{
    param([string]$zipfile, [string]$outfolder)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outfolder)
}

function CheckSoft
{
    $props='Name','IdentifyingNumber', 'Version'
    $appID=Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "SoftwareName" } | Select-Object $props | Sort-Object Name
    Return $appID
}

#Description of software package

$new_version_folder_soft="Software"
$new_version_tag="0.0.1"

$destination="C:\Temp"
$zip_destination="C:\Temp\"+$new_version_folder+".zip"
$unzip_destination="C:\Temp\"+$new_version_folder  
$source_destination="\\local_network_path\" # location of the source files
$software_installer="software.msi$"

If(!(Test-Path $destination))
{
    New-Item -ItemType Directory -Force -Path $destination
}

If(!(Test-Path $zip_destination))
{
    $ArchiveFile=$source_destination+$new_version_folder_soft+".zip"
    Copy-item -Force -Recurse -Verbose $ArchiveFile -Destination $destination 
}
#
If(!(Test-Path $unzip_destination))
{
    UnzipSoft $zip_destination $unzip_destination
}
$new_soft_installer_folder="C:\Temp\"+$new_version_folder_soft+"\"


$InstallMSI = (Get-ChildItem -Path $new_soft_installer_folder | Where-Object {$_.Name -match $software_installer}).Name  
$InstallMSI = $new_soft_installer_folder + $InstallMSI


$computername=$env:COMPUTERNAME
$appID=CheckSoft


foreach($key in $appID){

    if ((-not ($new_version_tag -eq $appID.Version)))
    {
        
       # Write-Host $key
        
        Write-Host $appID.Version
      
        $app=Get-WmiObject Win32_Product -ComputerName $computername | Where-Object {$_.name -eq $appID.Name}
        $app.uninstall() 

    }
    elseif ($new_version_tag -eq $appID.Version)
    {
        Write-Host "Break"
    }
    

   #Write-Host $thiskey

    if (-not ([string]::IsNullOrEmpty($DisplayName)))
    {
        # Write-Host $DisplayName
        # break
    }
   
}
$appID=CheckSoft

if ($null -eq $appID){
    Start-Process -Wait -FilePath msiexec -ArgumentList ('/package "' + $InstallMSI + '" /quiet /norestart "' + $logpath + '"')
}

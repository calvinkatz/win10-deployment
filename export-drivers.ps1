<#
   NOTES
   ===========================================================================
    Created with:  Visual Studio Code
    Created on:    1/22/2018
    Created by:    koca013636
    Filename:      export-drivers.ps1
   ===========================================================================
   DESCRIPTION
       Export drivers to network share.
       Network share derived from localhost hardware.
#>

# Globals
$share_prefix = '\\funzone\drivers\Script_Import\'
$scratch_dir = 'C:\TEMP\DriverExport'

# Get system information from WMI
$wmi_results = Get-WmiObject -Query 'SELECT Manufacturer,Model FROM Win32_ComputerSystem'
$manufacturer = $wmi_results.Manufacturer
$model = $wmi_results.Model

$wmi_results = Get-WmiObject -Query 'SELECT OSArchitecture,Version FROM Win32_OperatingSystem'
$os_architecture = $wmi_results.OSArchitecture
$os_version = ""
switch -Regex ($wmi_results.Version) {
    '^10' {$os_version = "10"}
    default {$os_version = $wmi_results.Version}
}

# TODO: Sanitize the inputs
$manufacturer = $manufacturer -replace ' ', '_'
$model = $model -replace ' ', '_'
$os_architecture = $os_architecture -replace ' ', '_'
$os_version = $os_version -replace ' ','_'

# Set share and log path
# Create path if missing
$share_path = $share_prefix + $manufacturer + '\' + $model + '\' + $os_architecture + '\' + $os_version
$log = $share_path + '\export_log.txt'
if (!(Test-Path $share_path)) {
    New-Item -ItemType Directory $share_path
}

# Check scratch directory
# Create if missing
if (!(Test-Path $scratch_dir)) {
    New-Item -ItemType Directory $scratch_dir
}

# Export drivers to share
Export-WindowsDriver -Destination $share_path -ScratchDirectory $scratch_dir -LogPath $log -Online

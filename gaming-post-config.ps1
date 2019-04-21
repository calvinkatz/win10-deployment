# Install chocolatey first:
# Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#
# Post config for personal desktop.
# Login as your personal account first, some choco setups don't place icons/shortcuts for all users.
#

$download_dir = $env:TEMP

function Set-RegistryProperty {
    param(
        $reg_path,
        $reg_prop,
        $reg_val
    )
    if ((Get-ItemProperty $reg_path).$reg_prop) {
        Set-ItemProperty $reg_path -Name $reg_prop -Type DWORD -Value 1 -Force
    }
    else {
        New-ItemProperty $reg_path -Name $reg_prop -Type DWORD -Value 1 -Force
    }
}

# Chocolatey Setup
$choco_items = @(
'firefox',
'bitwarden',
'git',
'putty',
'winscp',
'7zip',
'vscode',
'sumatrapdf',
'libreoffice-fresh',
'vlc',
'discord',
'spotify',
'steam',
'uplay',
'epicgameslauncher',
'origin',
'classic-shell',
'nvidia-display-driver',
'disable-nvidia-telemetry',
'logitechgaming'
)
foreach($item in $choco_items) {
    & cinst -y $item
}

# Standalone Installs
$web_items = @{
'x1.exe' = 'https://www.evga.com/EVGA/GeneralDownloading.aspx?file=EVGA_Precision_X1_0.3.15.0_BETA.exe';
'm9xx.exe' = 'https://www.gracedesign.com/support/drivers/XMOS-Stereo-USB-Audio-Class2-Driver-306A_v4.11.0.exe';
'bnet.exe' = 'https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP';
'amd.exe' = 'https://www2.ati.com/drivers/amd_chipset_drivers_18.10_1018.exe';
'intel.exe' = 'https://downloadmirror.intel.com/25016/eng/PROWinx64.exe';
'lasso.exe' = 'https://dl.bitsum.com/files/processlassosetup64.exe';
}
foreach($item in $web_items.GetEnumerator()) {
    $outfile = "$download_dir\" + $item.key
    Invoke-WebRequest -Uri $item.value -OutFile $outfile
    & $outfile
    $a = Read-Host -Prompt "Press any key to continue"
}

# Settings
#
# Quick Access disable
# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
# LaunchTo - DWORD
# 1 = This PC
# 2 = Quick access
# 3 = Downloads
Set-RegistryProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' 1
Set-RegistryProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' 1

# Show file extensions
# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
# HideFileExt - DWORD
# 0 = Show
# 1 = Hide
Set-RegistryProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0
Set-RegistryProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0

# Show recent files/folders in explorer quick access
# HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer
# ShowRecent - DWORD
Set-RegistryProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent' 0
Set-RegistryProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent' 0
# ShowFrequent - DWORD
Set-RegistryProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' 0
Set-RegistryProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' 0

# Show recent files/folders in start
#HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
# Start_TrackDocs
Set-RegistryProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' 0
Set-RegistryProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' 0

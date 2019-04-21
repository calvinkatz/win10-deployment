# Windows 10 Deployment Scripts

Collection of scripts for using with Windows 10 deployments (SCCM/MDT)

## Driver Import/Export

Eliminate the need to import and create driver packages in SCCM.

1. Use export script on working machine to export all drivers to a network location based on the machine's make/model.
2. Use import script in Task Sequence during deployment to pull drivers from network location based on the machine's make/model.

## Wifi Settings

Barring Intel ProSet tools or other management this script can set specific Wireless Adapter settings.

## Windows 10 Decrap

Removes pre-provisioned apps from Win10 install and sets privacy settings to more private defaults.

Run script as administrator and reboot after running.

## Gaming Post Config

Post config script for personal desktop. Installs tools and drivers for my personal PC and applies some settings.

Run the script under your account as admin; some chocolety installs don't create icons/shortcuts for all users.
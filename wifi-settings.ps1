<#
    NOTES
    ===========================================================================
    Created with:  Visual Studio Code
    Created on:    06/07/2018
    Created by:    koca013636
    Filename:      wifi-settings.ps1
    ===========================================================================
    DESCRIPTION
        Find active wifi adapter using WMI.
        Update wifi adapter settings in registry.
        Use '-sccm' argument for SCCM deployment.
    09/18/2018 - Add variables for specific adapter/driver settings.
                $adapter_model
                $driver_version
    06/07/2018 - Initial
#>

param (
    # Computer name for remote.
    [ValidateNotNull()]
    [string]
    $ComputerName = $env:COMPUTERNAME,
    # SCCM Switch
    [Switch]
    $sccm
)


#####################################################

# Global VARS
$adapter_model = ''
$driver_version = ''

#####################################################

function Write-Log {
    param([string]$text)
    if (-not $sccm) {
        Write-Host $text
    }
}

# Get active adapter assuming NETwNs32 service is running
$adapter_list = Get-WmiObject -ComputerName $ComputerName -Class Win32_NetworkAdapter `
    -Property @('NetEnabled', 'ServiceName', 'GUID', 'Name', 'Index') |`
    Where-Object {$_.ServiceName -match 'NETwNs32'}

if (-not $adapter_list) {
    "No adapters found, exiting!"
    exit 0
}

# For each adapter found
foreach ($adapter in $adapter_list) {
    Write-Log ("Found adapter: " + $adapter.Name)
    Write-Log ("At index: " + ( "{0:D4}" -f $adapter.Index ))

    # Open remote registry for reading
    Write-Log "Opening remote registry..."
    $location = "System\CurrentControlSet\Control\Class"
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
    $reg_sub_key = $reg.OpenSubKey($location)

    # Assume network adapter class is {4D36E972-E325-11CE-BFC1-08002BE10318}
    # Check for (default) Network adapters value
    $temp = $reg_sub_key.OpenSubKey('{4D36E972-E325-11CE-BFC1-08002BE10318}')
    if ($temp.GetValue('') -match "Network adapters") {
        $location += '\{4D36E972-E325-11CE-BFC1-08002BE10318}'
    }
    else {
        # Else search for network adapter class
        Write-Log "Searching for network adapter class..."
        $reg_sub_key_names = $reg_sub_key.GetSubKeyNames()
        $count = $reg_sub_key_names.Count - 1
        $state = 0

        # Search through each subkey in 'System\CurrentControlSet\Control\Class'
        # Exit loop upon finding key
        while ($state -eq 0 -and $count -gt 0) {
            $temp = $reg_sub_key.OpenSubKey($reg_sub_key_names[$count])

            if ($temp.GetValue('') -match "Network adapters") {
                Write-Log "Found class: \" + $reg_sub_key_names[$count]
                $location += "\" + $reg_sub_key_names[$count]
                $state = 1
            }
            $count--
        }
    }

    # Assume adapter index from WMI query
    $adapter_index = ( "{0:D4}" -f $adapter.Index )
    $temp = $reg.OpenSubKey($location + "\$adapter_index")
    if ($temp.GetValue('NetCfgInstanceId') -match $adapter.GUID) {
        $location += "\" + $adapter_index
        $adapter_model = $temp.GetValue('AdapterModel')
        $driver_version = $temp.GetValue('DriverVersion')
    }
    else {
        # Else search for adapter
        Write-Log "Searching for network adapter..."
        $reg_sub_key = $reg.OpenSubKey($location)
        $reg_sub_key_names = $reg_sub_key.GetSubKeyNames()
        $count = $reg_sub_key.SubKeyCount - 1
        $state = 0
        # Iterate through each adapter subkey
        # Exit loop upon finding adapter key
        while ($state -eq 0 -and $count -gt 0) {
            if ($reg_sub_key_names[$count] -match "\d{1,4}") {
                $temp = $reg_sub_key.OpenSubKey($reg_sub_key_names[$count])
            }

            # Compare adapter GUID in registry to WMI query
            if ($temp.GetValue('NetCfgInstanceId') -match $adapter.GUID) {
                Write-Log "Found adapter: " + $reg_sub_key_names[$count]
                $location += "\" + $reg_sub_key_names[$count]
                $adapter_model = $temp.GetValue('AdapterModel')
                $driver_version = $temp.GetValue('DriverVersion')
                $state = 1
            }
            $count--
        }
    }

    # Modify adapter settings to desired state
    Write-Log "Modify values for model: $adapter_model"
    if ($adapter_model -match '7260') {
        $reg_sub_key = $reg.OpenSubKey($location, $true)
        $reg_sub_key.SetValue('*DeviceSleepOnDisconnect', "0")
        $reg_sub_key.SetValue('*PMARPOffload', "1")
        $reg_sub_key.SetValue('*PMNSOffload', "1")
        $reg_sub_key.SetValue('*PMWiFiRekeyOffload', "1")
        $reg_sub_key.SetValue('*WakeOnMagicPacket', "1")
        $reg_sub_key.SetValue('*WakeOnPattern', "1")
        $reg_sub_key.SetValue('BT3HSMode', "0")
        $reg_sub_key.SetValue('ChannelWidth24', "0")
        $reg_sub_key.SetValue('ChannelWidth52', "0")
        $reg_sub_key.SetValue('CtsToItself', "1")
        $reg_sub_key.SetValue('FatChannelIntolerant', "0")
        $reg_sub_key.SetValue('IbssQosEnabled', "0")
        $reg_sub_key.SetValue('IbssTxPower', "100")
        $reg_sub_key.SetValue('IEEE11nMode', "2")
        $reg_sub_key.SetValue('RecommendedChannel24', "1")
        $reg_sub_key.SetValue('RoamAggressiveness', "2")
        $reg_sub_key.SetValue('RoamingPreferredBandType', "2")
        $reg_sub_key.SetValue('ThroughputBoosterEnabled', "0")
        $reg_sub_key.SetValue('uAPSDSupport', "0")
        $reg_sub_key.SetValue('WirelessMode', "17")
        $reg_sub_key.SetValue('PnPCapabilities', "24", [Microsoft.Win32.RegistryValueKind]::DWord)
    }
    if ($adapter_model -match '8260') {
        $reg_sub_key = $reg.OpenSubKey($location, $true)
        $reg_sub_key.SetValue('*DeviceSleepOnDisconnect', "0")
        $reg_sub_key.SetValue('*PMARPOffload', "1")
        $reg_sub_key.SetValue('*PMNSOffload', "1")
        $reg_sub_key.SetValue('*PMWiFiRekeyOffload', "1")
        $reg_sub_key.SetValue('*WakeOnMagicPacket', "1")
        $reg_sub_key.SetValue('*WakeOnPattern', "1")
        $reg_sub_key.SetValue('ChannelWidth24', "0")
        $reg_sub_key.SetValue('ChannelWidth52', "0")
        $reg_sub_key.SetValue('CtsToItself', "1")
        $reg_sub_key.SetValue('FatChannelIntolerant', "0")
        $reg_sub_key.SetValue('IbssQosEnabled', "0")
        $reg_sub_key.SetValue('IbssTxPower', "75")
        $reg_sub_key.SetValue('IEEE11nMode', "2")
        $reg_sub_key.SetValue('MIMOPowerSaveMode', "0")
        $reg_sub_key.SetValue('RecommendedChannel24', "1")
        $reg_sub_key.SetValue('RoamAggressiveness', "2")
        $reg_sub_key.SetValue('RoamingPreferredBandType', "2")
        $reg_sub_key.SetValue('ThroughputBoosterEnabled', "0")
        $reg_sub_key.SetValue('uAPSDSupport', "0")
        $reg_sub_key.SetValue('WirelessMode', "17")
        $reg_sub_key.SetValue('PnPCapabilities', "24", [Microsoft.Win32.RegistryValueKind]::DWord)
    }

    # Switch for specific settings
    # switch -Regex ($computer_name) {
    #     '^[EF]' { $reg_sub_key.SetValue('IbssTxPower', "75") } # MRMC specific (High)
    #     default { $reg_sub_key.SetValue('IbssTxPower', "75") } # Global default (High)
    # }
}

Write-Log "Settings applied, please REBOOT."

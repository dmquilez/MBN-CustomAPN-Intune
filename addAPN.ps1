<#
.SYNOPSIS
Adds a Mobile Broadband Network (MBN) profile configuring a custom APN and connects it to the specified interface.

.DESCRIPTION
This script adds an MBN profile and connects it to the specified interface. It captures the ICCID and SubscriberID using regex from the output of the netsh command. It also extracts the defaultProfileName using regex from the output of the netsh command. The script saves the populated XML to a file, adds the MBN profile and connects it, and then removes the profile XML file.

.PARAMETER APNUsername
The username for the Access Point Name (APN). This parameter is mandatory.

.PARAMETER APNPassword
The password for the Access Point Name (APN). This parameter is mandatory.

.PARAMETER APN
The Access Point Name (APN). This parameter is mandatory.

.PARAMETER AuthProtocol
The authentication protocol.

.PARAMETER HomeProviderName
The name of the home provider.

.PARAMETER profileName
The name of the MBN profile. This parameter is mandatory.

.PARAMETER xmlPath
The path to save the populated XML file. This parameter is mandatory.

.PARAMETER broadbandInterfaceName
The name of the broadband interface. This parameter is mandatory.

.EXAMPLE
.\addAPN.ps1 -APNUsername "username" -APNPassword "password" -APN "example.com" -AuthProtocol "PAP" -HomeProviderName "provider" -profileName "profile" -xmlPath "C:\temp\profile.xml" -broadbandInterfaceName "Cellular"

This example adds an MBN profile and connects it to the specified interface.

.NOTES
This script requires administrative privileges to run.

Author: David Muñoz (dmquilez)
Date: 10/26/2023
#>
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $APNUsername,

    [Parameter()]
    [String]
    $APNPassword,

    [Parameter(Mandatory = $true)]
    [String]
    $APN,

    [Parameter(Mandatory = $true)]
    [String]
    $AuthProtocol,

    [Parameter(Mandatory = $true)]
    [String]
    $HomeProviderName,

    [Parameter(Mandatory = $true)]
    [String]
    $profileName,

    [Parameter(Mandatory = $true)]
    [String]
    $xmlPath,

    [Parameter(Mandatory = $true)]
    [String]
    $broadbandInterfaceName
)

# Capture the output of the netsh command
$netshOutput = Invoke-Expression 'netsh mbn show readyinfo *' | Out-String

# Extract ICCID using regex
if ($netshOutput -match '[A-Za-z0-9]{20}') {
    $ICCID = $matches[0]
}
else {
    Write-Error "ICCID not found in netsh output"
    exit
}

# Extract SubscriberID using regex
if ($netshOutput -match '[0-9]{15}') {
    $SubscriberID = $matches[0]
}
else {
    Write-Error "Subscriber ID not found in netsh output"
    exit
}
 
# Capture the output of the netsh command
$netshOutput = Invoke-Expression 'netsh mbn show profile' | Out-String

# Extract defaultProfileName using regex (assuming is a GUID)
if ($netshOutput -match '[A-Za-z0-9]{8}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{12}') {
    $defaultProfileName = $matches[0]
}
else {
    Write-Error "defaultProfileName not found in netsh output"
    exit
}
 
# Define the XML template using a here-string
$xmlTemplate = @"
<?xml version="1.0"?>
<MBNProfileExt xmlns="http://www.microsoft.com/networking/WWAN/profile/v4">
<Name>$ProfileName</Name>
<Description>$ProfileName</Description>
<IsDefault>true</IsDefault>
<ProfileCreationType>AdminProvisioned</ProfileCreationType>
<SubscriberID>$SubscriberID</SubscriberID>
<SimIccID>$ICCID</SimIccID>
<HomeProviderName>$HomeProviderName</HomeProviderName>
<ConnectionMode>manual</ConnectionMode>
<Context>
<AccessString>$APN</AccessString>
<UserLogonCred>
<UserName>$APNUsername</UserName>
<Password>$APNPassword</Password>
</UserLogonCred>
<Compression>DISABLE</Compression>
<AuthProtocol>$AuthProtocol</AuthProtocol>
</Context>
<PurposeGroups>
<PurposeGroupGuid>{$defaultProfileName}</PurposeGroupGuid>
</PurposeGroups>
<AdminEnable>true</AdminEnable>
<AdminRoamControl>AllRoamAllowed</AdminRoamControl>
<IsExclusiveToOther>true</IsExclusiveToOther>
</MBNProfileExt>
"@

# Save the populated XML to a file
$xmlTemplate | Out-File $xmlPath -Encoding utf8
 
# Add the MBN profile and connect it
netsh mbn add profile interface="$broadbandInterfaceName" name="$xmlPath"
netsh mbn connect interface="$broadbandInterfaceName" connmode=tmp name=$xmlPath
 
#Remove the profile XML file
Remove-Item -Path $xmlPath
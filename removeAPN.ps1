<#
.SYNOPSIS
This script removes a specific APN profile from a mobile broadband interface.

.DESCRIPTION
This script uses the netsh command to delete a specific APN profile from a mobile broadband interface. The script requires two parameters: the name of the broadband interface and the name of the profile to be deleted.

.PARAMETER broadbandInterfaceName
The name of the mobile broadband interface from which the APN profile will be deleted. This parameter is mandatory.

.PARAMETER profileName
The name of the APN profile to be deleted. This parameter is mandatory.

.EXAMPLE
.\removeAPN.ps1 -broadbandInterfaceName "Cellular" -profileName "APN Profile 1"
This example removes the "APN Profile 1" from the "Mobile Broadband Connection" interface.

.NOTES
This script requires administrative privileges to run.

Author: David Muñoz (dmquilez)
Date: 10/26/2023
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [String]
    $broadbandInterfaceName,

    [Parameter(Mandatory = $true)]
    [String]
    $profileName
)

netsh mbn delete profile interface="$broadbandInterfaceName" name="$profileName"
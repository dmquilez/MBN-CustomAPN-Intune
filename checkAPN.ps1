<#
.SYNOPSIS
This script checks if a custom profile exists in the netsh output.

.DESCRIPTION
This script checks if a custom profile exists in the netsh output by invoking the 'netsh mbn show profile' command and searching for the specified profile name. If the profile exists, the script returns success (exit code 0). If the profile does not exist, the script returns failure (exit code 1).

.EXAMPLE
.\checkAPN.ps1

This example checks if the custom profile named "MyCustomProfile" exists in the netsh output.

.NOTES
This script requires administrative privileges to run.

Author: David Muñoz (dmquilez)
Date: 10/26/2023
#>

# Define the profile name to be checked
$profileName = "MyCustomProfile"

# Check if the custom profile exists
$netshOutput = Invoke-Expression 'netsh mbn show profile' | Out-String
if ($netshOutput -match $profileName) {
    #Return success
    Write-Host "Custom profile exists."
    exit 0
}
else {
    #Return failure
    Write-Host "Custom profile not found in netsh output"
    exit 1
}
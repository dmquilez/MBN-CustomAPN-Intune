# Custom APN for a MBN through Intune

This repository contains PowerShell scripts for managing Mobile Broadband Network (MBN) profiles, specifically for configuring custom APNs (Access Point Names) and integrating them with Microsoft Intune as a Win32 app.

**Disclaimer:** *Please note that this solution is created by David Muñoz (Technology Consultant at Microsoft), but it is not an official Microsoft tool. The solution is provided "as is" without any warranties, expressed or implied. Use at your own risk.*

## Table of Contents

- [Description](#description)
- [Scripts](#scripts)
  - [addAPN.ps1](#addapnps1)
  - [removeAPN.ps1](#removeapnps1)
  - [checkAPN.ps1](#checkapnps1)
- [Deploying through Intune](#deploying-through-intune)

## Description

The provided scripts aid developers and IT admins in:

1. Adding an MBN profile with a custom APN and connecting it to a specified interface.
2. Removing a specified APN profile from a mobile broadband interface.
3. Checking if a custom profile exists in the system.

These scripts are particularly useful when creating a Win32 app Intune package.

## Scripts

### **addAPN.ps1**

#### Description
Adds a MBN profile and connects it to the specified interface. It captures the ICCID and SubscriberID using regex from the output of the netsh command. The script then saves the populated XML to a file, adds the MBN profile, and connects it before removing the profile XML file.

#### Parameters

- `APNUsername`: The username for the Access Point Name (APN).
- `APNPassword`: The password for the Access Point Name (APN).
- `APN`: The Access Point Name (APN).
- `AuthProtocol`: The authentication protocol.
- `HomeProviderName`: The name of the home provider.
- `profileName`: The name of the MBN profile.
- `xmlPath`: The path to save the populated XML file.
- `broadbandInterfaceName`: The name of the broadband interface.

#### Usage

```powershell
.\addAPN.ps1 -APNUsername "username" -APNPassword "password" -APN "example.com" -AuthProtocol "PAP" -HomeProviderName "provider" -profileName "profile" -xmlPath "C:\temp\profile.xml" -broadbandInterfaceName "Cellular"
```

### **removeAPN.ps1**

#### Synopsis
Removes a specific APN profile from a mobile broadband interface.

#### Description
This script uses the `netsh` command to delete a specific APN profile from a mobile broadband interface.

#### Parameters

- `broadbandInterfaceName`: The name of the mobile broadband interface from which the APN profile will be deleted. This parameter is mandatory.
  
- `profileName`: The name of the APN profile to be deleted. This parameter is mandatory.

#### Usage

```powershell
.\removeAPN.ps1 -broadbandInterfaceName "Cellular" -profileName "APN Profile 1"
```
### **checkAPN.ps1**

#### Synopsis
Checks if a custom profile exists in the `netsh` output.

#### Description
This script checks if a custom profile exists in the `netsh` output by invoking the 'netsh mbn show profile' command and searching for the specified profile name. If the profile exists, the script returns success (exit code 0). If the profile does not exist, the script returns failure (exit code 1).


#### Usage

```powershell
.\checkAPN.ps1
```
⚠️ __Important__: You must hardcode the profile name in the script.

## Deploying through Intune

Before deploying these scripts through Intune, they need to be packaged into the .intunewin format. Utilize the IntuneWinAppUtil tool for this purpose.

You will find more information in the Microsoft-Win32-Content-Prep-Tool official repository: https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool

## Intune Configuration Example

### Install Command:

```
powershell.exe -executionpolicy bypass -file .\addAPN.ps1 -APNUsername "your_username" -APNPassword "your_password" -APN "your_apn" -AuthProtocol "your_auth_protocol" -HomeProviderName "your_provider" -profileName "your_profile_name" -xmlPath "path_to_save_xml" -broadbandInterfaceName "interface_name"
```

### Uninstall Command:

```
powershell.exe -executionpolicy bypass -file .\removeAPN.ps1 -broadbandInterfaceName "interface_name" -profileName "your_profile_name"
```

## Detection Rule

For the detection rule phase in Intune, use the `checkAPN.ps1` script. When configuring the Win32 app in Intune, upload the `checkAPN.ps1` script during the detection rule configuration. The script will return a success (exit code 0) if the custom profile exists and a failure (exit code 1) if it doesn't.

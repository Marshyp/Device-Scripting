<#	
	.DESCRIPTION
		This script is used to quickly and easily configure sandbox devices in our corporate environment.
        Note that some options may need enabling or disabling depending on requirements, please review carefully.

    .VERSION
        Version 1.0 - Initial build/release
                      There is a LOT that needs to be amended / added / hardened on this, so please bare this in mind. 

    .USAGE 
        This script is intended for use on Windows 11 builds, and should be ran after the initial OFF DOMAIN local
        Admin has been created, and Windows booted. 

    .SCRIPT TASKS
        — Create User account 
        — Defender onboarding
        — Disable NIC
        — Disable RDP
        — Set Background, Lock Screen and User Profile Picture for ALL USERS
        — Windows 11 hardening
        — Enable Windows Sandbox
        — Check for updates 
        — Winget Upgrade All 
        — Restart device
        

#>

## Check that we are running as admin
Write-Host "Checking for elevated permissions..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
# User is not an administrator
Write-Warning "Insufficient permissions to run this script. We will attempt to elevate permissions."
# Attempt elevated script run
Start-Process .\Sandbox-build.ps1 -Verb RunAs
Break
}
else {
Write-Host "Code is running as administrator — go on executing the script..." -ForegroundColor Green
}


#### Define Variables
$LockScreenLocation
$WallpaperLocation = "C:\users\public\Public Pictures\background.png"
$UserProfilePic
$UserName = "IT_User"
$UserDescription = "This is the local standard user account used for Sandbox testing"
$NICName = "Ethernet"
#####

#### Create our Local User Account
New-LocalUser -Name $UserName -Description $UserDescription -NoPassword # We use no password to allow immediate login, as off network deemed minimal risk.
####


#### MS Defender
# cmd /c .\DefenderOnBoarding.cmd

#### Disable Ethernet Network Adapter - We will use Wireless instead so that we can force Guest access.
Disable-NetAdapter -Name $NICName -Confirm:$false
####

#### Disable RDP 
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 1
####

#### Now lets update all the things! 
## Winget Upgrade and accept terms
winget upgrade --all -h --accept-source-agreements --accept-package-agreements
####

## Windows Updates // Likely that this can be improved
# Install required modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module pswindowsupdate -force
Import-Module PSWindowsUpdate -force
# End installing required modules
#Get list of windows updates to install
Get-WindowsUpdate
#Install the updates
Install-WindowsUpdate -AcceptAll -install -AutoReboot
####

<# NEEDS WORK
#### Set Background, Lock Screen and Profile Picture for all users.
# Background Image
Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name Wallpaper -value $WallpaperLocation
Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name TileWallpaper -value "0"
Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name WallpaperStyle -value "10" -Force

# LockScreen Image


####
#>



#### WINDOWS HARDENING
## Credits to @JKerai1 :: https://github.com/jkerai1/WindowsHardeningScripts

# Disable Autoplay
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xff /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xff /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoAutorun /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRecentDocsHistory /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRecentDocsMenu /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v ClearRecentDocsOnExit /t REG_DWORD /d 1 /f
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v DisableAutoplay /t REG_DWORD /d 1 /f

# Disable AutoRun
$regPath= "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$key0 = "NoAutorun"
Set-ItemProperty -Path $regKey -Name $key0 -Value 1 -Type DWORD -Force
Write-Host "The value of '$key0' has been set to 1."

# Disable ClickOnceTrust
reg add "HKLM\SOFTWARE\MICROSOFT\.NETFramework\Security\TrustManager\PromptingLevel" /v MyComputer /t REG_SZ /d "Disabled" /f
reg add "HKLM\SOFTWARE\MICROSOFT\.NETFramework\Security\TrustManager\PromptingLevel" /v LocalIntranet /t REG_SZ /d "Disabled" /f
reg add "HKLM\SOFTWARE\MICROSOFT\.NETFramework\Security\TrustManager\PromptingLevel" /v Internet /t REG_SZ /d "Disabled" /f
reg add "HKLM\SOFTWARE\MICROSOFT\.NETFramework\Security\TrustManager\PromptingLevel" /v TrustedSites /t REG_SZ /d "Disabled" /f
reg add "HKLM\SOFTWARE\MICROSOFT\.NETFramework\Security\TrustManager\PromptingLevel" /v UntrustedSites /t REG_SZ /d "Disabled" /f

# Disable WifiSense
If (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
	New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0

# LSA Protection
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$key1 = "RunAsPPL"
$key2 = "RunAsPPLBoot"

# Check if the value exists and is already set to 1
if ((Test-Path $regKey) -and (Get-ItemProperty $regKey -Name $key1 -ErrorAction SilentlyContinue).$key1 -eq 1) {
    Write-Host "The value of '$key1' under $regKey is already set to 1."

}
else {
try {
    # Set the value to 1
    Set-ItemProperty -Path $regKey -Name $key1 -Value 1 -Type DWORD -Force
    Write-Host "The value of '$key1' under $regKey has been set to 1."
}

catch {
    Exit 1
}
}

if ((Test-Path $regKey) -and (Get-ItemProperty $regKey -Name $key2 -ErrorAction SilentlyContinue).$key1 -eq 1) {
    Write-Host "The value of '$key2' under $regKey is already set to 1."

}

else {
try {
    # Set the value to 1
    Set-ItemProperty -Path $regKey -Name $key2 -Value 1 -Type DWORD -Force
    Write-Host "The value of '$key2' under $regKey has been set to 1."
}

catch {
    Exit 1
}
}

# LSASS Hardening
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 00000008 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 00000001 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin /t REG_DWORD /d 00000000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdminOutboundCreds /t REG_DWORD /d 00000001 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v Negotiate /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" /v AllowProtectedCreds /t REG_DWORD /d 1 /f
####


#### Reboot the device.
cmd /c shutdown.exe /r /t 30 /c "Device prepped, Restarting to apply all changes."

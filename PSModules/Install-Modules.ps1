<# 
Deployment of Powershell Modules for administrative accounts
#>

# Set working directory for the logging
Set-Location $env:SystemDrive\

# Define date variable
$date = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")

# Check if the log location exists already
# Directory already exists, so we will just add to it. 
if (Get-ChildItem "$env:SystemDrive\Intune-Deploy" -ErrorAction SilentlyContinue) {
    Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date | Directory already exists."
  }

# If not, we will create it
else {
New-Item -path $env:SystemDrive -name "Intune-Deploy" -ItemType Directory -Force
Start-Sleep 2
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date | Directory doesn't exist, but we made it."
}

# Start transcript
Start-Transcript -Path "$env:SystemDrive\Intune-Deploy\PSModules.txt" -Append

# Force the TLS version to try to resolve Powershell Gallery issues
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date TLS version forced to 1.2"

# Sets PSGallery as trusted source for powershell module installation
# Define the variable to check the trust state at present.
$psrepository = Get-PSRepository -Name psgallery
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date | PSGallery repo fetched."
# Check if the repository is untrusted
if ($psrepository.InstallationPolicy -eq "untrusted") {
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Check if repository is untrusted."
# If it is, we will set it to a trusted source.

## ERRORING HERE
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted # ERRORING HERE AT THE MOMENT
### END ERRORING

Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Set PSGallery as trusted source."
}
# Otherwise, we will log that this is already trusted.
else {
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date PSGallery is already trusted."
}

## Install NuGet dependency for PowerShellGet
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installing NuGet"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Start a sleep so that we have time to ensure that this is fully installed
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installed NuGet"
start-sleep 2
# Import the package so that we can use it as part of this script
Import-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Imported NuGet"

# Now check if PowershellGet is installed
if (Get-Module -Name PowerShellGet -ErrorAction SilentlyContinue) {
# If so, we will append the log to advise.
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date PowerShellGet module is already installed"
}
# Otherwise we will install it.
else {
Install-Module -Name PowerShellGet -Force -AllowClobber
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installed PowerShellGet Module"
}

# Install AzureADHybridAuthenticationManagement module -- To Manage Hybrid Auth for Cloud Kerberos with Windows Hello for Business
if (Get-Module -Name AzureADHybridAuthenticationManagement -ErrorAction SilentlyContinue) {
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date AzureADHybridAuthenticationManagement module is already installed"
}
else {
Install-Module -Name AzureADHybridAuthenticationManagement -Force -AllowClobber
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installed AzureADHybridAuthenticationManagement Module"
}

# Install ExchangeOnlineManagement module -- To manage Exchange Online (Cloud Mailboxes)
if (Get-Module -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue) {
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date ExchangeOnlineManagement module is already installed"
}
else {
Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.1.0 -Force -AllowClobber
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installed ExchangeOnlineManagement Module"
}

# Install AzureAD Module -- To manage Azure AD user objects, groups, apps, roles, etc
if (Get-Module -Name AzureAD -ErrorAction SilentlyContinue) {
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date AzureAD module is already installed"
}
else {
Install-Module -Name AzureAD -Force -AllowClobber
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installed AzureAD Module"
} 

# Install Microsoft.Online.SharePoint.PowerShell module -- To manage SharePoint online
if (Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ErrorAction SilentlyContinue) {
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date SharePoint module is already installed"
}
else {
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installed SharePoint Module"
}

# Install MicrosoftTeams module -- To manage Teams
if (Get-Module -Name MicrosoftTeams -ErrorAction SilentlyContinue) {
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date MicrosoftTeams module is already installed"
}
else {
Install-Module -Name MicrosoftTeams -Force -AllowClobber
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installed MicrosoftTeams Module"
}

# Install Microsoft Graph module -- For Microsoft Graph API management
if (Get-Module -Name Microsoft.Graph -ErrorAction SilentlyContinue) {
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Microsoft Graph module is already installed"
}
else {
Install-Module -Name Microsoft.Graph -Force -AllowClobber
Add-Content -Path "$env:SystemDrive\Intune-Deploy\$env:COMPUTERNAME.log" -Value "$date Installed Microsoft Graph Module"
}

# Create registry key for detection - Now that the modules are installed
New-Item -Path "HKLM:\Software" -Name Intune-Deploy -Force -ErrorAction SilentlyContinue
New-Item -Path "HKLM:\Software\Intune-Deploy" -Name PSModules -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\Software\Intune-Deploy\PSModules" -Name "Installed" -Value ”1” -PropertyType "DWORD" -Force -ErrorAction SilentlyContinue

# Stop transcript
Stop-Transcript

# Exit Powershell (Not strictly needed, but to tidy things up!)
exit

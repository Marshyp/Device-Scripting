<#	
	.DESCRIPTION
		Clear down users from USB Temp Allow group
#>

# Create our log location
New-EventLog -LogName Intune-Deploy -Source "USB-Cleardown" -ErrorAction SilentlyContinue
Write-EventLog -LogName Intune-Deploy -Source "USB-Cleardown" -EntryType Information -EventId 001 -Message "Testing USB Cleardown script - This should be removed when moving to Azure Automation." -ErrorAction SilentlyContinue

# Import the AzureAD PowerShell module
try {
    Import-Module AzureAD
    Write-EventLog -LogName Intune-Deploy -Source "USB-Cleardown" -EntryType Information -EventId 001 -Message "AzureAD module imported successfully." -ErrorAction SilentlyContinue
}
Catch {
    Write-EventLog -LogName Intune-Deploy -Source "USB-Cleardown" -EntryType Error -EventId 001 -Message "AzureAD module import failed..." -ErrorAction SilentlyContinue
}

# Connect to Azure AD
try {
    $Credential = Get-Credential
    Connect-AzureAD -Credential $Credential -ErrorAction Stop
    Write-EventLog -LogName Intune-Deploy -Source "USB-Cleardown" -EntryType Information -EventId 001 -Message "Successfully connected to Azure AD." -ErrorAction SilentlyContinue
}
catch {
    Write-EventLog -LogName Intune-Deploy -Source "USB-Cleardown" -EntryType Error -EventId 001 -Message "Failed to connect to Azure AD: $($_.Exception.Message)" -ErrorAction SilentlyContinue
    return
}

# Set the name of the Azure cloud security group to modify
$groupName = "Temporary Allow Users"
# $allowedusers = "Media Operators"

$users = Get-AzureADGroupMember -ObjectId "YOUR OBJID HERE"

# Loop through each user in the list
foreach ($user in $users) {
    # Check if the EndDate value is less than or equal to today's date
    if ($user.ObjectID -ne "YOUR OBJID HERE") {
        
        try {
        # Get the user object from Azure Active Directory
        $userObj = Get-AzureADUser -ObjectId $user.ObjectID

        # Get the security group object from Azure Active Directory
        $groupObj = Get-AzureADGroup -SearchString $groupName

        # Remove the user from the security group
        Remove-AzureADGroupMember -ObjectId $groupObj.ObjectId -MemberId $userObj.ObjectId
        Write-EventLog -LogName Intune-Deploy -Source "USB-Cleardown" -EntryType Information -EventId 001 -Message "User $($user.DisplayName) removed from Azure AD Group" -ErrorAction SilentlyContinue
        }

        Catch {
            Write-EventLog -LogName Intune-Deploy -Source "USB-Cleardown" -EntryType Error -EventId 001 -Message "User $($user.DisplayName) could not be removed from Azure AD Group" -ErrorAction SilentlyContinue
        }

    }
    else {
        Write-Host "Skipping user $($user.DisplayName)"
    }
}

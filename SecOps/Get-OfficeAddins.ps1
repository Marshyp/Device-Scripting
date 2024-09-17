# Connect to Exchange Online
Connect-ExchangeOnline

# Get all user mailboxes (enabled)
$mailboxes = Get-EXOMailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited

# Initialize an array to store add-ins data
$addinsData = @()

# Loop through each mailbox to get add-ins
foreach ($mailbox in $mailboxes) {
    $addins = Get-App -Mailbox $mailbox.Identity

    foreach ($addin in $addins) {
        # Store add-in data for each mailbox
        $addinsData += [pscustomobject]@{
            Mailbox       = $mailbox.UserPrincipalName
            DisplayName   = $addin.DisplayName
            Enabled       = $addin.Enabled
            AppVersion    = $addin.AppVersion
        }
    }
}

# Export the add-ins data to a CSV file
$addinsData | Export-Csv "C:\Temp\office-addins-audit.csv" -NoTypeInformation -Append

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false

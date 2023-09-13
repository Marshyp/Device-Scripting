Write-Host "----------- Calendar permissions utility -----------"
Write-Host ""
Write-Host "Signing in......"

Connect-ExchangeOnline

$folder= ':\calendar'
cls

Write-Host ""
Write-Host "----------- Calendar permissions utility -----------"
Write-Host ""

$source=read-host -prompt 'Please enter the email address of the source mailbox'

Write-Host ""
$Delegate = Read-Host -Prompt 'Please enter the email address of the delegate user'

Write-Host ""
$AccessRight = Read-Host -Prompt 'Please enter access rights required'

$Bread = $source + $folder

cls
Write-Host ""
Write-Host "----------- Calendar permissions utility -----------"
write-host ""
Write-Host "Getting reference data......"

Add-MailboxFolderPermission -Identity $Bread -user $Delegate -AccessRights $AccessRight -SharingPermissionFlags Delegate,CanViewPrivateItems
cls

Write-Host ""
Write-Host "----------- Calendar permissions utility -----------"
write-host ""


Get-MailboxFolderPermission $Bread | select FolderName,User,AccessRights | format-table -property FolderName,User,AccessRights
Pause

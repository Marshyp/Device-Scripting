$folder= ':\calendar'

Write-Host "----------- Calendar permissions utility -----------`n" -ForegroundColor DarkGray
Write-Host "Signing in......`n" -ForegroundColor Red

Connect-ExchangeOnline

cls

Write-Host "----------- Calendar permissions utility -----------`n" -ForegroundColor DarkGray

$source= Read-Host -Prompt 'Please enter the email address of the source mailbox'

$Delegate = Read-Host -Prompt 'Please enter the email address of the delegate user'

$AccessRight = Read-Host -Prompt 'Please enter access rights required'

$Bread = $source + $folder

cls
Write-Host "Getting reference data......`n"

Add-MailboxFolderPermission -Identity $Bread -user $Delegate -AccessRights $AccessRight -SharingPermissionFlags Delegate,CanViewPrivateItems
cls

Write-Host "----------- Calendar permissions utility -----------`n"

Get-MailboxFolderPermission $Bread | select FolderName,User,AccessRights | format-table -property FolderName,User,AccessRights
Pause

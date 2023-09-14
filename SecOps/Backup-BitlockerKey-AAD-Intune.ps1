## Backup Bitlocker Recovery key to AAD and InTune

BackupToAAD-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId ((Get-BitLockerVolume -MountPoint $env:SystemDrive).KeyProtector | where {$_.KeyProtectorType -eq "RecoveryPassword"}).KeyProtectorId

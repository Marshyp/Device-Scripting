<#
  .DESCRIPTION
  Used to report on all users in specific groups that you are monitoring for. 
#>

﻿# Define groups to query
$groups = Get-Content C:\_Scripts\AdminGroups\Groupstoquery.csv ## Define your monitored groups here in a CSV 

# Run a for-each loop against all groups in the list
foreach($Group in $Groups) {            

# Get AD Group membership and append against the CSV - Format is GroupName | Member
# CSV is saved as format "ADGroupExport-{todays date}.csv"
Get-ADGroupMember -Id $Group | select  @{Expression={$Group};Label="Group Name"},Name | Export-CSV C:\_Scripts\AdminGroups\Output\ADGroupExport-$((Get-Date).ToString('dd-MM-yyyy')).csv -NoTypeInformation -append

}

# Send email to Technical Services with the attachment
Send-MailMessage -To you@somesickemail.org -Subject "Admin Group Membership Report" -Body "Please find attached the exported administrative group membership" -Port 25 -SmtpServer marshlab-net.mail.protection.outlook.com -From them@somesickemail.org -Attachments "C:\_Scripts\AdminGroups\Output\ADGroupExport-$((Get-Date).ToString('dd-MM-yyyy')).csv" -BodyAsHtml

# Delete today's CSV to save disk space, as this has now been emailed instead.
Remove-Item C:\_Scripts\AdminGroups\Output\ADGroupExport-$((Get-Date).ToString('dd-MM-yyyy')).csv

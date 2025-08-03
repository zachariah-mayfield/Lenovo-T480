# -----------------------------------  Create the new Admin user account  -----------------------------------

# Create the new Admin user account (if that user does not exist) that you want to use for SSH access.

#region Create New Admin User

# This section creates a new local user account named "zachariah.mayfield" and adds it to the Administrators group.
# It also ensures that the user "zachariah.mayfield" is in the Remote Desktop Users group
$Password = Read-Host -AsSecureString "Enter password for new user"
New-LocalUser -Name "zachariah.mayfield" -Password $Password -FullName "Zachariah Mayfield" -Description "Local admin account"
Add-LocalGroupMember -Group "Administrators" -Member "zachariah.mayfield"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "zachariah.mayfield" 

#endregion Create New Admin User
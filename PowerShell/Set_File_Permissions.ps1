# ---------------------------  Create the File(s) and Folder(s) for the SSH Authorized Key File  -------------------------------- 

#region Create Files and Folders for SSH

# Create the ssh directory for the administrators_authorized_keys file
New-Item -ItemType Directory -Force -Path "$env:ProgramData\ssh"

# Create the administrators_authorized_keys file in the ProgramData\ssh directory
New-Item -ItemType File -Force -Path "$env:ProgramData\ssh\administrators_authorized_keys"

# Create the .ssh directory in the user's home directory (not for an Administrator account SSH)
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.ssh

# Create the user's authorized_keys file in the user's .ssh directory (not for an Administrator account SSH)
New-Item -ItemType File -Force -Path $env:USERPROFILE\.ssh\authorized_keys

<#
| User type          | Where SSH looks for keys                            |
| ------------------ | --------------------------------------------------- |
| Regular user       | `C:\Users\<username>\.ssh\authorized_keys`          |
| Administrator user | `C:\ProgramData\ssh\administrators_authorized_keys` |
#>

#endregion Create Files and Folders for SSH

# ---------------------------------------  Permissions for Administrator Accounts  --------------------------------------- 

#region Permissions for Administrator Accounts

# Set permissions for the .ssh directory and authorized_keys file - This is for administrators
# This is for the administrators group to have full control over the authorized_keys file
icacls "$env:ProgramData\ssh\administrators_authorized_keys" /inheritance:r
icacls "$env:ProgramData\ssh\administrators_authorized_keys" /grant "Administrators:F"
icacls "$env:ProgramData\ssh\administrators_authorized_keys" /remove "Users"

# Check the permissions of the .ssh directory for administrators
icacls "$env:ProgramData\ssh\administrators_authorized_keys"
# EXAMPLE:  C:\ProgramData\ssh\administrators_authorized_keys NT AUTHORITY\SYSTEM:(I)(F)
#                                                  BUILTIN\Administrators:(I)(F)
#                                                  NT AUTHORITY\Authenticated Users:(I)(RX)

#endregion Permissions for Administrator Accounts

# ---------------------------  Set the Permissions for the File(s) and Folder(s) of the SSH Authorized Key File  -------------------------------- 

#region Permissions for standard Users

# Set permissions for the .ssh directory and authorized_keys file - This is for normal users - (not for an Administrator account SSH)
icacls "$env:USERPROFILE\.ssh" /inheritance:r
icacls "$env:USERPROFILE\.ssh" /grant "$($env:USERNAME):(R,W)"
icacls "$env:USERPROFILE\.ssh\authorized_keys" /inheritance:r
icacls "$env:USERPROFILE\.ssh\authorized_keys" /grant "$($env:USERNAME):(R,W)"

# Check the permissions of the .ssh directory
icacls "$env:USERPROFILE\.ssh"
# EXAMMPLE:  C:\Users\USERPROFILE\.ssh Lenovo-T480\USERNAME:(R,W)

# Check the permissions of the authorized_keys file
icacls "$env:USERPROFILE\.ssh\authorized_keys"
# EXAMMPLE:  C:\Users\USERPROFILE\.ssh\authorized_keys Lenovo-T480\USERNAME:(R,W)

#endregion Permissions for standard Users
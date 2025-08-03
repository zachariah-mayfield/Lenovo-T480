# Path to PowerShell Version 5
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

# Path to PowerShell Version 7 - when installed via Winget
# C:\Program Files\PowerShell\7\pwsh.exe

# These are instructions on how to set up your Windows 11 machine to allow connections of SSH and WinRM.
# It also shows how to enable it to be managed with ansible over WinRM with a NTLM connection and Certificate connection.
# Do NOT just run this script - It is meant to be run in sections and as a guide to do the above.

# 1: Install PowerShell 7.
# 2: Enable Remote Desktop and preform all other required changes to enable it.
# 3: Create the Administrator account and enable it for RDP
# 4: Set and enable all of the neccessary firewall rules
# 5: Enable the Windows Capability OpenSSH and preform all other required changes to enable it.
# 6: Enable WinRM Service and PSRemoting and preform all other required changes to enable it.
# 7: Create the File(s) and Folder(s) for the SSH Authorized Key File
# 8: Set Permissions for Administrator Accounts in the File(s) and Folder(s)

# ---------------------------------------  Back on your Local Machine (MacBook)  ---------------------------------------  


# On your Local Machine (MacBook)
# Display your public SSH key so you can copy it to the Windows 11 Mmachine
# BASH_COMMAND cat ~/.ssh/id_ed25519.pub

# On your Local Machine (MacBook)
# Remove the old SSH key from the known hosts file
# BASH_COMMAND ssh-keygen -R $IP_Address

# On your Local Machine (MacBook)
# SSH into the remote machine using the new user account
# BASH_COMMAND ssh -i ~/.ssh/id_ed25519 "$env:USERNAME@$IP_Address"

# Use PowerShell on your local machine to connect to the Windows 11 machine.
# $Session = New-PSSession -ComputerName 192.168.1.225 -Credential (Get-Credential) -Authentication Basic -UseSSL:$false
# Enter-PSSession $session

# This is a fix for macOS concurrency/runtime warning that sometimes crashes or hangs processes.
# This disables the safety check causing the crash.
# This is for MacOS - run this on your MacBook
# export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Run the below checks on MacOS
# Confirm port 5985 is open and reachable with:
# nc -vz 192.168.1.225 5985

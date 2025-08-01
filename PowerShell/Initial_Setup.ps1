clear-host

# Set Execution Policy
# This command sets the execution policy for PowerShell to Bypass for the current user, local machine, and process.
# This allows scripts to run without being blocked by the execution policy.
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
Set-ExecutionPolicy Bypass -Scope Process -Force

# -----------------------------------  NOTES  -----------------------------------

# Path to PowerShell Version 5
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

# Path to PowerShell Version 7 - when installed via Winget
# C:\Program Files\PowerShell\7\pwsh.exe

# -----------------------------------  NOTES  -----------------------------------

# Manually log in to the Windows 11 machine and run the following block of code to install the latest version of PowerShell using Winget.

# -----------------------------------  Install PowerShell using Winget  -----------------------------------

#region Install PowerShell using Winget

# Search for the latest version of PowerShell
winget search Microsoft.PowerShell

# This command installs the latest version of PowerShell using Winget
Write-Host "Installing PowerShell using Winget..."
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed.  install Winget first."
    exit 1
}
else {
    winget install --id Microsoft.Powershell --source winget --accept-source-agreements --accept-package-agreements # --silent
    Write-Host "PowerShell installation initiated." 
}

#endregion Install PowerShell using Winget

# -----------------------------------  Enable Remote Desktop  -----------------------------------

# Manually log in to the machine and enable Remote Desktop Protocol (RDP) access.

#region Enable Remote Desktop

# This section enables Remote Desktop Protocol (RDP) on the Windows machine.
# It sets the necessary registry key to allow RDP connections, opens the required firewall ports,
# and ensures that the Remote Desktop Services service is running.

# Enable Remote Desktop
# This sets fDenyTSConnections to 0, which tells Windows to allow RDP connections.
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

# Enable RDP through the firewall
# This opens TCP port 3389 in the firewall, which RDP uses.
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Enable the Remote Desktop Services service
Set-Service -Name TermService -StartupType Automatic

# This starts the TermService, which is responsible for handling RDP connections.
Start-Service -Name TermService

# This command ensures that the user "zachariah.mayfield" is in the Remote Desktop Users group
# and the Administrators group, allowing them to log in via RDP and have administrative privileges
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "zachariah.mayfield" 
Add-LocalGroupMember -Group "Administrators" -Member "zachariah.mayfield"

#endregion Enable Remote Desktop

# -----------------------------------  Create the new Admin user account  -----------------------------------

# Create the new Admin user account (if that user does not exist) that you want to use for SSH access.

#region Create New Admin User

# This section creates a new local user account named "zachariah.mayfield" and adds it to the Administrators group.
$Password = Read-Host -AsSecureString "Enter password for new user"
New-LocalUser -Name "zachariah.mayfield" -Password $Password -FullName "Zachariah Mayfield" -Description "Local admin account"
Add-LocalGroupMember -Group "Administrators" -Member "zachariah.mayfield"

#endregion Create New Admin User

# -----------------------------------  Add Windows Capability SSH  -----------------------------------  

#region Add Windows Capability SSH

# list all available optional features, filtered for OpenSSH:
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# This command checks if OpenSSH Client and Server are installed and installs them if they are not.
$sshClient = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
$sshServer = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
if ($sshClient.State -ne 'Installed') {
    Write-Host "Installing OpenSSH Client..."
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 -ErrorAction Stop
} else {
    Write-Host "OpenSSH Client is already installed."
}
if ($sshServer.State -ne 'Installed') {
    Write-Host "Installing OpenSSH Server..."
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop
} else {
    Write-Host "OpenSSH Server is already installed."
}

# Verify OpenSSH Client and Server are installed
$sshClientInstalled = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*' | Select-Object -ExpandProperty State
$sshServerInstalled = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Select-Object -ExpandProperty State
if ($sshClientInstalled -eq 'Installed' -and $sshServerInstalled -eq 'Installed') {
    Write-Host "OpenSSH Client and Server are both installed."
} else {
    Write-Host "OpenSSH Client or Server is not installed.  check the installation."
}

#endregion  Add Windows Capability SSH

# -----------------------------------  Enable the SSH Service(s)  -----------------------------------

#region Enable the SSH Services

# Enable the ssh-agent service
Set-Service -Name ssh-agent -StartupType 'Automatic'
# Start the ssh-agent service
Start-Service ssh-agent -ErrorAction Stop

# Enable the sshd (OpenSSH Server) service
Set-Service -Name sshd -StartupType 'Automatic'
# Start the sshd service
Start-Service sshd -ErrorAction Stop

# Display the status of the sshd and ssh-agent services
Get-Service sshd | Select-Object -Property "DisplayName","ServiceName","StartupType","Status"
Get-Service ssh-agent | Select-Object -Property "DisplayName","ServiceName","StartupType","Status"

#endregion Enable the SSH Services

# ---------------------------  Create the File(s) and Folder(s) for the SSH Authorized Key File  -------------------------------- 

#region Create Files and Folders for SSH

# Create the .ssh directory in the user's home directory
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.ssh

# Create the user's authorized_keys file in the user's .ssh directory
New-Item -ItemType File -Force -Path $env:USERPROFILE\.ssh\authorized_keys

# Create the administrators_authorized_keys file in the ProgramData\ssh directory
New-Item -ItemType File -Force -Path "$env:ProgramData\ssh\administrators_authorized_keys"

<#
| User type          | Where SSH looks for keys                            |
| ------------------ | --------------------------------------------------- |
| Regular user       | `C:\Users\<username>\.ssh\authorized_keys`          |
| Administrator user | `C:\ProgramData\ssh\administrators_authorized_keys` |
#>

#endregion Create Files and Folders for SSH

# ---------------------------  Set the Permissions for the File(s) and Folder(s) of the SSH Authorized Key File  -------------------------------- 

# Set the Permissions for the File(s) and Folder(s) of the SSH Authorized Key File

#region Permissions

# Set permissions for the .ssh directory and authorized_keys file - This is for normal users - not administrators
icacls "$env:USERPROFILE\.ssh" /inheritance:r
icacls "$env:USERPROFILE\.ssh" /grant "$($env:USERNAME):(R,W)"
icacls "$env:USERPROFILE\.ssh\authorized_keys" /inheritance:r
icacls "$env:USERPROFILE\.ssh\authorized_keys" /grant "$($env:USERNAME):(R,W)"

# Set permissions for the .ssh directory and authorized_keys file - This is for administrators
# This is for the administrators group to have full control over the authorized_keys file
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /grant "Administrators:F"
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /remove "Users"

# Check the permissions of the .ssh directory for administrators
icacls "C:\ProgramData\ssh\administrators_authorized_keys"
# EXAMPLE:  C:\ProgramData\ssh\administrators_authorized_keys NT AUTHORITY\SYSTEM:(I)(F)
#                                                  BUILTIN\Administrators:(I)(F)
#                                                  NT AUTHORITY\Authenticated Users:(I)(RX)

# Check the permissions of the .ssh directory
icacls "$env:USERPROFILE\.ssh"
# EXAMMPLE:  C:\Users\USERPROFILE\.ssh Lenovo-T480\USERNAME:(R,W)

# Check the permissions of the authorized_keys file
icacls "$env:USERPROFILE\.ssh\authorized_keys"
# EXAMMPLE:  C:\Users\USERPROFILE\.ssh\authorized_keys Lenovo-T480\USERNAME:(R,W)

#endregion Permissions

# ---------------------------------------  Firewall Rules  --------------------------------------- 

#region Firewall Rules

# Add a new firewall rule to allow SSH traffic
# This command creates a new firewall rule to allow inbound SSH traffic on port 22
New-NetFirewallRule -Name sshd `
    -DisplayName 'OpenSSH Server' `
    -Enabled True `
    -Direction Inbound `
    -Protocol TCP `
    -Action Allow `
    -LocalPort 22

# Add a new firewall rule to allow ICMPv4 (Ping) traffic
# This command creates a new firewall rule to allow inbound ICMPv4 traffic (Ping)
New-NetFirewallRule -Name Allow_ICMPv4_In `
    -DisplayName "Allow ICMPv4-In (Ping)" `
    -Protocol ICMPv4 `
    -IcmpType 8 `
    -Direction Inbound `
    -Action Allow `
    -Enabled True

#endregion Firewall Rules

# Get the IP address of the Windows 11 machine
Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet" -and $_.AddressFamily -eq "IPv4"} | Select-Object IPAddress

# ---------------------------------------  Back on your Local Machine (MacBook)  ---------------------------------------  

#region Local Machine (MacBook)

# On your Local Machine (MacBook)
# Display your public SSH key so you can copy it to the Windows 11 Mmachine
# BASH_COMMAND cat ~/.ssh/id_ed25519.pub

# On your Local Machine (MacBook)
# Remove the old SSH key from the known hosts file
# BASH_COMMAND ssh-keygen -R $IP_Address

# On your Local Machine (MacBook)
# SSH into the remote machine using the new user account
# BASH_COMMAND ssh -i ~/.ssh/id_ed25519 "$env:USERNAME@$IP_Address"

#endregion Local Machine (MacBook)
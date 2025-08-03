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
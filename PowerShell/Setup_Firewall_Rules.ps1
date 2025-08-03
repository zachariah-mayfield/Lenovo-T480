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

# Opens port 5986 for all profiles
# This is al ALT approach in creating a windows firewall rule:
$firewallParams = @{
    Name        = 'Custom-WinRM-HTTPS-In'
    Action      = 'Allow'
    Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]'
    Direction   = 'Inbound'
    DisplayName = 'Windows Remote Management (HTTPS-In)'
    LocalPort   = 5986
    Profile     = 'Any'
    Protocol    = 'TCP'
}
New-NetFirewallRule @firewallParams

#endregion Firewall Rules
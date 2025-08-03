# -----------------------------------  Enable WinRM Service & PSRemoting  -----------------------------------

#region Enable WinRM Service & PSRemoting

# Enable the Windows Remote Management (WinRM) service for remote PowerShell management.
Set-Service -Name WinRM -StartupType Automatic

# Allow CredSSP on client and server
Enable-WSManCredSSP -Role Server

# Enable PowerShell Remoting to allow remote management via PowerShell sessions (required for remote administration and automation).
if (-not (Test-WSMan -ErrorAction SilentlyContinue)) {
    Write-Host "WinRM is not configured. Enabling PSRemoting..."
    Enable-PSRemoting -Force
} else {
    Write-Host "WinRM is already configured. Skipping Enable-PSRemoting."
}

# Allow  Unencrypted Access (Optional, but required for Mac)
# This allows unencrypted traffic. Only use this on a trusted LAN. (if you're not using HTTPS)
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Add the host to Trusted Hosts - This is for all "*" IP Addresses or $IP_Address for a targeted IP.
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Enable required authentication mechanisms
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true # Only if using plain HTTP (unsafe), or testing
Set-Item -Path WSMan:\localhost\Service\Auth\Kerberos -Value $true # Domain environments
Set-Item -Path WSMan:\localhost\Service\Auth\Negotiate -Value $true # NTLM or Kerberos fallback
Set-Item -Path WSMan:\localhost\Service\Auth\CredSSP -Value $true # RDP or multi-hop WinRM
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true # HTTPS + PKI setups

# Set network category to Private (required for WinRM firewall rules to apply)
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private

# -----  Set the firewall rules for WinRM  -----
# Enables the main WinRM firewall rule that allows HTTP (port 5985) inbound connections. Required to allow WinRM traffic in secure (non-public) environments.
Set-NetFirewallRule -Name WINRM-HTTP-In-TCP -Enabled True

# Ensures that the rule above is enabled only on Private and Domain network profiles. WinRM should not typically be exposed on Public networks for security reasons.
Set-NetFirewallRule -Name WINRM-HTTP-In-TCP -Profile Private,Domain -Enabled True

#  Enables a variant of the main rule without network scope restrictions. This rule often allows access regardless of the IP scope.
Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-NoScope -Enabled True

# Open the WinRM firewall rule for private networks
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"

#endregion Enable WinRM Service & PSRemoting
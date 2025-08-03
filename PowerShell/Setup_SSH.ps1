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

#endregion Add Windows Capability SSH

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
Get-Service sshd, ssh-agent | Select-Object -Property "DisplayName","ServiceName","StartupType","Status"

#endregion Enable the SSH Services
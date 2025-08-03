# Opens port 5986 for all profiles
$firewallParams = @{
    Action      = 'Allow'
    Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]'
    Direction   = 'Inbound'
    DisplayName = 'Windows Remote Management (HTTPS-In)'
    LocalPort   = 5986
    Profile     = 'Any'
    Protocol    = 'TCP'
}
New-NetFirewallRule @firewallParams

# Get Cert
$My_store_cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -like "*CN=LENOVO-T480*"} | Select-Object -First 1

# Extract thumbprint
$thumbprint = $My_store_cert.Thumbprint

# Create HTTPS listener using cmd.exe /c
cmd.exe /c "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=`"`"; CertificateThumbprint=`"$thumbprint`"}"

# Verify the HTTPS Listener
winrm enumerate winrm/config/listener
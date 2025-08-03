# Get Cert
$My_store_cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -like "*CN=LENOVO-T480*"} | Select-Object -First 1

# Extract thumbprint
$thumbprint = $My_store_cert.Thumbprint

# Create HTTPS listener using PowerShell - does not work yet - still working the kinks out.
# Prepare the key-value pairs as a single string for the Listener creation
$listenerConfig = @{
    Address               = "*"
    Transport             = "HTTPS"
    CertificateThumbprint = $thumbprint
    Port                  = 5986
    Enabled               = $true
    Hostname              = ""
}

# Convert hashtable to string that matches expected WinRM syntax
$listenerValueString = $listenerConfig.GetEnumerator() | ForEach-Object { "$($_.Key)='$($_.Value)'" } -join ';'

# Build the full URI
$resourceUri = "winrm/config/Listener?Address=*+Transport=HTTPS"

# Create the listener with a low-level call
Invoke-Expression "winrm create $resourceUri @{ $listenerValueString }"

# use this as an alternative:
# Create HTTPS listener using cmd.exe /c
cmd.exe /c "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=`"`"; CertificateThumbprint=`"$thumbprint`"}"
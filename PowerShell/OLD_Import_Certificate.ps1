# -----------------------------------  Import Certificate  -----------------------------------

#region Import Certificate

# Import the certificate into Trusted Root store
Write-Output "Importing public cert to Trusted Root Certification Authorities..."
$cert = Get-ChildItem -Path "Cert:\LocalMachine\My" |
    Where-Object { $_.Subject -like "*CN=LENOVO-T480*" } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1

if ($cert) {
    $destStore = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
    $destStore.Open("ReadWrite")
    $destStore.Add($cert)
    $destStore.Close()
    Write-Output "Certificate added to Trusted Root."
} else {
    Write-Output "Could not find imported cert to add to Trusted Root store."
}

#endregion Import Certificate
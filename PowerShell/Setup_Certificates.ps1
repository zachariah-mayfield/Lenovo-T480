
# Enable Certificate Authentication in WinRM
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
Get-Item WSMan:\localhost\Service\Auth\Certificate

# Remove old Certificates
Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object { $_.Subject -like "*LENOVO-T480*" } | Remove-Item
Get-ChildItem -Path Cert:\LocalMachine\TrustedPeople | Where-Object { $_.Subject -like "*LENOVO-T480*" } | Remove-Item
Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*LENOVO-T480*" } | Remove-Item

# Import Pfx Certificate
Import-PfxCertificate -FilePath "$env:USERPROFILE\Downloads\zachariah.mayfield_Certificate.pfx" -CertStoreLocation Cert:\LocalMachine\My

$cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new("$env:USERPROFILE\Downloads\zachariah.mayfield_Certificate.pem")

# Import Certificate to the Certificate Store Cert:\LocalMachine\Root
$TrustedPeoplestore = Get-Item -LiteralPath Cert:\LocalMachine\TrustedPeople
$TrustedPeoplestore.Open('ReadWrite')
$TrustedPeoplestore.Add($cert)
$TrustedPeoplestore.Dispose()

# Import Certificate to the Certificate Store Cert:\LocalMachine\Root
$Root_store = Get-Item -LiteralPath Cert:\LocalMachine\Root
$Root_store.Open('ReadWrite')
$Root_store.Add($cert)
$Root_store.Dispose()

# ----------------------   MAKE SURE TO ENTER YOUR PASSWORD HERE   ---------------------- #

# Store your password as a secure string
# $vars = Import-PowerShellDataFile "~/GitHub/Main/Lenovo-T480/X_Secret/vars.psd1"
# $plainPassword = $vars.PASSWORD
$plainPassword = "MAKE SURE TO ENTER YOUR PASSWORD HERE"
$securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force

# ----------------------   MAKE SURE TO ENTER YOUR PASSWORD HERE   ---------------------- #

# Create the credential object
$username = "$env:COMPUTERNAME\$env:USERNAME"
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Mapping Certificate to a Local Account
$certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new("$env:USERPROFILE\Downloads\zachariah.mayfield_Certificate.pem")
$certificateChain = [System.Security.Cryptography.X509Certificates.X509Chain]::new()
[void]$certificateChain.Build($certificate)
$caThumbprint = $certificateChain.ChainElements.Certificate[-1].Thumbprint

$certMapping = @{
    Path       = 'WSMan:\localhost\ClientCertificate'
    Subject    = $certificate.GetNameInfo('UpnName', $false)
    Issuer     = $caThumbprint
    Credential = $credential
    Force      = $true
}
New-Item @certMapping
clear-host

# Set Execution Policy
# This command sets the execution policy for PowerShell to Bypass for the current user, local machine, and process.
# This allows scripts to run without being blocked by the execution policy.
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
Set-ExecutionPolicy Bypass -Scope Process -Force

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
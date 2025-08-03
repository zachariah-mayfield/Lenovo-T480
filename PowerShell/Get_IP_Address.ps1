# Get the IP address of the Windows 11 machine
Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet" -and $_.AddressFamily -eq "IPv4"} | Select-Object IPAddress
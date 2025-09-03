# OpenSSL config file line by line:
# This file controls important certificate properties like subject name, extensions, and Subject Alternative Names (SANs) — all crucial for your WinRM and Ansible certificate setup.
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req_combined
prompt = no

[req_distinguished_name]
CN = LENOVO-T480

[v3_req_combined]
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth

subjectAltName = @alt_names

[alt_names]
DNS.1 = LENOVO-T480
IP.1 = <Your_IP_Address>
otherName.1 = 1.3.6.1.4.1.311.20.2.3;UTF8:${USERNAME}@localhost

---

[req]
This section controls the behavior of the openssl req command:

distinguished_name = req_distinguished_name
Specifies the section name where the Distinguished Name (DN) attributes like CN, O, C are defined.

x509_extensions = v3_req_combined
When creating a self-signed cert (using openssl req -x509), this sets which extension section to include.

prompt = no
Disables interactive prompts — OpenSSL won’t ask you questions and will use values directly from the config file (good for automation).

[req_distinguished_name]
This section defines the Distinguished Name (DN) fields for the certificate subject:

CN = LENOVO-T480
The Common Name (CN) is the primary identifier for the certificate, often the hostname or machine name.
In your case, it’s set to your Windows machine's hostname LENOVO-T480.
This CN must match the hostname used by clients connecting to this server (e.g., WinRM connections).

[v3_req_combined]
This section contains the X.509 extensions applied to the certificate. Extensions specify certificate usage and additional identifiers.

keyUsage = digitalSignature, keyEncipherment
Defines how the certificate's key can be used:

digitalSignature allows the key to sign digital data (e.g., authentication)

keyEncipherment allows key to be used for encrypting keys during TLS handshake

extendedKeyUsage = serverAuth, clientAuth
Defines specific usage purposes beyond basic key usage:

serverAuth allows the cert to be used by servers (WinRM listener)

clientAuth allows the cert to be used by clients (Ansible control node authenticating)

subjectAltName = @alt_names
Specifies that the Subject Alternative Names (SANs) are listed in the [alt_names] section below.
SANs allow the certificate to specify valid DNS names, IP addresses, or other identities — modern TLS requires SAN for hostname validation.

[alt_names]
This section enumerates all the SAN entries included in the cert:

DNS.1 = LENOVO-T480
Adds the DNS name LENOVO-T480 as a valid identity for the cert.

IP.1 = <Your_IP_Address>
Adds the IP address <Your_IP_Address> as a valid identity.

otherName.1 = 1.3.6.1.4.1.311.20.2.3;UTF8:${USERNAME}@localhost
Adds an OtherName SAN entry:

The OID 1.3.6.1.4.1.311.20.2.3 is Microsoft-specific and used for User Principal Name (UPN).

This lets Windows map the certificate to a user account based on the UPN.

${USERNAME} is a shell variable, so when you generate the config dynamically, it will be replaced with your username (e.g., zachariah.mayfield@localhost).

Why is this important?
WinRM requires the certificate to have the correct EKU extensions (serverAuth for listener, clientAuth for client).

The CN and SAN entries must match the server hostname or IP address used to connect, or Windows will reject the cert.

The UPN SAN (otherName with OID 1.3.6.1.4.1.311.20.2.3) allows you to map the cert to a specific Windows user, enabling certificate-based authentication.

Summary:
Section	Purpose	Example Value
[req]	Configure openssl req behavior	Use DN section, extension section, no prompts
[req_distinguished_name]	Define certificate subject fields	CN = LENOVO-T480 (hostname)
[v3_req_combined]	Certificate extensions (key usage, EKU, SAN)	serverAuth, clientAuth, SAN refs
[alt_names]	Subject Alternative Names	DNS, IP, UPN (OtherName SAN)

Notes: 
# This command uses OpenSSL to:
# Generate a new private key (rsa:2048)
# Use that key to create a Certificate Signing Request (CSR), stored in $CSR_FILE
# Apply a custom extension section from your config (v3_req_combined)
# Line-by-Line Breakdown:
# openssl req --> This runs the OpenSSL X.509 certificate request utility.
# -new --> Tells OpenSSL to generate a new CSR.
# -sha256 --> Sets the hash algorithm used to sign the CSR to SHA-256.
# -newkey rsa:2048 --> Tells OpenSSL to generate a new RSA private key of 2048 bits, and use it to create the CSR.
# It creates: A new private key & A matching public key (embedded in the CSR)
# -nodes --> Means "no DES encryption" — do not encrypt the private key with a password.
# This is important in automation (e.g. Ansible), where you'd want the private key to be usable without interactive password prompts.
# -keyout "$KEY_FILE" --> Specifies where to save the new private key file.
# -out "$CSR_FILE" --> Specifies where to save the CSR file.
# The CSR ($CSR_FILE) contains: The public key & Subject (e.g. CN, SANs) & Requested certificate extensions (via -reqexts) & 
# It’s signed with the private key & You give the CSR to a CA (or self-sign it yourself later).
# -config "$CERT_CONFIG_FILE" --> Uses a custom OpenSSL config file to define: Subject info & Extensions (e.g. EKU, SAN) & Default key params.
# -reqexts v3_req_combined --> Applies the extension section [v3_req_combined] from the config during CSR creation.
# This section defines fields like: extendedKeyUsage: needed for WinRM (serverAuth, clientAuth) & 
# subjectAltName: required for modern TLS (e.g. IP or DNS match) & keyUsage: defines what the key can be used for.
# This is critical for WinRM to accept the cert.
openssl req \
    -new \
    -sha256 \
    -newkey rsa:2048 \
    -nodes \
    -keyout "$KEY_FILE" \
    -out "$CSR_FILE" \
    -config "$CERT_CONFIG_FILE" \
    -reqexts v3_req_combined

# This command takes the CSR and self-signs it (not using a separate CA), producing a valid X.509 certificate with all your desired extensions.
# Adds custom extensions from [v3_req_combined] (like serverAuth, SAN, etc.)
# You can then import this .pem on your Windows system, and use it in Ansible or WinRM setups.
# Line-by-Line Breakdown:
# openssl x509 --> Tells OpenSSL to work with X.509 certificates.
# This tool can: Create self-signed certificates from CSRs & Convert between PEM/DER formats & Inspect, modify, or verify certs.
# -req --> Indicates that the input file is a certificate signing request (CSR). Without this, OpenSSL assumes the input is already a certificate, not a CSR.
# -in "$CSR_FILE" --> Points to the CSR file that you want to sign. This file was generated earlier using openssl req, and it contains: 
# Subject (CN, SAN, etc.) & Public key & Optional extensions & Signature from the private key - You're about to sign this request using the private key.
# -sha256 --> Sets the hash algorithm used to sign the CSR to SHA-256.
# -out "$PEM_FILE" --> Specifies where to write the final self-signed certificate.
# This file (typically with .pem or .crt extension) is the public certificate you'll use for WinRM, HTTPS, etc.
# -days "$DAYS_VALID" --> Sets how long the certificate will be valid (e.g., 36500 = 100 years).
# -extfile "$CERT_CONFIG_FILE" --> Reads a config file to load X.509 extensions (like SAN, EKU, etc.).
# These extensions are not in the CSR by default, so you must explicitly apply them when signing.
# -extensions v3_req_combined --> Tells OpenSSL to use the [v3_req_combined] section from your config file.
# These are critical for usage in WinRM/HTTPS/TLS:
# serverAuth and clientAuth define usage in client-server scenarios.
# subjectAltName ensures hostname/IP validation works (required by most clients).
# -signkey "$KEY_FILE" --> Signs it using your private key ($KEY_FILE)
openssl x509 \
    -req \
    -in "$CSR_FILE" \
    -sha256 \
    -out "$PEM_FILE" \
    -days "$DAYS_VALID" \
    -extfile "$CERT_CONFIG_FILE" \
    -extensions v3_req_combined \
    -signkey "$KEY_FILE"

# Export PFX (PKCS#12 bundle)
# this command uses OpenSSL to bundle your certificate and private key into a .pfx / .p12 file, which is a PKCS#12 archive. 
# This format is commonly used on Windows for importing certificates into certificate stores like Personal or TrustedPeople.
# This command: Combines your certificate and private key into a single .pfx file & Stores it in a Windows-friendly format.
# Makes it easy to import into Windows certificate stores for WinRM and Ansible certificate auth.
# Line-by-Line Breakdown:
# openssl pkcs12 -export --> Tells OpenSSL to export a PKCS#12 (.pfx/.p12) file. PKCS#12 is a binary format that can include:
# The certificate & The private key & Intermediate CA certificates (optional). This format is used primarily by: 
# Windows (for import into the cert store) & Automation scripts like WinRM setup.
# -out "$PFX_FILE" --> Specifies the output file path for the .pfx or .p12 archive. This file will contain:
# Your certificate (.pem) & Your unencrypted private key (.key) & (Optionally) any additional CA/intermediate certs.
# -inkey "$KEY_FILE" --> Specifies the private key to include in the .pfx archive.
# This is the private key you created earlier with: -keyout "$KEY_FILE"
# It’s required because .pfx is meant to pair the certificate with its private key — 
# useful for systems that need full client authentication capabilities (like Windows + Ansible + WinRM).
# -in "$PEM_FILE" --> Specifies the certificate file to include in the archive.
# This is the .pem you created earlier: openssl x509 ... -out "$PEM_FILE" & It’s the public certificate corresponding to the private key.
# -passout pass: --> This defines the password used to encrypt the output .pfx file. pass: means you're passing the password inline.
# An empty password is defined here by simply giving pass: with nothing after it.
# This means the .pfx will be unencrypted, making it easier to import in automated scripts.
# The PFX file contains everything needed to authenticate as a client (private key + cert).
openssl pkcs12 -export \
    -out "$PFX_FILE" \
    -inkey "$KEY_FILE" \
    -in "$PEM_FILE" \
    -passout pass:
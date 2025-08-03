#!/bin/bash

set -e

# === Configuration ===
# Set the username to the name of the user the certificate will be mapped to
USERNAME="zachariah.mayfield"
CERT_NAME="${USERNAME}_Certificate"
CA_NAME="MyRootCA"
OUT_DIR="$HOME/GitHub/Main/Lenovo-T480/X_Secret"
CERT_CONFIG_FILE="${OUT_DIR}/cert_config.conf"
CSR_FILE="${OUT_DIR}/${CERT_NAME}.csr"
KEY_FILE="${OUT_DIR}/${CERT_NAME}.key"
PEM_FILE="${OUT_DIR}/${CERT_NAME}.pem"
PFX_FILE="${OUT_DIR}/${CERT_NAME}.pfx"
DAYS_VALID=36500

# === Create output directory if it doesn't exist ===
mkdir -p "$OUT_DIR"

# === Create OpenSSL config with EKU for Server Authentication ===
# This is explain in the ReadMe.
cat > "$CERT_CONFIG_FILE" <<EOF
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
IP.1 = 192.168.1.225
otherName.1 = 1.3.6.1.4.1.311.20.2.3;UTF8:${USERNAME}@localhost
EOF

# This command uses OpenSSL to:
# Generate a new private key (rsa:2048)
# Use that key to create a Certificate Signing Request (CSR), stored in $CSR_FILE
# Apply a custom extension section from your config (v3_req_combined)
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
# This command uses OpenSSL to bundle your certificate and private key into a .pfx / .p12 file, which is a PKCS#12 archive. 
# This format is commonly used on Windows for importing certificates into certificate stores like Personal or TrustedPeople.
# This command: Combines your certificate and private key into a single .pfx file & Stores it in a Windows-friendly format.
# Makes it easy to import into Windows certificate stores for WinRM and Ansible certificate auth.
openssl pkcs12 -export \
    -out "$PFX_FILE" \
    -inkey "$KEY_FILE" \
    -in "$PEM_FILE" \
    -passout pass:

# === SCP to Windows machine ===
WINDOWS_IP="192.168.1.225"
WINDOWS_DEST_PATH="/C:/Users/zachariah.mayfield/Downloads"

echo "Copying Certificate files to Windows..."
scp "$PEM_FILE" "$USERNAME@$WINDOWS_IP:$WINDOWS_DEST_PATH"
scp "$PFX_FILE" "$USERNAME@$WINDOWS_IP:$WINDOWS_DEST_PATH"
scp "$CSR_FILE" "$USERNAME@$WINDOWS_IP:$WINDOWS_DEST_PATH"
scp "$KEY_FILE" "$USERNAME@$WINDOWS_IP:$WINDOWS_DEST_PATH"
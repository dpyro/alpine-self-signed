#!/bin/sh

# Based on https://github.com/paulczar/omgwtfssl/blob/master/generate-certs
set -e

export SSL_DNS=$SSL_DNS
export SSL_IP=$SSL_IP
export SSL_SUBJECT=${SSL_SUBJECT:-"localhost"}

export CA_KEY=${CA_KEY-"ca-key.pem"}
export CA_CERT=${CA_CERT-"ca.pem"}
export CA_SUBJECT=${CA_SUBJECT:-"test-self-signed-ca"}
export CA_EXPIRE=${CA_EXPIRE:-"7"}

export SSL_CERT=${SSL_CERT:-"cert.pem"}
export SSL_CONFIG=${SSL_CONFIG:-"openssl.cnf"}
export SSL_CSR=${SSL_CSR:-"key.csr"}
export SSL_EXPIRE=${SSL_EXPIRE:-"7"}
export SSL_KEY=${SSL_KEY:-"key.pem"}
export SSL_SIZE=${SSL_SIZE:-"4096"}

echo "CA Key"
openssl genrsa -out "$CA_KEY" "$SSL_SIZE"
echo "CA Cert"
openssl req -x509 -new -nodes -key "$CA_KEY" -days "$CA_EXPIRE_DAYS" -subj "/CN=$CA_SUBJECT" > "$CA_CERT"

cat > "$SSL_CONFIG" <<-EOM
	[req]
	req_extentions = v3_req
	distinguished_name = req_distinguished_name
	[req_distinguished_name]
	[v3_req]
	basicConstraints = CA:FALSE
	keyUsage = nonRepudiation, digitalSignature, keyEncipherment
	extendedKeyUsage = clientAuth, serverAuth
EOM

if [ -n "$SSL_DNS" ] || [ -n "$SSL_IP" ]; then
	cat >> "$SSL_CONFIG" <<-EOM
	subjectAltName = @alt_names
	[alt_names]
	EOM
fi

if [ -n "$SSL_DNS" ]; then
	cat "DNS = $SSL_DNS" >> "$SSL_CONFIG"
fi

if [ -n "$SSL_IP" ]; then
	cat "IP = $SSL_IP" >> "$SSL_CONFIG"
fi

echo "Generating SSL Key"
openssl genrsa -out "$SSL_KEY" "$SSL_SIZE"

echo "Generating SSL CSR"
openssl req -new -key "$SSL_KEY" -subj "/CN=$SSL_SUBJECT" < "$SSL_CONFIG" > "$SSL_CSR" 

echo "Generating SSL Cert"
openssl x509 -req -in "$SSL_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial -out "$SSL_CERT" \
	-days "$SSL_EXPIRE" -extensions v3_req -extfile "$SSL_CONFIG"

echo "YAML Result:"
echo "---"
echo "ca_key: |"
sed 's/^/  /' < "$CA_KEY"
echo
echo "ca_crt: |"
sed 's/^/  /' < "$CA_CERT" 
echo
echo "ssl_key: |"
sed 's/^/  /' < "$SSL_KEY" 
echo
echo "ssl_csr: |"
sed 's/^/  /' < "$SSL_CSR" 
echo
echo "ssl_crt: |"
sed 's/^/  /' < "$SSL_CERT" 
echo

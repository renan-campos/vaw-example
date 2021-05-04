# Based on:
# https://medium.com/rungo/secure-https-servers-in-go-a783008b36da

PRIVATE_KEY="tls/server.key"
PUBLIC_KEY="tls/server.csa"
SELF_SIGNED_CERTIFICATE="tls/server.crt"
CA_PRIVATE="tls/ca.key"
CA_PUBLIC="tls/ca.crt"

# Create a local host signing request certificate:
if [ ! -f $PRIVATE_KEY ] || [ ! -f $SELF_SIGNED_CERTIFICATE ]
then
  echo "Need to create keys. Follow OpenSSL prompts:"
  # Generating CA
  openssl req -nodes -new -x509 -keyout $CA_PRIVATE -out $CA_PUBLIC -subj "/CN=Root CA"

  # Creating the private key, and a certificate signing request containing the public key
  openssl req -new -newkey rsa:2048 -nodes -keyout $PRIVATE_KEY -out $PUBLIC_KEY -subj "/CN=vaw-example.default.svc" -addext "subjectAltName=DNS:vaw-example.default.svc"

  # To create a self-signed certificate:
  openssl  x509 -in $PUBLIC_KEY -req -CA $CA_PUBLIC -CAkey $CA_PRIVATE -CAcreateserial -out $SELF_SIGNED_CERTIFICATE -extfile <(printf "subjectAltName=DNS:vaw-example.default.svc")

fi

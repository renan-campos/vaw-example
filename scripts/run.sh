# Based on:
# https://medium.com/rungo/secure-https-servers-in-go-a783008b36da

PRIVATE_KEY="tls/localhost.key"
PUBLIC_KEY="tls/localhost.csr"
SELF_SIGNED_CERTIFICATE="tls/localhost.crt"

# Create a local host signing request certificate:
if [ ! -f $PRIVATE_KEY ] || [ ! -f $SELF_SIGNED_CERTIFICATE ]
then
  echo "Need to create keys. Follow OpenSSL prompts:"
  # Creating the private key, and a certificate signing request containing the public key
  openssl req  -new  -newkey rsa:2048  -nodes  -keyout $PRIVATE_KEY  -out $PUBLIC_KEY

  # To create a self-signed certificate:
  openssl  x509  -req  -days 365  -in $PUBLIC_KEY  -signkey $PRIVATE_KEY  -out $SELF_SIGNED_CERTIFICATE

fi

# Run server:
echo "Running https server..."
go run server.go

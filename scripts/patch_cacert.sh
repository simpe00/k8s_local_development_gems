# Creates a CA and cert that azurite uses for https support
# It also patches certifi python module CA list to trust the custom CA 

PATH_VENV=../../venv
MKCERT_DIR="certs/azurite"
echo "###############"
if [ ! -e "$MKCERT_DIR" ]; then

    CERTIFI_CA_CERT=$(find $PATH_VENV -name cacert.pem | grep site-packages/certifi)
    if [ ! -e "$CERTIFI_CA_CERT" ]; then
        echo "cacert.pem of certifi python module was not found. Can not patch cacert.pem"
        exit 1
    fi

    echo "Creating certs at $MKCERT_DIR"
    mkdir -p $MKCERT_DIR
    export CAROOT=$MKCERT_DIR
    # mkcert -install
    mkcert -key-file $MKCERT_DIR/key.pem -cert-file $MKCERT_DIR/cert.pem 127.0.0.1 localhost azurite.default azurite.default.svc.cluster.local azurite-queue-127-0-0-1.nip.io warp10-api-127-0-0-1.nip.io

    echo "Patching cacert.pem of certifi python module"
    mkcert_ca="$(mkcert -CAROOT)/rootCA.pem"
    if grep -qFf "$mkcert_ca" "$CERTIFI_CA_CERT"; then
        echo >> $CERTIFI_CA_CERT
        echo "# Azurite custom CA" >> $CERTIFI_CA_CERT
        cat $mkcert_ca >> $CERTIFI_CA_CERT
    fi
else
    echo "Azurite certs can be found at $MKCERT_DIR"
    echo "Delete this directory if you want to regenerate the certs."
fi
echo "###############"
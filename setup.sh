# Install kind
# curl -Lo ./kind-bin https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
# chmod +x ./kind-bin
# sudo mv ./kind-bin /usr/local/bin/kind

# Install helm
# curl -fsSL https://get.helm.sh/helm-v3.11.0-linux-amd64.tar.gz | tar xz
# sudo mv linux-amd64/helm /usr/local/bin/helm

# Create a cluster
kind delete cluster --name gemini-k8s
kind create cluster --name gemini-k8s --config kind/kind-no-ssl.yaml

# Configure kubectl
kubectl config use-context kind-gemini-k8s

# Install fdb
kubectl apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/main/config/crd/bases/apps.foundationdb.org_foundationdbclusters.yaml
kubectl apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/main/config/crd/bases/apps.foundationdb.org_foundationdbbackups.yaml
kubectl apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/main/config/crd/bases/apps.foundationdb.org_foundationdbrestores.yaml
kubectl apply -f https://raw.githubusercontent.com/foundationdb/fdb-kubernetes-operator/main/config/samples/deployment.yaml
kubectl apply -f k8s/fdb-cluster.yaml

# Install warp10
# TODO: simplify with public image
docker build -t warp10-standaloneplus:1.0.1 ./docker
kind load docker-image warp10-standaloneplus:1.0.1 -n gemini-k8s
kubectl apply -f k8s/warp10-deploy.yaml 

# Azurite
# https://medium.com/@khuongntrd/emulating-azure-storage-with-azurite-on-kubernetes-7839c6352ed6
## Create cert and patch certifi module to make azure sdk work
# ./patch_cacert.sh
## Create secret from cert
# If you want to use storage explorer, copy certs/azurite/rootCA.pem to windows as .crt file and add it to trusted root certificate authorities
# https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&bc=%2Fazure%2Fstorage%2Fblobs%2Fbreadcrumb%2Ftoc.json&tabs=visual-studio%2Cblob-storage#import-certificate-to-storage-explorer
# Connection string for storage explorer: DefaultEndpointsProtocol=https;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=https://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=https://127.0.0.1:10001/devstoreaccount1;TableEndpoint=https://127.0.0.1:10002/devstoreaccount1;
# If you want to use this azurite with other python projects, manually append contents of certs/azurite/rootCA.pem to cacert.pem of certifi module, typically found at venv/lib/python3.8/site-packages/certifi/cacert.pem
# DefaultEndpointsProtocol=https;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;QueueEndpoint=https://azurite-queue-127-0-0-1.nip.io:32143/devstoreaccount1;
## Deploy azurite
kubectl apply -f k8s/azurite.yaml

# Install postgres
kubectl apply -f k8s/postgres.yaml

# Push docker images
kind load docker-image gemini-data-processing:17 -n gemini-k8s

# Add creds for azure data lake
kubectl apply -f datalake-creds.yaml

# Install nginx
## Create certs
mkdir -p certs
CAROOT=certs mkcert -key-file certs/key.pem -cert-file certs/cert.pem localhost 123.0.0.1 azurite-queue-127-0-0-1.nip.io warp10-api-127-0-0-1.nip.io
kubectl delete secret tls-cert
kubectl create secret tls tls-cert --key certs/key.pem --cert certs/cert.pem
## Install nginx
helm upgrade --install nginx oci://ghcr.io/nginxinc/charts/nginx-ingress --version 1.2.2 --set controller.hostPort.enable=true --set controller.hostPort.http=32080 --set controller.hostPort.https=32443
kubectl apply -f k8s/nginx-routes.yaml
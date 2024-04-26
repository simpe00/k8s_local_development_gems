#!/bin/bash

# Script is from: https://github.com/FoundationDB/fdb-kubernetes-operator/tree/main/kubectl-fdb#installation
# Adjustment for linux

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


TMPDIR=$SCRIPT_DIR
pushd $TMPDIR
if [ -f "$TMPDIR/kubectl-fdb-version.txt" ]; then
   rm "$TMPDIR/kubectl-fdb-version.txt"
fi
OS=$(uname)
ARCH=$(uname -m)

# ARCH
# Adjustment for linux
if [ ${OS} == "Linux" ]; then
  echo "Change OS to linux from ${OS}"
  OS="linux"
fi
if [ ${ARCH} == "x86_64" ]; then
  echo "Change arch to amd64 from ${ARCH}"
  ARCH="amd64"
fi

VERSION="$(curl -s "https://api.github.com/repos/FoundationDB/fdb-kubernetes-operator/releases/latest" | jq -r '.tag_name')"

curl -sLO "https://github.com/FoundationDB/fdb-kubernetes-operator/releases/download/${VERSION}/checksums.txt"
echo "https://github.com/FoundationDB/fdb-kubernetes-operator/releases/download/${VERSION}/kubectl-fdb_${VERSION}_${OS}_${ARCH}"
curl -sLO "https://github.com/FoundationDB/fdb-kubernetes-operator/releases/download/${VERSION}/kubectl-fdb_${VERSION}_${OS}_${ARCH}"
sha256sum --ignore-missing -c checksums.txt
chmod +x kubectl-fdb_${VERSION}_${OS}_${ARCH}
sudo mv ./kubectl-fdb_${VERSION}_${OS}_${ARCH} /usr/local/bin/kubectl-fdb
popd
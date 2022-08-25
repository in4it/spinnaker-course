#!/bin/bash

# install dependencies
sudo apt update
sudo apt-get -y install redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server

echo 'spinnaker.s3:
  versioning: false
' | sudo tee -a /home/spinnaker/.hal/default/profiles/front50-local.yml

# env flag that need to be set:
SPINNAKER_VERSION=1.28.1

set -e

if [ -z "${SPINNAKER_VERSION}" ] ; then
  echo "SPINNAKER_VERSION not set"
  exit
fi

sudo hal config version edit --version $SPINNAKER_VERSION

# fix https://github.com/spinnaker/spinnaker/issues/6428
echo 'install_helm() {
   wget https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get
   chmod +x get
-  bash -x ./get
+  bash -x ./get --version v2.17.0
   rm get
 }' > /var/lib/dpkg/info/spinnaker-rosco.postinst

sudo hal deploy apply

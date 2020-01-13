#!/bin/bash

# install dependencies
sudo apt update
sudo apt-get -y install redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server

echo 'spinnaker.s3:
  versioning: false
' > ~/.hal/default/profiles/front50-local.yml

# env flag that need to be set:
SPINNAKER_VERSION=1.17.5

set -e

if [ -z "${SPINNAKER_VERSION}" ] ; then
  echo "SPINNAKER_VERSION not set"
  exit
fi

sudo hal config version edit --version $SPINNAKER_VERSION

sudo hal deploy apply

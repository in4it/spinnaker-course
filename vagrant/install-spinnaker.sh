#!/bin/bash
SPINNAKER_VERSION=1.6.0
curl -Os https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh --user ubuntu
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker ubuntu
sudo docker run -p 127.0.0.1:9090:9000 -d --name minio1 -v /mnt/data:/data -v /mnt/config:/root/.minio minio/minio server /data

sudo apt-get -y install jq

MINIO_SECRET_KEY=`echo $(sudo docker exec minio1 cat /root/.minio/config.json) |jq -r '.credential.secretKey'`
MINIO_ACCESS_KEY=`echo $(sudo docker exec minio1 cat /root/.minio/config.json) |jq -r '.credential.accessKey'`
echo $MINIO_SECRET_KEY | hal config storage s3 edit --endpoint http://127.0.0.1:9090 \
    --access-key-id $MINIO_ACCESS_KEY \
    --secret-access-key

hal config storage edit --type s3

# env flag that need to be set:


set -e

if [ -z "${SPINNAKER_VERSION}" ] ; then
  echo "SPINNAKER_VERSION not set"
  exit
fi

sudo hal config version edit --version $SPINNAKER_VERSION
sudo hal deploy apply
sudo echo "host: 0.0.0.0" |sudo tee \
    /home/ubuntu/.hal/default/service-settings/gate.yml \
    /home/ubuntu/.hal/default/service-settings/deck.yml
sudo hal deploy apply
sudo systemctl daemon-reload
sudo hal deploy connect
printf " -------------------------------------------------------------- \n|     Connect here to spinnaker: http://192.168.33.10:9000/    |\n --------------------------------------------------------------"

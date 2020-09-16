#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo swapon /swapfile

sudo apt-get update
sudo apt-get -y install jq default-jdk

SPINNAKER_VERSION=1.17.5
curl -Os https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh --user ubuntu
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker ubuntu
sudo docker run -p 127.0.0.1:9090:9000 -d --name minio1 -v /mnt/data:/data -v /mnt/config:/root/.minio minio/minio:RELEASE.2018-07-31T02-11-47Z server /data

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
sudo hal config security api edit --cors-access-pattern "http://192.168.33.10:9000"
sudo hal config security ui edit --override-base-url http://192.168.33.10:9000
sudo hal config security api edit --override-base-url http://192.168.33.10:8084
sudo hal deploy apply
sudo systemctl daemon-reload
sudo hal deploy connect
sudo systemctl enable redis-server.service
sudo systemctl start redis-server.service
printf " -------------------------------------------------------------- \n|     Starting spinnaker, this can take several minutes        |\n --------------------------------------------------------------"
sleep 300 #needed to be sure everyting is started correctly 
printf " -------------------------------------------------------------- \n|     Connect here to spinnaker: http://192.168.33.10:9000/    |\n --------------------------------------------------------------"

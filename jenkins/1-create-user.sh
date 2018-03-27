#!/bin/bash

groupadd ubuntu
useradd -g ubuntu -G admin -s /bin/bash -d /home/ubuntu ubuntu
mkdir -p /home/ubuntu
cp -r /root/.ssh /home/ubuntu/.ssh
chown -R ubuntu:ubuntu /home/ubuntu
echo "ubuntu	ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

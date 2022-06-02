#!/bin/bash

wget https://github.com/deepfence/ThreatMapper/raw/master/deployment-scripts/docker-compose.yml
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker ${USER}
echo "Before newgrp"
newgrp docker <<EONG
echo "hello from within newgrp"
id
EONG
sudo sysctl -w vm.max_map_count=262144 
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
docker-compose --version
docker-compose -f docker-compose.yml up --detach
docker ps -a
hostname -I
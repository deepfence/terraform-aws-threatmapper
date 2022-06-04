#!/bin/bash

wget https://github.com/deepfence/ThreatMapper/raw/master/deployment-scripts/docker-compose.yml
sudo amazon-linux-extras install docker -y
sed -i 's/^OPTIONS=.*/OPTIONS=\"--default-ulimit nofile=1000029:1000029\"/' /etc/sysconfig/docker
sudo usermod -a -G docker ec2-user
echo "Before newgrp"
newgrp docker <<EONG
echo "hello from within newgrp"
id
EONG
sudo service docker start
sudo sysctl -w vm.max_map_count=262144 
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
docker-compose --version
docker-compose -f docker-compose.yml up --detach
docker ps -a
hostname -I
date +"%H:%M:%S"
sleep 2m 30s
if [[ $(docker-compose logs | grep -i error) ]]; then
    echo "check the below error logs in the threatmapper"
    docker-compose logs | grep -i error
else
    echo "no error logs found threatmapper should be up now"
fi
echo "start of docker container error logs"
date +"%H:%M:%S"
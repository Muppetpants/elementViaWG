#!/bin/bash

#Run as root
sleep 60
wget https://raw.githubusercontent.com/angristan/wireguard-install/refs/heads/master/wireguard-install.sh -O /root/wireguard-install.sh


apt install docker.io docker-compose -y
sleep 10
mkdir -p /root/Docker/Matrix_Synapse
cd /root/Docker/Matrix_Synapse
tee -a /root/Docker/Matrix_Synapse/docker-compose.yml << EOF
version: "3.3"

services:
    synapse:
        image: "matrixdotorg/synapse:latest"
        container_name: "matrix_synapse"
        ports:
            - 10.66.66.1:8008:8008
        volumes:
            - "./data:/data"
        environment:
            VIRTUAL_HOST: "matrix.chat.local"
            VIRTUAL_PORT: 8008
            LETSENCRYPT_HOST: "matrix.chat.local"
            SYNAPSE_SERVER_NAME: "matrix.chat.local"
            SYNAPSE_REPORT_STATS: "yes"

EOF

tee -a /root/READMEFIRST.txt << EOF
INSTALL INSTRUCTIONS
1. Install the wireguard server and create/download necessary client .confs:

sudo bash /root/wireguard-install.sh

Install the Matrix Server:

sudo bash /root/final.sh 

Finally, run docker ps -a to confirm container is running.

ELEMENT USAGE INSTRUCTIONS
To access the Element GUI, connect a client device to wireguard. Download and install the Element chat client.
Then, configure element to use an custom server at http://10.66.66.1:8008. Anyone with a wireguard client certificate
can register their own user name, create rooms, and chat with others on the VPN.
EOF

tee -a /root/final.sh << EOF

cd /root/Docker/Matrix_Synapse 

docker run -it --rm -v /root/Docker/Matrix_Synapse/data:/data -e SYNAPSE_SERVER_NAME=matrix.chat.local -e SYNAPSE_REPORT_STATS=yes matrixdotorg/synapse:latest generate
sleep 10
echo "#" >> /root/Docker/Matrix_Synapse/data/homeserver.yaml

echo "enable_registration: true" >> /root/Docker/Matrix_Synapse/data/homeserver.yaml

echo "enable_registration_without_verification: true" >> /root/Docker/Matrix_Synapse/data/homeserver.yaml

docker-compose up -d  
EOF

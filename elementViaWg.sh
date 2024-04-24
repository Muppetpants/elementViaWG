#!/bin/bash

#Run as root

wget https://raw.githubusercontent.com/Muppetpants/cleanWireguard/master/cleanWireguard-Install.sh -O /root/cleanWireguard-Install.sh


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

tee -a /root/README.txt << EOF
Now, install the wireguard server and create/download necessary client .confs:

bash /root/cleanWireguard-Install.sh

Then, run bash /root/final.sh to stand up the chat client.

Finally, run docker ps -a to confirm container is running. After running, connect client device to wireguard and, and configure element to use the server http://10.66.66.1:8008, or update hosts file to connect to http://matrix.chat.local:8008.


EOF

tee -a /root/final.sh << EOF

cd /root/Docker/Matrix_Synapse 

docker run -it --rm -v /root/Docker/Matrix_Synapse/data:/data -e SYNAPSE_SERVER_NAME=matrix.chat.local -e SYNAPSE_REPORT_STATS=yes matrixdotorg/synapse:latest generate
sleep 4
echo "#" >> /root/Docker/Matrix_Synapse/data/homeserver.yaml

echo "enable_registration: true" >> /root/Docker/Matrix_Synapse/data/homeserver.yaml

echo "enable_registration_without_verification: true" >> /root/Docker/Matrix_Synapse/data/homeserver.yaml

docker-compose up -d  
EOF

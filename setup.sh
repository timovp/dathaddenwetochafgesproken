#!/bin/bash
# change user/pass here
USER1=$(echo 'user1')
USER2=$(echo 'user2')
USER3=$(echo 'user3')
USER4=$(echo 'user4')
PASS1=$(echo 'user1')
PASS2=$(echo 'user2')
PASS3=$(echo 'user3')
PASS4=$(echo 'user4')
# sudo password to fix stuff on user accounts
SUDOPASS=$(echo 'sudopass')
# domain name, registered at digital ocean
DOMAINNAME=$(echo 'dathaddenwetochafgesproken.nl')

mkdir /root/docker
mkdir /root/docker/code-server-master
mkdir /root/docker/code-server-$USER1
mkdir /root/docker/code-server-$USER2
mkdir /root/docker/nginx-proxy-manager
mkdir /root/docker/code-server-master/custom-cont-init.d
mkdir /root/docker/code-server-$USER1/custom-cont-init.d
mkdir /root/docker/code-server-$USER2/custom-cont-init.d

mkdir /root/docker/code-server-master/workspace/
mkdir /root/docker/code-server-$USER1/workspace/
mkdir /root/docker/code-server-$USER2/workspace/

cp requirements.txt /root/docker/code-server-master/workspace/
cp requirements.txt /root/docker/code-server-$USER1/workspace/
cp requirements.txt /root/docker/code-server-$USER2/workspace/
echo 'version: "2.1"
services:
  code-server:
    image: linuxserver/code-server
    container_name: code-server-master
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - PASSWORD=master
      - SUDO_PASSWORD=master
      - PROXY_DOMAIN=vscode.'$DOMAINNAME' #optional
    volumes:
      - /root/docker/code-server-master:/config
      - /root/docker/code-server-'$USER1'/workspace:/config/workspace/'$USER1'
      - /root/docker/code-server-'$USER2'/workspace:/config/workspace/'$USER2'
    ports:
      - 8443:8443
    restart: unless-stopped

  code-server-'$USER1':
    image: linuxserver/code-server
    container_name: code-server-'$USER1'
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - PASSWORD='$PASS2'
      - SUDO_PASSWORD='$SUDOPASS'
      - PROXY_DOMAIN='$USER1'.'$DOMAINNAME' #optional
    volumes:
      - /root/docker/code-server-'$USER1':/config
    ports:
      - 8444:8443
    restart: unless-stopped

  code-server-'$USER2':
    image: linuxserver/code-server
    container_name: code-server-'$USER2'
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - PASSWORD='$PASS2'
      - SUDO_PASSWORD='$SUDOPASS'
      - PROXY_DOMAIN='$USER1'.'$DOMAINNAME' #optional
    volumes:
      - /root/docker/code-server-'$USER2':/config
    ports:
      - 8445:8443
    restart: unless-stopped

  nginx-proxy-manager:
    image: jlesage/nginx-proxy-manager
    build: .
    ports:
      - "8181:8181"
      - "80:8080"
      - "443:4443"
    volumes:
      - "/root/docker/nginx-proxy-manager:/config:rw"
    restart: unless-stopped' > /root/docker/docker-compose.yml
docker-compose -f /root/docker/docker-compose.yml up -d --remove-orphans --force-recreate
cp install_python /root/docker/code-server-master/custom-cont-init.d/
cp install_python /root/docker/code-server-$USER1/custom-cont-init.d/
cp install_python /root/docker/code-server-$USER2/custom-cont-init.d/
docker-compose -f /root/docker/docker-compose.yml restart

TOKEN=$(cat /root/token.txt)
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -d '{"type": "CNAME",
  "name": "'$USER1'",
  "data": "'$DOMAINNAME'.",
  "priority": null,
  "port": null,
  "ttl": 60,
  "weight": null,
  "flags": null,
  "tag": null}' "https://api.digitalocean.com/v2/domains/dathaddenwetochafgesproken.nl/records" 

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -d '{"type": "CNAME",
  "name": "'$USER2'",
  "data": "'$DOMAINNAME'.",
  "priority": null,
  "port": null,
  "ttl": 60,
  "weight": null,
  "flags": null,
  "tag": null}' "https://api.digitalocean.com/v2/domains/dathaddenwetochafgesproken.nl/records" 
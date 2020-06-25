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

mkdir ~/docker
mkdir ~/docker/code-server-master
mkdir ~/docker/code-server-$USER1
mkdir ~/docker/code-server-$USER2
mkdir ~/docker/nginx-proxy-manager
mkdir ~/docker/code-server-master/custom-init.d
mkdir ~/docker/code-server-$USER1/custom-init.d
mkdir ~/docker/code-server-$USER2/custom-init.d

mkdir ~/docker/code-server-master/workspace/
mkdir ~/docker/code-server-$USER1/workspace/
mkdir ~/docker/code-server-$USER2/workspace/

cp requirements.txt ~/docker/code-server-master/workspace/
cp requirements.txt ~/docker/code-server-$USER1/workspace/
cp requirements.txt ~/docker/code-server-$USER2/workspace/
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
      - ~/docker/code-server-master:/config
      - ~/docker/code-server-'$USER1'/workspace:/config/workspace/'$USER1'
      - ~/docker/code-server-'$USER2'/workspace:/config/workspace/'$USER2'
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
      - ~/docker/code-server-'$USER1':/config
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
      - ~/docker/code-server-'$USER2':/config
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
      - "~/docker/nginx-proxy-manager:/config:rw"
    restart: unless-stopped' > ~/docker/docker-compose.yml
docker-compose -f ~/docker/docker-compose.yml up -d --remove-orphans --force-recreate
cp install_python ~/docker/code-server-master/custom-init.d/
cp install_python ~/docker/code-server-$USER1/custom-init.d/
cp install_python ~/docker/code-server-$USER2/custom-init.d/
docker-compose -f ~/docker/docker-compose.yml restart

TOKEN=$(cat ~/token.txt)
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
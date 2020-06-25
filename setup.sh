#!/bin/bash
mkdir ~/docker
mkdir ~/docker/code-server-master
mkdir ~/docker/code-server-user1
mkdir ~/docker/code-server-user2
mkdir ~/docker/nginx-proxy-manager
cp -r nginx-proxy-manager ./nginx-proxy-manager
docker-compose up -d --remove-orphans --force-recreate

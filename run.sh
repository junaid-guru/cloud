#!/bin/bash

rm -rf ./docker-registry/auth/htpasswd
mkdir ./docker-registry/auth/htpasswd
docker run --rm   --entrypoint htpasswd httpd:2 -Bbn junaid {passowrd} > ./docker-registry/auth/htpasswd

docker network create --attachable proxy
envsubst < ./traefik-data/traefik.yml > ./traefik-data/traefik_rendered.yml
docker-compose down
docker-compose up

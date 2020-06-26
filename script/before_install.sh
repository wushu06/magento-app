#!/bin/bash
docker rm $(docker ps -a -f status=exited -q)

ROOT=/var/www/html/magento-app

if [ ! -d $ROOT/release ]; then
    mkdir -p $ROOT/release;
fi;
if [ ! -d $ROOT/aws ]; then
    mkdir -p $ROOT/aws;
fi;
sudo rm -rf $ROOT/release/*
\cp -Rf $ROOT/aws/* $ROOT/release
\cp -Rf $ROOT/shared/* $ROOT/release
chmod +x  $ROOT/release/script/*



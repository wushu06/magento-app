#!/bin/bash
docker rm $(docker ps -a -f status=exited -q)

ROOT=/var/www/html

if [ ! -d $ROOT/release ]; then
    echo 'creating release folder..'
    mkdir -p $ROOT/release;
fi;
if [ ! -d $ROOT/git ]; then
    echo 'creating git folder..'
    mkdir -p $ROOT/git;
fi;
sudo rm -rf $ROOT/release/*
\cp -Rf $ROOT/git/* $ROOT/release
\cp -Rf $ROOT/shared/auth.json $ROOT/release/auth.json
chmod +x  $ROOT/release/script/*



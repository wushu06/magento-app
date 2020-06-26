#!/bin/bash
# remove and past content to avoid container mapping issue
ROOT=/var/www/html/magento-app
rm -r $ROOT/src/*
\cp -Rf $ROOT/release/* $ROOT/src
chmod +x  $ROOT/src/script/*

APP_PATH=$ROOT/src/script
sh $APP_PATH/fixowns

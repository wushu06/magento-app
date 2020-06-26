#!/bin/bash
# remove and past content to avoid container mapping issue
rm -r /var/www/html/magento-app/src/*
\cp -Rf /var/www/html/magento-app/release/* /var/www/html/magento-app/src
chmod +x  /var/www/html/magento-app/src/script/*

APP_PATH='/var/www/html/magento-app/src/script'
sh $APP_PATH/fixowns

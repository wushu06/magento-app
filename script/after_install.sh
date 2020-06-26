#!/bin/bash

APP_PATH='/var/www/html/magento-app/release/script'

sh $APP_PATH/composer install
sh $APP_PATH/env
sh $APP_PATH/magento module:enable --all
sh $APP_PATH/magento setup:upgrade
sh $APP_PATH/magento setup:static-content:deploy -f
sh $APP_PATH/magento setup:di:compile


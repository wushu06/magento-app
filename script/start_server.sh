#!/bin/bash
# remove and past content to avoid container mapping issue
ROOT=/var/www/html
rm -r $ROOT/src/*
\cp -Rf $ROOT/release/* $ROOT/src
chmod +x  $ROOT/src/script/*

APP_PATH=$ROOT/src/script

rm /var/www/html/src/app/etc/env.php
sh $APP_PATH/cli ln -sf /var/www/html/shared/env.php /var/www/html/src/app/etc/env.php

sh $APP_PATH/fixowns

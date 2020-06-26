#!/bin/bash
ROOT=/var/www/html/magento-app

mkdir -p $ROOT/release
mkdir -p $ROOT/aws

\cp -Rf $ROOT/aws/* $ROOT/release
\cp -Rf $ROOT/shared/* $ROOT/release
chmod +x  $ROOT/release/script/*



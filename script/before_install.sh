#!/bin/bash
mkdir -p /var/www/html/magento-app/src/app/release
mkdir -p /var/www/html/magento-app/src/app/aws

\cp -Rf /var/www/html/magento-app/aws/* /var/www/html/magento-app/release
\cp -Rf /var/www/html/magento-app/shared/* /var/www/html/magento-app/release
chmod +x  /var/www/html/magento-app/release/script/*



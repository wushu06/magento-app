#!/bin/bash
mkdir -p /var/www/html/worked

cat <<EOF | sudo tee /var/www/html/worked/deploy.php
working fine.
EOF


#!/bin/bash

cd /tmp

# Download
curl -O -L https://download.civicrm.org/civicrm-5.9.1-drupal.tar.gz

# Extract
tar xzf civicrm-5.9.1-drupal.tar.gz

# Install
mv civicrm /var/www/html/sites/all/modules

# Cleanup
rm /tmp/civicrm-5.9.1-drupal.tar.gz

# Add dependency
/usr/local/bin/docker-php-ext-install mysqli

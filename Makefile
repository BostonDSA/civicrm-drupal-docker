build:
	curl -O -L https://download.civicrm.org/civicrm-${CIVICRM_VERSION}-drupal.tar.gz
	tar xzf civicrm-${CIVICRM_VERSION}-drupal.tar.gz
	mv civicrm /var/www/html/sites/all/modules
	rm civicrm-${CIVICRM_VERSION}-drupal.tar.gz
	/usr/local/bin/docker-php-ext-install mysqli

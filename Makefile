# Builds the docker image
build:
# Install some packages
	apt update
	apt install -y mysql-client # drush needs this

# Add Apache modules
	a2enmod ssl && service apache2 restart

# Install CiviCRM
	curl -O -L https://download.civicrm.org/civicrm-${CIVICRM_VERSION}-drupal.tar.gz
	tar xzf civicrm-${CIVICRM_VERSION}-drupal.tar.gz
	mv civicrm /var/www/html/sites/all/modules
	rm civicrm-${CIVICRM_VERSION}-drupal.tar.gz

# Install PHP dependencies
	/usr/local/bin/docker-php-ext-install mysqli

# Configure temporary directory
	mkdir -p /var/www/html/sites/default/files/civicrm
	chown -R www-data:www-data /var/www/html/sites/default
	chmod g+s /var/www/html/sites/default/files/civicrm

# Install drush (Drupal CLI)
	curl -O -L https://github.com/drush-ops/drush/releases/download/${DRUSH_VERSION}/drush.phar
	chmod +x drush.phar
	mv drush.phar /usr/local/bin/drush

# Install cv (CiviCRM CLI)
	curl -LsS https://download.civicrm.org/cv/cv.phar -o /usr/local/bin/cv
	chmod +x /usr/local/bin/cv

# Install SMTP
	drush pm-download smtp-7.x-1.7

# Creates the database tables for Drupal + CiviCRM
seed-db:
	drush site-install standard --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}/${MYSQL_DATABASE}
	cp /var/www/html/sites/default/civicrm.settings.php /var/www/html/sites/default/civicrm.settings.php.bak # backup
	drush civicrm-install
	cp /var/www/html/sites/default/civicrm.settings.php.bak /var/www/html/sites/default/civicrm.settings.php # restore
	drush php-script sites/default/add_civi_perms_to_admin.php

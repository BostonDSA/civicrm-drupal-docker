FROM drupal:7-apache

ENV CIVICRM_VERSION 5.9.1
ENV DRUSH_VERSION 8.2.3

# Other envars
# ENV MYSQL_DATABASE
# ENV MYSQL_USER
# ENV MYSQL_PASSWORD
# ENV MYSQL_HOST
# ENV MYSQL_PORT
# ENV DRUPAL_HASH_SALT

ADD Makefile Makefile
ADD docker/civicrm-drupal /var/www/html/sites/default

RUN make

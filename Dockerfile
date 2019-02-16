FROM drupal:7-apache
ENV CIVICRM_VERSION 5.9.1
ADD Makefile Makefile
RUN make

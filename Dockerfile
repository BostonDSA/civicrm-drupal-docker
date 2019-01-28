FROM drupal:7-apache
ADD install-civicrm.bash /tmp/install-civicrm.bash
RUN /bin/bash -c /tmp/install-civicrm.bash

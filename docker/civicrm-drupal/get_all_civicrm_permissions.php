<?php
# This output a concated string of all the civicrm permissions
echo implode("','", array_keys(module_invoke("civicrm", "permission")));

<?php
/**
 * This script will add all the CiviCRM permissions to the administrator role.
 */

$admin = user_role_load_by_name('administrator');
user_role_grant_permissions($admin->rid, array_keys(module_invoke("civicrm", "permission")));

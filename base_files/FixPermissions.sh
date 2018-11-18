#!/bin/bash
#script from Drupal.org site Permissions document
# https://drupal.org/node/244924
#
# MUST be run a s root if changing ownership of files
#
echo "Setting Permissions and Ownership on this Site"
chown -Rv francis:apache .
echo "Setting all directories to 755"
find . -type d -exec chmod u=rwx,g=rx,o=rx '{}' \;
echo "Setting all files to 644"
find . -type f -exec chmod u=rw,g=r,o=r '{}' \;
echo "Setting all directories below ./sites to 775 and files to 664"
chmod 777 sites/default/files
find sites -type d -name files -exec chmod ug=rwx,o=rx '{}' \;
for d in sites/default/files
do
   find $d -type d -exec chmod ug=rwx,o=rx '{}' \;
   find $d -type f -exec chmod ug=rw,o=rw '{}' \;
done
echo "Setting all config directories to 775 and files to 664"
chmod u=rx,g=rx,o=rx config
find config -type d -exec chmod ug=rwx,o=rx '{}' \;
find config -type f -exec chmod ug=rw,o=r '{}' \;
echo "force group and user for config/active files"
# to overcome group and user being set to francis when using drush to enable a module
chmod g+s config/active
chmod u+s config/active
chmod 777 sites/default/files
chmod 770 sites/default/files/private
echo "make sure Drush will work correctly"
chmod +x vendor/drush/drush/drush
chmod +x vendor/drush/drush/drush.launcher
echo "Setting settings.php and services.php file to 440"
chmod 440 sites/default/settings.php
chmod 440 sites/default/services.yml
chmod 440 .htaccess
chmod 444 sites/default/files/.htaccess
echo "Setting FixPermissions.sh to 750"
chmod 750 FixPermissions.sh


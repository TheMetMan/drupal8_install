#!/bin/bash
#script from Drupal.org site Permissions document
# https://drupal.org/node/244924
#
echo "Setting Permissions and Ownership on this Site. This can take a while ...."
find $apacheRoot/$siteFolder/ -type d -exec chmod u=rwx,g=rwx,o=rwx '{}' \;
chmod 666 "$apacheRoot/$siteFolder/sites/default/*"
chown -Rv USER:GROUP .
# for local site
# chown -Rv francis:www-data .
# for webfaction server
# chown -Rv themetman:themetman .
echo "Setting all directories to 755"
find . -type d -exec chmod u=rwx,g=rx,o=rx '{}' \;
echo "Setting all files to 644"
find . -type f -exec chmod u=rw,g=r,o=r '{}' \;
echo "Setting all directories below ./sites to 775 and files to 664"
find sites -type d -name files -exec chmod ug=rwx,o=rx '{}' \;
#chmod 777 ./sites/default/files
#chmod 777 -R ./sites/all
for d in sites/default/files
do
   find $d -type d -exec chmod ug=rwx,o=rx '{}' \;
   find $d -type f -exec chmod ug=rw,o=rw '{}' \;
done
echo "Setting files folder to 777"
chmod 777 -R sites/default/files
echo "Setting sites/default folder to 555"
chmod 555 sites/default
echo "Setting config folder to 777"
chmod 777 -R config
echo "Setting settings.php and services.yaml files to 444"
chmod 444 sites/default/s*.*
echo "Setting FixPermissions.sh to 750"
chmod 750 FixPermissions.sh


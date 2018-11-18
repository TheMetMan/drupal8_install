#!/bin/bash
#
# https://github.com/TheMetMan/drupal8_install 
# 
# This is the Install script for a Composer/Drush Install for LOCAL SITE ONLY
#
# script to create a Drupal site for File Based Workflow
# 
# The scripts, config file and base_files folder should be together
# perhaps in a folder such as ~/bin/drupal8 or some such
#
# make sure you have a MySql Database setup ready. Can be full or empty
#
# Edit the config.sh file with the correct information for your setup
# and run this script
#
# May  2017 Francis Greaves
# Nov  2018 Francis Greaves
#
askfg(){
  local REPLY
  while true; 
    do
        read -p "$1 [Y/n]" REPLY </dev/tty
        # Default is Y
        if [ -z "$REPLY" ]; then
          REPLY=Y
        fi
        # Check if the reply is valid
        case "$REPLY" in
          Y*|y*) return 0 ;;
          N*|n*) return 1 ;;
        esac
    done
}       # End of ask()
#
############ Import Config
configFile=config.cfg
if [ -e "$configFile" ]; then
  source $configFile
else
  echo "I cannot find the Config File $configFile"
  exit 1
fi
#-----------------------------------------------------------------------------
cd $apacheRoot
echo "----------- This is a Drupal Install using Composer and Drush ----------------"
echo "                Installing to $apacheRoot/$siteFolder"
echo "we would recommend only using this for the Local Install NOT Dev or Production"
echo "                Make sure you have a database setup already"
echo "=============================================================================="
if [ -d "$siteFolder" ]; then
  echo "**** The Old Site Folder is still present ****"
  echo "     you will need to remove this site."
  echo "  So as ROOT rm -fvr $apacheRoot/$siteFolder"
  echo "           then re-run this script"
  echo "Quitting Install Drupal 8 for File Based Workflow"
  exit 1
fi
if askfg "Do you really want to continue?" ; then
    echo "Installing now"
  else
    exit 1
  fi
echo 'Downloading Drupal ....'
  composer create-project drupal/drupal $siteFolder
  cd "$apacheRoot/$siteFolder"
  composer update
  composer require drush/drush:8.1.17
echo "create and copy .htaccess file to private folder"
mkdir -p sites/default/files/private
cp "$workingFolder/base_files/htaccess" sites/default/files/private/.htaccess
echo "create the other folders"
mkdir logs
mkdir -p config/sync
mkdir config/active
mkdir config/staging
mkdir config/sync-import
cp "$workingFolder/base_files/htaccess" config/.htaccess
echo "set temporary permissions on sites/default"
chmod 777 sites/default
chmod 666 sites/default/d*
chmod 777 sites/default/files
chmod 777 sites/default/files/private
echo 'Append Config Sync settings to default.settings.php file'
cat "$workingFolder/base_files/default.settings.xtra" >> ./sites/default/default.settings.php
cp ./sites/default/default.services.yml ./sites/default/services.yml
cat "$workingFolder/base_files/default.services.xtra" >> ./sites/default/services.yml
echo 'Install Site using Drush'
drush site-install standard \
--db-url="mysql://$dbUser:$dbPwd@localhost:3306/$db" \
--account-name=$acName \
--account-pass=$acPwd \
--account-mail=$acMail \
--site-name=$siteName \
--site-mail=$siteMail \
-y
echo
echo "copy useful files across and clean up a little"
cp "$workingFolder/base_files/FixPermissions.sh" ./
cp "$workingFolder/base_files/gitignore" ./.gitignore
rm example.gitignore
echo "adding Private Files Path and Trusted Hosts to settings.php file"
chmod 666 ./sites/default/settings.php
echo "\$settings['file_private_path'] = '$privatePath';" >> ./sites/default/settings.php
echo "\$settings['trusted_host_patterns'] = array('$trustedHosts',);" >> ./sites/default/settings.php 
echo "Updating FixPermissions.sh User and Group"
sed -i 's/USER/'$apacheUser'/' FixPermissions.sh
sed -i 's/GROUP/'$apacheGroup'/' FixPermissions.sh
echo "Fix Permissions on the site... This takes a little while...."
find "$apacheRoot/$siteFolder/" -type d -exec chmod u=rwx,g=rwx,o=rwx '{}' \;
chmod 666 "$apacheRoot/$siteFolder/sites/default/*"
echo "now run FixPermissions.sh as ROOT"
echo "then run drush updb and drush cr"
echo
echo "Copying a .gitignore file for you"
cp $workingFolder/base_files/gitignore .gitignore
echo
echo "You need to Create a git repository and commit"
echo
echo "The $siteName Site should now be up and running"
echo "so test it out and login to check the Reports->Status Report and tidy it up"
echo 
echo "There is more info regarding a git workflow at http://themetman.net/content/drupal-cms"
echo

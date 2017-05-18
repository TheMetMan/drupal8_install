#!/bin/bash
#
# https://github.com/TheMetMan/drupal8_install 
#
# script to create a Drupal site for File Based Workflow
# 
# The script, config files and base_files folder should be together
# perhaps in a folder such as ~/bin/drupal8 or some such
#
# make sure you have a MySql Database setup ready. Can be full or empty
#
# Edit the config.sh file with the correct information for your setup
# and run this script
#
# May 2017 Francis Greaves
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
############ Import Config
configFile=config.sh
if [ -e "$configFile" ]; then
  source $configFile
else
  echo "I cannot find the Config File $configFile"
  exit 1
fi
#-----------------------------------------------------------------------------
cd $apacheRoot
if [ -d "$siteFolder" ]; then
  echo "WARNING!!! you are about to DELETE the existing Site $siteFolder"
  echo "and Install Drupal 8 for File Based Workflow"
  if askfg "Do you really want to continue?"; then
    sudo rm -fvr $siteFolder > /dev/null 2>&1
  else
    echo "Quitting Install Drupal 8 for File Based Workflow"
    exit 1
  fi
fi
echo 'Downloading Drupal'
drush dl --drupal-project-rename=$siteFolder drupal
cd $apacheRoot/$siteFolder
mkdir -p sites/default/files/private
echo "copy .htaccess file to private folder"
cp $workingFolder/base_files/htaccess ./sites/default/files/private/.htaccess
mkdir logs
mkdir -p config/sync
mkdir config/active
mkdir config/staging
mkdir config/sync-import
chmod 777 sites/default
chmod 666 sites/default/*
echo 'Append Config Sync settings to default.settings.php file'
cat $workingFolder/base_files/default.settings.xtra >> sites/default/default.settings.php
cp sites/default/default.services.yml sites/default/services.yml
cat $workingFolder/base_files/default.services.xtra >> sites/default/services.yml
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
cp $workingFolder/base_files/FixPermissions.sh ./
cp $workingFolder/base_files/gitignore ./.gitignore
rm example.gitignore
echo "adding Private Files Path and Trusted Hosts to settings.php file"
chmod 666 sites/default/settings.php
echo "\$settings['file_private_path'] = '$privatePath';" >> sites/default/settings.php
echo "\$settings['trusted_host_patterns'] = array('$trustedHosts',);" >> sites/default/settings.php 
echo "Updating FixPermissions.sh User and Group"
sed -i 's/USER/'$apacheUser'/' FixPermissions.sh
sed -i 's/GROUP/'$apacheGroup'/' FixPermissions.sh
echo "Fix Permissions on the site... This takes a little while...."
sudo ./FixPermissions.sh > /dev/null 2>&1
echo "Create git repository and commit"
git init
git status
git add .
git commit -m "initial Comit for $siteFolder"  > /dev/null 2>&1
git status
drush updb
drush cr
echo
echo "The $siteName Site should now be up and running with a git repo initialised"
echo "so test it out and login to check the Reports->Status Report"

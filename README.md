# drupal8_install
Bash Script to install a new Drupal 8 site using Drush or Composer for File Based Workflow in a little over Three Minutes.
# Preamble
This project came from an attempt to develop a File Based Workflow for Drupal 8.
There are various methods out there, many using Composer. Unfortunately Composer is very memory hungry and would not run in our Hosting service with limited memory. We had to find a way to install a Drupal 8 site for File Based Workflow, but the method requires a particular order which we discovered by trial and error. So lots of Install, Rip Down and Start Again. Very time comsuming!!
We have found that installing Drupal 8 using Composer on the Local site, and then clone to Dev and Production sites to get the whole setup started works well.
Then make additions to modules and themes on the Local site, using Git to push/pull via a remote repo to Dev and Prod works well
We use Drush CMI Tools to update the sites. This will not work with Drush 9, so this install downgrades Drush to 8.1.17
This is why we developed this script which will Install a Drupal 8 Site to the location of your choice, and if the site exists it will replace it with a fresh one, and in only a little over three minutes.

# Requirements
This is for Linux Only. We have not considered Windows. It will probably work on a Mac, but we have not tested it.
You will need to have already installed Drush Version 8, Composer and Git globally.
You will also need a Virtual Host setup to match your site, and a database installed too.

# Usage
Place the script and the base_files folder in a location of your choice eg ~/bin/drupal8_local
Edit the config.sh file to put the correct variables for your location and site in place
Then make sure the createDrupalSite.sh script is executable

`chmod +x createDrupalSite.sh`

and execute like so:

`./createDrupalSite.sh`

Wait a little ......


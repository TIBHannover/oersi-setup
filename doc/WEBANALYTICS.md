# Analysis of the use of the Search Index

To get an overview of how the Search Index is used (e.g. number of visits in a period etc), an analysis of the Nginx Access Logs can be activated. For this purpose [Matomo](https://matomo.org) is installed and a cron job is set up to analyze the access logs once a day. The overview of the analysis can then be viewed in the Matomo-UI via the browser:

<http://192.168.98.115:8923/matomo> (set your host instead of the Vagrant-VM)

## Requirements

Already covered by the other rolls in oersi: Installation of MariaDB and Nginx.

## Configuration

* `matomo_install`: set to `true` to install Matomo
* `matomo_superuser_name`: Username of the Admin
* `matomo_superuser_password`: Password of the Admin
* `matomo_superuser_mail`: E-Mail of the Admin
* `matomo_dbname`: Name of the database for Matomo
* `matomo_dbuser`: User for access to the Matomo database
* `matomo_dbpassword`: Password of the database user

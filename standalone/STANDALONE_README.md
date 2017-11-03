# Standalone version setup

## Requirements:
 - Ubuntu 16.04 or newer (for server)
 - Docker 1.13.0 or newer (for container running machine)

**IMPORTANT**
**This operation requires sensitive data as real accounts name and passwords. That data is not sent anywhere else except your server and not gathered by ThinkMobiles company.**
**All credentials can be changed on server after project will be deployed.`**

## Application configuration
1. Clone project with command
```sh
git clone https://github.com/thinkmobiles/eqa eqa
```
2. Go to the `eqa` folder
```sh
cd eqa
```
3. Open file `standalone/ansible_provision/hosts` (which is [Ansible’s inventory file](http://docs.ansible.com/ansible/intro_inventory.html)) and set values.

 - **SERVER_IP** - your server ip address.
 - **APP_NAME** - this will serve as application folder name, application setings folder name, part of database name, database user name (`eqa` recomended).
 - **APP_DOMAIN** - your app domain for Phusion Passenger and Nginx server configuration (can be set as IP address).
 - **deploy_user** - system user for deploy which will be created on server (`value shouldn't be changed`).
 - **deploy_folder** - should be `/home/deploy/www/` (`value shouldn't be changed`).
 - **DEPLOY_USER_PASSWORD_PLAIN** - deploy user password in plain text.
 - **DEPLOY_USER_PASSWORD_SHA_512** - password for deploy_user, encrypted in md5.
The simplest way to ge it is to run in console next command
`mkpasswd --method=sha-512 DEPLOY_USER_PASSWORD_PLAIN`.
 - **GIT_HTTPS_USERNAME** - GitHub account name for cloning project
 - **GIT_HTTPS_PASSWORD** - GitHub account password for cloning project
 - **ROOT_PASSWORD** - server root account password
 - **SECRET_KEY_BASE** - 128 symbols sequence which serves for security porposes..
The simplest way to ge it is to run in console next command
`openssl rand -hex 64`
 - **SECRET_EMAIL** - email which will be used to send messages from application.
 - **SECRET_EMAIL_PASSWORD** - email password in plain text format
 - **ACTION_MAILER_ADDRESS** - email server domain
 - **ACTION_MAILER_SDOMAIN** - email server subdomain
 - **DEVISE_EMAIL** - email which will be in "From" field when you will restore your account (may be the same as SECRET_EMAIL).
 - **DEVISE_SECRET_KEY** - anothe 128 symbols sequence which serves for security porposes.
The simplest way to ge it is to run in console next command
`openssl rand -hex 64`
 - **ssl_sertificate_present** - must be true or false.
 - **CERTIFICATE_FILE_ABSOLUTE_PATH** - absolute path to certificate file.
 - **KEY_FILE_ABSOLUTE_PATH** - absolute path to key file.
 - **MONIT_WEB_LOGIN** - login for Monit web interface
 - **MONIT_WEB_PASSWD** - password for Monit web interface
 - **backup=true** - allows **[Backup](https://github.com/backup/backup)** instalation for easily perform backup operations. **false** disable **[Backup](https://github.com/backup/backup)** instalation. By default backups stored locally. Feel free to configure it for your needs.


## Server setup:
 - in **/etc/ssh/sshd_config**
    set `PermitRootLogin yes`
    set `PasswordAuthentication yes`
 - **restart sshd service** with command
```sh
service sshd restart
```
 - root password on server and ROOT_PASSWORD in `standalone/ansible_provision/hosts` file must be equal
 - put **SSL** certificate files on server and set **CERTIFICATE_FILE_ABSOLUTE_PATH** **KEY_FILE_ABSOLUTE_PATH** in `hosts` file.

Provision run
```sh
docker build -t eqa .
docker run -it eqa
```

After all scripts finish opening your app in browser (visit ip address or application URL).

To remove unnecessary Docker data from machine use commands:
```sh
docker rm $(docker ps -a -q)
docker rm $(docker images -q)
```

# Updating standalone version

## Application configuration
1. Clone project with command
```sh
git clone https://github.com/thinkmobiles/eqa eqa
```
2. Go to the `eqa` folder
```sh
cd eqa
```
3. Open file `standalone/ansible_provision/hosts` and set values.
 - **SERVER_IP** - your server ip address.
 - **DEPLOY_USER_PASSWORD_PLAIN** - deploy user password in plain text.
 - **ROOT_PASSWORD** - server root account password

## Updating
1. Execute next bash commands:
```sh
docker build -t updater -f standalone/updater/Dockerfile .
docker run -it updater
```

To remove unnecessary Docker containers execute:
```sh
docker rm $(docker ps -aq)
```

Pay attention !!!
Standalone provision adds additional ssh keys to your server.
You can make copies of authorized_keys and known_hosts files before standalone provision and updates and remove them after provision and updates.

**[Monit](https://mmonit.com/monit/)** is used for process monitoring. Feel free to configure it for your needs.

**[Backup](https://github.com/backup/backup)** is used for database backup.
Database backups are enabled by default (copies are stored locally).
You can setup backups in some other way if you need or add additional settings (backup notifications for example).
Backup log is located here `/home/deploy/Backup/cron_backup.log`
**[Backup](https://github.com/backup/backup)** version is hardcoded for 4.4.0.
Backup log file max size is set to 10MB.
You can change it manually editing `/home/deploy/www/eqa/backups/config.rb`.

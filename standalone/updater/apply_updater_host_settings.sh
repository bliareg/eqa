#!/bin/bash

echo '###################################################################'
echo 'running standalone/updater/apply_updater_host_settings.sh'
echo '###################################################################'

# WORKDIR /eqa
echo 'Applying hosts file settings'

ip_adress=$(grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" ./standalone/updater/hosts)
echo "server ip: $ip_adress"

# ######## ./standalone/updater/ssh_server_root_expect.sh
sed -i "s/REMOTE_SERVER_IP/$ip_adress/g" ./standalone/updater/ssh_server_root_expect.sh

##############################################################################
# sed
  # -i всі операції проходять в одному файлі без -і потрібен проміжний файл
##############################################################################

root_password=$(grep -E "^root_password.*$" ./standalone/updater/hosts)
root_password=${root_password:14}
echo "got root_password" # remove
echo "$root_password" # remove
sed -i "s/ROOT_PASSWORD/$root_password/g" ./standalone/updater/ssh_server_root_expect.sh
# ######## ./standalone/updater/ssh_server_root_expect.sh

# ######## ./standalone/updater/ssh_server_deploy_expect.sh
sed -i "s/REMOTE_SERVER_IP/$ip_adress/g" ./standalone/updater/ssh_server_deploy_expect.sh

user_password_plain=$(grep -E "^user_password_plain.*$" ./standalone/ansible_provision/hosts)
user_password_plain=${user_password_plain:20}
echo "got user_password_plain" # remove
echo "$user_password_plain" # remove
sed -i "s/USER_PASSWORD_PLAIN/$user_password_plain/g" ./standalone/updater/ssh_server_deploy_expect.sh
# ######## ./standalone/updater/ssh_server_deploy_expect.sh

chmod +x ./standalone/updater/ssh_server*_expect.sh

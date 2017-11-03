#!/bin/bash

# WORKDIR /eqa
echo 'Applying hosts file settings'

ip_adress=$(grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" ./standalone/ansible_provision/hosts)
echo "server ip: $ip_adress"

# ######## ./standalone/ssh_server_root_expect.sh
sed -i "s/REMOTE_SERVER_IP/$ip_adress/g" ./standalone/ssh_server_root_expect.sh

root_password=$(grep -E "^root_password.*$" ./standalone/ansible_provision/hosts)
root_password=${root_password:14}
echo "got root_password"
echo "$root_password"
sed -i "s/ROOT_PASSWORD/$root_password/g" ./standalone/ssh_server_root_expect.sh
# ######## ./standalone/ssh_server_root_expect.sh

# ######## ./standalone/ssh_server_deploy_expect.sh
sed -i "s/REMOTE_SERVER_IP/$ip_adress/g" ./standalone/ssh_server_deploy_expect.sh

user_password_plain=$(grep -E "^user_password_plain.*$" ./standalone/ansible_provision/hosts)
user_password_plain=${user_password_plain:20}
echo "got user_password_plain"
echo "$user_password_plain"
sed -i "s/USER_PASSWORD_PLAIN/$user_password_plain/g" ./standalone/ssh_server_deploy_expect.sh
# ######## ./standalone/ssh_server_deploy_expect.sh

chmod +x ./standalone/ssh_server*_expect.sh

# ######## ./config/deploy/standalone.rb
sed -i "s/REMOTE_SERVER_IP/$ip_adress/g" ./config/deploy/standalone.rb

deploy_user=$(grep -E "^deploy_user.*$" ./standalone/ansible_provision/hosts)
deploy_user=${deploy_user:12}
echo "got deploy_user"
echo "$deploy_user"
sed -i "s/DEPLOY_USER/$deploy_user/g" ./config/deploy/standalone.rb

git_https_username=$(grep -E "^git_https_username.*$" ./standalone/ansible_provision/hosts)
git_https_username=${git_https_username:19}
echo "got git_https_username"
echo "$git_https_username"
sed -i "s/GIT_HTTPS_USERNAME/$git_https_username/g" ./config/deploy/standalone.rb

git_https_password=$(grep -E "^git_https_password.*$" ./standalone/ansible_provision/hosts)
git_https_password=${git_https_password:19}
echo "got git_https_password"
echo "$git_https_password"
sed -i "s/GIT_HTTPS_PASSWORD/$git_https_password/g" ./config/deploy/standalone.rb
# ######## ./config/deploy/standalone.rb

# ######## ./standalone/ansible_provision/roles/linked_files/templates/secrets.yml
secret_key_base=$(grep -E "^secret_key_base.*$" ./standalone/ansible_provision/hosts)
secret_key_base=${secret_key_base:16}
echo "got secret_key_base"
echo "$secret_key_base"
sed -i "s/SECRET_KEY_BASE/$secret_key_base/g" ./standalone/ansible_provision/roles/linked_files/templates/secrets.yml
# ######## ./standalone/ansible_provision/roles/linked_files/templates/secrets.yml

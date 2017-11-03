#!/bin/bash

# WORKDIR /eqa

echo '###################################################################'
echo 'running standalone/updater/setup_standalone_updater.sh'
echo '###################################################################'

./standalone/updater/apply_updater_host_settings.sh

# setup container ssh connection
echo 'setup container ssh connection'
echo '==========================================================='
ssh-keygen -b 2048 -t rsa -f ~/.ssh/updater_container -q -N ''
eval `ssh-agent -s`
ssh-add ~/.ssh/updater_container

echo '###################################################################'
echo 'running standalone/updater/ssh_server_root_expect.sh'
echo '###################################################################'
./standalone/updater/ssh_server_root_expect.sh
echo '==========================================================='

echo '###################################################################'
echo 'running standalone/updater/ssh_server_deploy_expect.sh'
echo '###################################################################'
ssh-keygen -b 2048 -t rsa -f ~/.ssh/user_deploy -q -N ''
/eqa/standalone/updater/ssh_server_deploy_expect.sh
echo '==========================================================='

bundle install

# deploy project to server
cap standalone deploy

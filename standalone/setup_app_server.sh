#!/bin/bash

cp config/sidekiq.yml standalone/ansible_provision/roles/linked_files/templates/sidekiq.yml
mkdir -p /etc/ansible/
cp standalone/files/ansible.cfg /etc/ansible/.

# WORKDIR /eqa
./standalone/apply_host_settings.sh

ssh-keygen -b 2048 -t rsa -f ~/.ssh/provision_container -q -N ''

eval `ssh-agent -s`
ssh-add ~/.ssh/provision_container

./standalone/ssh_server_root_expect.sh

./standalone/ansible_provision/setup_standalone.sh

#!/bin/sh

ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/python.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/setup_user.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/install_all_necessary_software.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/add_swap_file.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/setup_nginx_and_passenger.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/install_redis.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/install_ruby_with_rbenv.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/install_postgre.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/prepare_deploy.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/configure_nginx_for_app.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/copy_linked_files.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/install_bundler.yml
ansible-playbook -i standalone/ansible_provision/hosts standalone/ansible_provision/set_nginx_rbenv_ruby.yml

ssh-keygen -b 2048 -t rsa -f ~/.ssh/user_deploy -q -N ''
/eqa/standalone/ssh_server_deploy_expect.sh

bundle install

cap standalone deploy

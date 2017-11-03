#!/bin/bash

mkdir -p /root/.ssh/
ssh-keygen -b 2048 -t rsa -f ~/.ssh/provision_container -q -N ''
# sshpass -p "c6b91b1048de668d" ssh -o StrictHostKeyChecking=no root@46.101.133.230
sshpass -p "62b30d50f5ef540b" ssh-copy-id -i ~/.ssh/provision_container.pub root@46.101.116.74
# ssh -o StrictHostKeyChecking=no root@46.101.133.230

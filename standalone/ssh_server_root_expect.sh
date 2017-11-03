#!/usr/bin/expect

spawn ssh-copy-id -i /root/.ssh/provision_container.pub -o PreferredAuthentications=password -o PubkeyAuthentication=no -o StrictHostKeyChecking=no root@REMOTE_SERVER_IP
expect "root@REMOTE_SERVER_IP's password: "
send "ROOT_PASSWORD\n";
interact


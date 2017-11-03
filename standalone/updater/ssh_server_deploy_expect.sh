#!/usr/bin/expect

spawn ssh-copy-id -i /root/.ssh/user_deploy.pub -o PreferredAuthentications=password -o PubkeyAuthentication=no -o StrictHostKeyChecking=no deploy@REMOTE_SERVER_IP
expect "deploy@REMOTE_SERVER_IP's password: "
send "USER_PASSWORD_PLAIN\n";
interact


#!/usr/bin/env bash
#
# author: albedo
# email: albedo@foxmail.com
# date: 20190613
# usage: for upload git dir
#

function auto_input(){
expect <<-EOF
spawn git push orgin master
expect "Username" { send "albedo@foxmail.com\r"}
expect "Password" { send "$1\r"}
expect eof
EOF
}


read -s -p "Password: " password
git add .
git commit -m "shell_init"
#git remote add orgin https://github.com/albe-fox/shell_initialize.git
#git push -u orgin master
if [ ! -f /usr/bin/expect ];then
	yum -y install expect
fi
auto_input $password

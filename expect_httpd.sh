#!/usr/bin/env bash
#
# author: oldfox
# email: albedo@foxmail.com
# date: 20190613
# usage: 实现自动登录远程主机并安装httpd
#
function create_keygen(){
expect <<-EOF
spain ssh-keygen
ecpect ':' { send "\r" }
expect ":" { send "\r" }
expect eof
EOF
}
function transfer_ssh(){
##传入两个参数，1是ip，2是密码
expect <<-EOF
spain ssh-copy-id root@$1
expect "*yes/no" { send "yes\r" }
expect "*password" { send "$2\r" }
expect eof
EOF
}
if [ ! -f /usr/bin/expect ];then
	yum -y install expect	
fi
if [ ! -f $HOME/.ssh/id_rsa ];then
	create_keygen
fi
transfer_ssh 10.0.111.99 "123"

#!/usr/bin/env bash
#
# author: albedo
# email: albedo@foxmail.com
# date: 20190613
# usage: 实现自动登录远程主机并安装httpd
#
function create_keygen(){
expect <<-EOF
spawn ssh-keygen
expect ":" { send "\r" }
expect ":" { send "\r" }
expect ":" { send "\r" }
expect eof
EOF
}
function transfer_ssh(){
ip=$1
pawd=$2
##传入两个参数，1是ip，2是密码
expect <<-EOF
spawn ssh-copy-id root@$ip
#expect "*yes*" { send "yes\r" }
expect "*password*" { send "$pawd\r" }
expect eof
EOF
}
##main
if [ ! -f /usr/bin/expect ];then
	yum -y install expect	
fi
if [ ! -f $HOME/.ssh/id_rsa ];then
	create_keygen
fi
for i in `cat ip.txt`
do
ip=`echo $i | awk -F":" '{print $1}'`
passwd=`echo $i | awk -F":" '{print $2}'`
transfer_ssh $ip $passwd
ssh root@$ip "yum -y install httpd"
done


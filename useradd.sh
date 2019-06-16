#!/usr/bin/env bash
#
# author: albedo
# email: albedo@foxmail.com
# date: 20190613
# usage: adduser

#1
read -p "UserName: " name
read -p "Password: " password
if [ -z $name ];then
	echo "please!!!"
	exit 100000
fi
useradd $name
if [ -z $password ];then
	echo ‘123456’ | passwd --stdin $name
else
	echo $password | passwd --stdin $name
fi

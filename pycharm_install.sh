#!/usr/bin/env bash
#
# author: albedo
# email: albedo@foxmail.com
# date: 20190614
# usage: deploy pycharm
#
wget https://download.jetbrains.8686c.com/python/pycharm-community-2019.1.3.tar.gz
tar xf pycharm-community-2019.1.3.tar.gz
if [ ! -d /opt ];then
	mkdir /opt
fi
yum -y install java-latest-openjdk.x86_64
mv pycharm-community-2019.1.3 /opt/
cd /opt/pycharm-community-2019.1.3/bin
#需要graphics environment，图形化环境
./pycharm.sh

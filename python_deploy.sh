#!/usr/bin/env bash
#
# author: albedo
# albedo@foxmai.com
# date: 20190614
# usage: deploy python3.7
#
yum -y groupinstall "Development Tools"
yum -y install zlib-devel bzip2-devel openssl-devel sqlite-devel readline-devel libffi-devel
wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz
if [ ! -d /opt ];then
	mkdir /opt/
fi
tar xf Python-3.7.2.tgz -C /opt/
cd /opt/Python-3.7.2/
sed -ire '/readline.c /#/d' Modules/Setup.dist
sed -ire '/ssl/ /#/d' Modules/Setup.dist
./configure --enable-share 
make -j `lscpu | awk 'NR==4{print $2}'`
make install
echo "\/usr\/local\/lib" >>/etc/ld.so.conf.d/python3.conf
source /etc/profile
ldconfig

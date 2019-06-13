#!/usr/bin/env bash
#
#author:OldFox
#email:albedo@foxmail.com
#date:2019/05/30
#usage:install wordpress in LNMP
#

function intall_nginx(){

}


function install_php(){

}

function install_mysql(){

}

function install_wordpress(){
wget https://wordpress.org/latest.tar.gz &>/dev/null
if [ ! $? -eq 0 ];then
	echo "下载包失败，请自行准备包"	
	exit
fi
tar xf latest.tar.gz -C ./
mkdir /www.test.com.bak
mv /usr/share/nginx/html/* /www.test.com.bak/
mv ./wordpress/* /usr/share/nginx/html/

echo "创建数据库"
systemctl start mysqld
mysql --login-path=orginal -e "create database wordpress"

echo "准备配置文件"
cp /usr/share/nginx/html/{wp-config-sample.php,wp-config.php}
sed -i 's/database_name_here/wordpress/' /usr/share/nginx/html/wp-config.php
sed -i 's/username_here/root/' /usr/share/nginx/html/wp-config.php
sed -i 's/password_here/123/' /usr/share/nginx/html/wp-config.php
}

##main


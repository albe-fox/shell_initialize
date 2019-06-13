#!/usr/bin/env bash
#
#author:OldFox
#email:albedo@foxmail.com
#date:2019/05/30
#usage:install wordpress in LNMP
#

function intall_nginx(){
rpm -qa | grep nginx
if [ $? -eq 0 ];then
	yum -y remove nginx
fi
if [ ! -f /etc/yum.repos.d/nginx.repo ];then
        rm -rf /etc/yum.repos.d/nginx.repo
fi
#yum install apr --nogpgcheck
echo <<-EOF >>/etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
EOF
yum -y install nginx
systemctl restart nginx && systemctl enable nginx
#隐藏默认版本号

#nginx支持php的必要配置
sed -ri "s/index.html/index.php index.html/g" /etc/nginx/conf.d/default.conf
sed -ire "29,36 s/#\(.*\)/\1/g" /etc/nginx/conf.d/default.conf
sed -ire "s/\/scripts/\$Document_Root/g" /etc/nginx/conf.d/default.conf
sed -ri "31 s/html/\/usr\/share\/nginx\/html/" /etc/nginx/conf.d/default.conf
systemctl restart nginx
}


function install_php(){
rpm -qa | grep php &>/dev/null
if [ $? -eq 0 ];then
	yum -y remove php*
fi
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum -y install php70w php70w-opcache php70w-xml php70w-mcrypt php70w-gd php70w-devel php70w-mysql php70w-intl php70w-mbstring php70w-fpm
systemctl restart php-fpm && systemctl enable php-fpm
}

function install_mysql(){
#wget ftp://10.0.111.99/mysql-5.7.26.bin.tar.xz
##sh mysq-sourcecode-linstall.sh
yum -y groupinstall "Development Tools"
wget https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
rpm -ivh mysql80-community-release-el7-1.noarch.rpm
#修改安装mysql的yum源文件,把安装5.7的源打开, 关闭安装8.0的源
sed -ire '21 s/0/1/' /etc/yum.repos.d/mysql-community.repo
sed -ire '28 s/1/0/' /etc/yum.repos.d/mysql-community.repo
yum -y install mysql-community-server
systemctl start mysqld && systemctl enable mysqld
echo "skip-grant-tables" >>/etc/my.cnf
systemctl restart mysqld
mysql -e "use mysql ; update user set authentication_string=password('123') where user='root'"
sed -ire '/skip-grant/ s/\(.*\)/#\1/' /etc/my.cnf
systemctl restart mysqld
create_login_path '123'
}
function create_login_path(){
expect <<-EOF
spawn mysql_config_editor set --login-path=orginal --host=localhost --user='root' -p
expect "password" { send "$1\r"}
expect eof
EOF
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
mysql --login-path=orginal -e "create database if not exists wordpress"

echo "准备配置文件"
cp /usr/share/nginx/html/{wp-config-sample.php,wp-config.php}
sed -i 's/database_name_here/wordpress/' /usr/share/nginx/html/wp-config.php
sed -i 's/username_here/root/' /usr/share/nginx/html/wp-config.php
sed -i 's/password_here/123/' /usr/share/nginx/html/wp-config.php
}

##main
sed -ri s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
systemctl stop firewalld && systemctl disable firewalld
install_mysql
install_php
install_nginx
install_wordpress

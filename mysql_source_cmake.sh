#!/usr/bin/env bash
#
# author: oldfox
# email: albedo@foxmail.com
# date: 20190615
# usage: make install mysql_5.7.26
#
###所需要的依赖及安装mysql的包
yum -y update
yum -y groupinstall "Development Tools"
yum -y install ncurses ncurses-devel bison libgcrypt perl make cmake
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-5.7.26.tar.gz
#在系统中添加运行mysqld进程的用户mysql
groupadd mysql
useradd -M -s /sbin/nologin -g mysql mysql
##在系统中添加自定义mysql数据库目录及其他必要目录,便于打包
mkdir -p /usr/local/mysqld/{data,mysql,log,tmp}
chown -R mysql:mysql /usr/local/mysqld/*

##将mysql-boost-5.7.24.tar.gz解压到当前目录,并执行部署操作
tar xf mysql-boost-5.7.26.tar.gz
cd mysql-5.7.26
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysqld/mysql \
-DMYSQL_DATADIR=/usr/local/mysqld/data \
-DWITH_BOOST=/root/mysql-5.7.26/boost \
-DDEFAULT_CHARSET=utf8 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \		#数据库引擎
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \	
-DENABLE_DTRACE=0 \
-DDEFAULT_CHARSET=utf8 \	# 使用utf-8编码
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EMBEDDED_SERVER=1	
make -j `lscpu | awk 'NR==4{ print $2 }'`
make install
echo "export PATH=\$PATH:/usr/local/mysqld/mysql/bin" >>/etc/profile
source /etc/profile
chown -R mysql.mysql /usr/local/mysqld/*

mv /etc/{my.cnf,my.cnf.bak}
cat <<-EOF  >>/etc/my.cnf
[client]
socket = /usr/local/mysqld/tmp/mysql.sock

[mysqld]
basedir = /usr/local/mysqld/mysql
datadir = /usr/local/mysqld/data
tmpdir = /usr/local/mysqld/tmp
socket = /usr/local/mysqld/tmp/mysql.sock
pid_file = /usr/local/mysqld/tmp/mysqld.pid
log_error = /usr/local/mysqld/log/mysql_error.log
##慢查询日志
slow_query_log_file = /usr/local/mysqld/log/slow_warn.log

server_id = 145 
user = mysql
port = 3306
bind-address = 0.0.0.0   ## 接收访问的地址
character-set-server = utf8
default_storage_engine = InnoDB
EOF

mysqld --defaults-file=/etc/my.cnf --initialize --user='mysql'
mysqld_safe --defaults-file=/etc/my.cnf &
cp /usr/local/mysqld/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
tmppwd=`grep "password" /usr/local/mysqld/log/mysql_error.log | awk -F': ' '{print $2}'`
mysql -uroot -p"$tmppwd" -e "alter user 'root'@localhost identified by '123'"






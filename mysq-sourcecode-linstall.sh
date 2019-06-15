#!/usr/bin/env bash
#
#author:OldFox
#email:965846709@qq.com
#date:20190528
#usage:installmysql

#设置serverid和随机更改uuid
function unique_server(){
ip=`ip a | grep inet | awk -F'[ /]+' 'NR==3{print $3}'`
id=`echo $ip | awk -F'.' '{print $4}'`
sed -ire '% s/^\(server_id\).*/\1 = $id/g' /etc/my.cnf
ranuuid=`openssl rand -hex 2`
sed -ire "/uuid/ s/....$/$ranuuid/g" /usr/local/mysqld/data/auto.cnf
}
#获取源码编译包
wget ftp://10.0.111.99/mysql-5.7.26.bin.tar.xz
echo "解压到usrlocal下"
tar xf /root/mysql-5.7.26.bin.tar.xz -C /usr/local    #wait
if [ $? -eq  0 ];then
        echo "解压成功"
else
        echo "解压失败"
        exit
fi
echo "添加用户及组"
id mysql &>>/dev/null
if [ $? -ne 0 ];then
        groupadd mysql
        useradd -M -g mysql -s /sbin/nologin mysql
else
        echo "mysql已存在"
fi
chown -R mysql:mysql /usr/local/mysqld/*

echo "修改配置文件"
mv /etc/{my.cnf,my.cnf.bak}
cp -R /usr/local/mysqld/my.cnf /etc/my.cnf

echo "添加开机自启动"
ln -s /usr/local/mysqld/mysql/support-files/mysql.server /etc/init.d/mysqld
ln -s /usr/local/mysqld/mysql/support-files/mysql.server /usr/bin/mysqlctl
chkconfig --add mysqld
chkconfig mysqld on

echo "修改环境变量"
echo "export PATH=\$PATH:/usr/local/mysqld/mysql/bin" >>/etc/profile
source /etc/profile

echo "启动mysqld"
echo "skip-grant-tables" >>/etc/my.cnf
unique_server
systemctl start mysqld
mysql -e "use mysql ; update user set authentication_string=password('123') where user='root'"
sed -ire '/skip-grant/ s/\(.*\)/#\1/' /etc/my.cnf
systemctl restart mysqld




#!/usr/bin/env bash
#
# author: oldfox
# email: albedo@foxmail.com
# date: 20190613
# usage: initialize for project
#

function create_login_path(){
expect <<-EOF
spawn mysql_config_editor set --login-path=orginal --host=localhost --user='root' -p
expect "password" { send "$1\r"}
expect eof
EOF
}
function edit_mysql(){
	mysql --login-path=orginal -e $1
}

##main
read -s -p "MysqlPassword: " password
create_login_path $password
edit_mysql  "create database if not exists project charset='utf8';"
edit_mysql  "use project;create table account( id bigint not null primary key auto_increment=100000,username varchar(50) not null unique,password varchar(100),balance int default 100,updatetime timestamp default current_timestamp on update current_timestamp);create table record( id bigint not null primary key auto_increment,uname varchar(50),foreign key(uname) references account(username),changerecord int,balance  int default 100,createtime datetime  default current_timestamp );"


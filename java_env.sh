#!/usr/bin/env bash
#
# author: albedo
# email: albedo@foxmail.com
# date: 20190614
# usage: deploy jdk
#

java_version=$( java --version | awk -F'[ .]+' 'NR==1{ print $2}')
if [ ! -z $java_version ];then
        if [ $java_version -lt 9 ];then
                yum -y remove java*
		yum -y install java-latest-openjdk.x86_64
        fi
else
	yum -y install java-latest-openjdk.x86_64
fi

#set java environment
cat <<-EOF  >>/etc/profile
JAVA_HOME=/usr/lib/jvm/java-12-openjdk-12.0.1.12-1.rolling.el7.x86_64
JRE_HOME=\$JAVA_HOME/jre
CLASS_PATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib
PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH
EOF
source /etc/profile
env | grep -i java

#!/usr/bin/env bash


tar -xf zookeeper-3.4.14.tar.gz  -C /opt/
mkdir -p /data/zookeeper/{data,logs}
echo "
export ZOOKEEPER_HOME=/opt/zookeeper-3.4.14
export PATH=\$ZOOKEEPER_HOME/bin:\$PATH" >>/etc/profile
source /etc/profile
mv /opt/zookeeper-3.4.14/conf/{zoo_sample.cfg,zoo_sample.cfg.bak}
echo "
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/zookeeper/data
dataLogDir=/zookeeper/logs
clientPort=2181
server.1=elk-1:2888:3888
server.2=elk-2:2888:3888
server.3=elk-3:2888:3888 " >/opt/zookeeper-3.4.14/conf/zoo.cfg
echo $num >/data/zookeeper/data/myid
/opt/zookeeper-3.4.14/bin/zkServer.sh start

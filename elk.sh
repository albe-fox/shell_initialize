#!/usr/bin/env bash
#
# author: albedo
# date: 20190718
# usage: temporary install of filebeat+kafka+ELK
#

systemctl stop firewalld
systemctl disable  firewalld
setenforce 0
sed -ire 's/^\(SELINUX=\).*$/\1DISABLED/g' /etc/selinux/config

echo "安装java.."
yum -y install vim wget &>/dev/null
yum -y install java-1.8.0-openjdk.x86_64 &>/dev/null
if [ $? -ne 0 ];then
	echo "Java安装失败，请检查网络"
fi

num=`echo $HOSTNAME | grep -o '[0-9]'`


echo "192.168.128.142 elk1
192.168.128.200 elk2
192.168.128.136 elk3" >> /etc/hosts

echo "下载文件..."
wget ftp://10.0.111.244/ELK/*

function beat_install(){
rpm -ivh filebeat-7.2.0-x86_64.rpm
sed -ire 's/\(reload\.enabled:[ ]*\)true$/\1false/g' /etc/filebeat/filebeat.yml
sed -ire '/^output.elasticsearch/ s/^\(.*$\)/#\1/g' /etc/filebeat/filebeat.yml
sed -ire '/9200/ s/^\(.*$\)/#\1/g' /etc/filebeat/filebeat.yml
sed -ire 's/\(^[ ]*enabled:[ ]*\)false$/\1true/' /etc/filebeat/filebeat.yml
sed -ire 's/\(\/var\/log\/\).*$/\1messages/' /etc/filebeat/filebeat.yml
echo "
output.kafka:
  hosts: [\"elk-1:9092\"]
  topic: \"filebeat\"
  codec.json:
    pretty: false " >> /etc/filebeat/filebeat.yml
}
function es_install(){
tar -xf elasticsearch-7.2.0-linux-x86_64.tar.gz -C /opt/
if ! id elk 
then
useradd elk
fi
mkdir -p /data/elk/{data,logs}
chown -R elk.elk /opt/
echo "
cluster.name: elk
node.name: node-$num
path.data: /data/elk/data
path.logs: /data/elk/logs
bootstrap.memory_lock: false
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: [\"elk1\",\"elk2\",\"elk3\"]
cluster.initial_master_nodes: [\"node-$num\"] " >>/opt/elasticsearch-7.2.0/config/elasticsearch.yml
echo "
* soft nofile 65536   
* hard nofile 131072
* soft nproc 2048
* hard nproc 4096 " >>/etc/security/limits.conf
echo "vm.max_map_count=262144" > /etc/sysctl.conf
nohup runuser -l elk -c '/opt/elasticsearch-7.2.0/bin/elasticsearch' &
}

function ls_install(){
tar -xf logstash-7.2.0.tar.gz -C /opt/
echo "
input {
  kafka {
    bootstrap_servers => \"elk-$num:9092\"
    topics => [\"filebeat\"]
    codec => json
  }
}

output {
  if [@metadata][pipeline] {
    elasticsearch {
      hosts => \"http://localhost:9200\"
      manage_template => false
      index => \"system-elk$num-%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}\"
      pipeline => \"%{[@metadata][pipeline]}\"
    }
  } else {
    elasticsearch {
      hosts => \"http://localhost:9200\"
      manage_template => false
      index => \"system-elk$num%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}\"
    }
  }
}" >/opt/logstash-7.2.0/config/logstash_kafka.conf

nohup /opt/logstash-7.2.0/bin/logstash -f /opt/logstash-7.2.0/config/logstash_kafka.conf &
}

function kib_install(){
tar -xf kibana-7.2.0-linux-x86_64.tar.gz  -C /opt/
echo "
server.port: 5601
server.host: 0.0.0.0
elasticsearch.hosts: [\"http://elk1:9200\"] ">>/opt/kibana-7.2.0-linux-x86_64/config/kibana.yml
nohup /opt/kibana-7.2.0-linux-x86_64/bin/kibana --allow-root &
}

function kaf_install(){
tar -xf kafka_2.12-2.3.0.tgz -C /opt/
mkdir -p /kafka/logs
chmod -R 777 /kafka
sed -ire "s/\(broker.id=\)0/\1$((num-1))/g" /opt/kafka_2.12-2.3.0/config/server.properties
sed -ire "/#listeners=PLAINTEXT:\/\/:9092/ a\listeners=PLAINTEXT:\/\/elk-$num:9092" /opt/kafka_2.12-2.3.0/config/server.properties
sed -ire 's/\(zookeeper.connect=\)localhost:2181/\1elk-1:2181,elk-2:2181,elk-3:2181/g' /opt/kafka_2.12-2.3.0/config/server.properties
nohup /opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh /opt/kafka_2.12-2.3.0/config/server.properties &
}

es_install
if [ $? -ne 0 ];then
	echo "elasticsearch安装启动失败"
fi
ls_install
if [ $? -ne 0 ];then
         echo "logstash安装启动失败"
fi
kaf_install
if [ $? -ne 0 ];then
         echo "kafka安装启动失败"
fi
beat_install
if [ $? -ne 0 ];then
         echo "filebeat安装启动失败"
fi

if [ "$num" = "1" ];then
	kib_install
fi





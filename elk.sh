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
wget ftp://10.0.111.244/ELK/* &>/dev/null

function beat_install(){
echo "安装filebeat"
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
systemctl start filebeat
systemctl enable filebeat
}
function es_install(){
echo "安装elasticsearch"
tar -xf elasticsearch-7.2.0-linux-x86_64.tar.gz -C /opt/
if ! id elk &>/dev/null
then
useradd elk
fi
mkdir -p /data/elk/{data,logs}
chown -R elk.elk /data/elk/
chown -R elk.elk /opt/elasticsearch-7.2.0/
echo "
cluster.name: elk
node.name: node-$num
path.data: /data/elk/data
path.logs: /data/elk/logs
bootstrap.memory_lock: false
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: [\"elk1\",\"elk2\",\"elk3\"]
cluster.initial_master_nodes: [\"node-1\"] " >>/opt/elasticsearch-7.2.0/config/elasticsearch.yml
echo "
* soft nofile 65536   
* hard nofile 131072
* soft nproc 2048
* hard nproc 4096 " >>/etc/security/limits.conf
echo "vm.max_map_count=262144" > /etc/sysctl.conf
sysctl -p &>/dev/null
nohup runuser -l elk -c '/opt/elasticsearch-7.2.0/bin/elasticsearch' &

if [ $? -ne 0 ];then
        return 2
fi
}

function ls_install(){
echo "安装logstash"
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
if [ $? -ne 0 ];then
	return 2
fi
}

function kib_install(){
echo "安装kibana"
tar -xf kibana-7.2.0-linux-x86_64.tar.gz  -C /opt/
echo "
server.port: 5601
server.host: 0.0.0.0
elasticsearch.hosts: [\"http://elk1:9200\"] ">>/opt/kibana-7.2.0-linux-x86_64/config/kibana.yml
nohup /opt/kibana-7.2.0-linux-x86_64/bin/kibana --allow-root &
if [ $? -ne 0 ];then
        return 2
fi
}

function kaf_install(){
echo "安装kafka"
tar -xf kafka_2.12-2.3.0.tgz -C /opt/
mkdir -p /kafka/logs
chmod -R 777 /kafka
sed -ire "s/\(broker.id=\)0/\1$((num-1))/g" /opt/kafka_2.12-2.3.0/config/server.properties
sed -ire "/#listeners=PLAINTEXT:\/\/:9092/ a\listeners=PLAINTEXT:\/\/elk-$num:9092" /opt/kafka_2.12-2.3.0/config/server.properties
sed -ire 's/\(zookeeper.connect=\)localhost:2181/\1elk-1:2181,elk-2:2181,elk-3:2181/g' /opt/kafka_2.12-2.3.0/config/server.properties
nohup /opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh /opt/kafka_2.12-2.3.0/config/server.properties &
if [ $? -ne 0 ];then
        return 2
fi
}

function zoo_install(){
echo "安装zookeeper"
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
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/logs
clientPort=2181
server.1=elk-1:2888:3888
server.2=elk-2:2888:3888
server.3=elk-3:2888:3888 " >/opt/zookeeper-3.4.14/conf/zoo.cfg
echo $num >/data/zookeeper/data/myid
/opt/zookeeper-3.4.14/bin/zkServer.sh start
if [ $? -ne 0 ];then
	echo "zook启动失败"
        return 2
fi
}

###main
es_install 
if [ $? -ne 0 ];then
	echo "elasticsearch安装启动失败"
fi
ls_install
if [ $? -ne 0 ];then
         echo "logstash安装启动失败"
fi
zoo_install
if [ $? -ne 0 ];then
        echo "zookeeper安装失败"
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

sleep 5
array=("elasticsearch" "logstash" "kibana" "kafka" "zookeeper" "filebeat")
len=${#array[*]}
for i in $(seq 0 $((len-1)) )
do
        n=$(ps aux | grep ${array[$i]} | wc -l)
        if [ "$((n-1))" = "0" ];then
                echo "${array[$i]}安装失败"
        else
                echo "${array[$i]}安装成功"
        fi
done


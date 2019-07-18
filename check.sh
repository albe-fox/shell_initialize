#!/usr/bin/env bash
# author: abledo
# date: 20190718


array=("elasticsearch" "logstash" "kibana" "kafka" "zookeeper" "filebeat")
len=${#array[*]}
for i in $(seq 0 $((len-1)) )
do
        n=$(ps aux | grep ${array[$i]} | wc -l)
        if [ "$((n-1))" = "0" ];then
                echo "${array[$i]}安装失败失败失败失败"
        else
                echo "${array[$i]}安装成功"
        fi
done


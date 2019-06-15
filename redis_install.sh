#!/usr/bin/env bash
#
# author: oldfox
# email: albedo@foxmail.com
# date: 20190615
# usage: install redis
#
wget http://download.redis.io/releases/redis-5.0.4.tar.gz
tar xf redis-5.0.4.tar -C /opt/
cd /opt/redis-5.0.4/
make -j `lscpu | awk 'NR==4{print $2}'`
cd src/
make install
mkdir -p /usr/local/redis/{bin,conf}
cp /opt/redis-5.0.4/redis.conf /usr/local/redis/conf/
cd /opt/redis-5.0.4/src/
cp mkreleasehdr.sh redis-benchmark redis-check-aof redis-cli redis-server redis-sentinel /usr/local/redis/bin/
sed -ri s/"daemonize no"/"daemonize yes"/g /usr/local/redis/conf/redis.conf


#!/usr/bin/env bash
#
# author: albedo
# email: albedo@foxmail.com
# date: 20190617
# usage: monitoring cpu,memory,disk 
#
function warining_mail(){
Mail="albedo@foxmail.com"
Date=`date +%F" "%r`
ip=`ip a | awk -F"[ /]+" 'NR==9{print $3}'`
date=$DATE
echo '''
Date: $Date
Host: $ip
Problem: $1 utilization $2%
'''| mail -s "warning" $Mail
}
function moni_cpu(){
cpu_used=$(vmstat | awk 'NR==3{print$13+$14}')

if [ $cpu_used -gt 70 ];then
	warning_mail "cpu" $cpu_used
fi
}
function moni_mem(){
mem_used=$(free -m | awk 'NR==2{print ($2-$4)/$2*100}')
if [ $mem_used -gt 85 ];then
	warnning_mail "memory" $mem_used%
fi
}
function moni_disk(){
disk_used=$(df -Th| awk 'NR==2{print $6}')
disk_tmp=`echo $disk_used | awk -F"%" '{print $1}'`
if [ $disk_tmp -gt 90 ];then
	wairning_mail "disk" $disk_used
fi
}
function moni_crontab(){
crontab -l | grep monitoring_system.sh  &>/dev/null
if [ $? -ne 0 ];then
	cp -R ./$1 /tmp/
	echo "*/1 * * * * /tmp/$1" >>/var/spool/cron/root
else 
	sed -ire '49 s/\(\.*\)/#\1/' /tmp/$1
fi 
}
#####main
moni_crontab $0
moni_cpu
moni_mem
moni_disk




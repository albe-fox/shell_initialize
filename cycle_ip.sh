
#!/usr/bin/env bash
#
# author: albedo
# email: albedo@foxmail.com
# date: 20190613
# usage: ping ip use while cycle
#
ip=10.0.111.
for i in $(seq 2 254)
do
{
        ping $ip$i -c1 -i0 &>/dev/null
        if [ $? -eq 0 ];then
		echo "$ip$i is ok"
	else
		echo "$ip$i is down"		
	fi
}&
done 
#n=2
#while ((n<255))
#do
#	ping $ip$n -c1 -i0 $>/dev/null
#	 if [ $? -eq 0 ];then
#                echo "$ip$n is ok"
#        else
#                echo "$ip$n is down"            
#        fi
#	let n++
#done

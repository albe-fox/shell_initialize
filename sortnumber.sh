#!/usr/bin/env bash
#
# author: oldfox
# email: albedo@foxmail.com
# date: 20190613
# usage: 输入三个数并进行升序排序
#

read -p "number: " num1
read -p "number: " num2
read -p "number: " num3
read -p "number: " num4

array=($num1 $num2 $num3 $num4)
len=${#array[*]}
for i in $(seq 0 $len)
do
	for j in $(seq $i $len)
	do
		let a=${array[$i]}+1
		let b=${array[$j]}+1
		if [ $a -gt $b ];then		
#		if [ ${array[$i]} -gt ${array[$j]} ];then
			tmp=${array[$i]}
			array[$i]=${array[$j]}
			array[$j]=$tmp

		fi
	done

done
for i in $(seq 0 $len)
do
	echo ${array[$i]}
done

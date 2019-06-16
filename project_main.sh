#!/usr/bin/env bash
# 
# author: albedo
# email: albedo@firefox.com
# date: 20190605
# usage: achieve 
#
startmenu() {
cat <<-EOF
    +-----------------------+
    |         lomenu        |
    +-----------------------+
    +        1,register     |
    +-----------------------+
    +       2,login        |
    +-----------------------+
    +      3,quit           |
    +-----------------------+
EOF
}

topmenu() {
cat <<-EOF
    +----------------------------------------+
    +               topmenu                  +
    +----------------------------------------+
    +       1,Checking account balance       +
    +----------------------------------------+
    +       2,Re-charge                      +
    +----------------------------------------+
    +       3,spend                          +
    +----------------------------------------+
    +       4,back to startmenu              +
    +----------------------------------------+
    +       5,quit                           +
    +----------------------------------------+
EOF
}
select_userinfo(){
	#第一个参数name，得出结果用户名密码和余额
	name_pwd_ba=`mysql --login-path=test -e "select username,password,balance from project.account where username='$1'" | awk 'NR==2{print $1,$2,$3}' `
	echo $name_pwd_ba
}
insert_userinfo(){
	#传入两个参数，用户名和密码，写入数据库
	mysql --login-path=test -e "insert into project.account (username,password) values ('$1','$2');" 
}
insert_recharge(){
	#三个参数，用户名，余额，充值或者消费金额
	#更改用户信息，添加订单信息
	mysql --login-path=test -e "insert into project.record (uname,balance,changerecord) values ('$1','$2','$3');update project.account set balance=('$2') where username='$1';" 
}
register(){
flag=0
while ((flag==0))
do
    read -p "please in put your name: " name
    name_password_balance=`select_userinfo $name`
    echo $name_password_balance | grep -E "^$"
    if [ $? -ne 0 ];then
        echo "用户名已存在，请重新输入" 

    else
	echo "这个用户名可用"
        flag2=0
        while ((flag2==0))
        do
            read -s -p "please input your password:" pwd01
		echo ""
            read -s -p "please confirm your password:" pwd02
		echo ""
            if [ "$pwd01" =  "$pwd02" ];then
                pwd=$pwd01
                flag2=1
		mysql --login-path=test -e "insert into project.account (username,password) values ('$name','$pwd');" 
       		 if [ $? -eq 0 ];then
                	echo "注册成功"
                	flag=1
       		 else
        	        echo "写入失败，请重新输入"             
	        fi
	    else
		echo "两次密码不一样哦老弟"
            fi
        done
    fi
done
}
userlogin(){

	flag=0
	while ((flag==0))
	do
		read -p "please input your name :" name
		echo ""
		read -s -p "please input your password: " password
		echo ""
		name_password_balance=`select_userinfo $name`
		echo $name_password_balance | grep -E "^$"
		if [ $? -eq 0 ];then
			echo "此用户不存在，请重新输入"
		else
			tmppwd=`echo $name_password_balance | awk '{print $2}'`
			if [ "$tmppwd" != "$password" ];then
				echo "用户名输入错误，请重新输入"
			else
				echo "登录成功"
				flag2=0
				while ((flag2==0))
				do
					tmpbalance=`select_userinfo $name | awk '{print $3}'`					
					topmenu
					read -p "please input your choice:" choice
					case $choice in
						1)
							
							echo "你的余额是$tmpbalance"
							;;

						2)
							read -p "please input your charge: " charge
							if [ $((charge % 50)) -ne 0 ];then
								echo "充值的金额必须是50的倍数"
							else
								let sum=$charge+$tmpbalance
								insert_recharge $name $sum $charge
							fi
							;;
						3)	
							read -p "please input you want to spend:" spend
							let sum2=$tmpbalance-$spend
							if [ $sum2 -lt 0 ];then
								echo "余额不足,请重新输入"
							else
								let tmpspend=-$spend
								insert_recharge $name $sum2 $tmpspend
							fi	
							;;						
						4)	
							let flag=1
							;;
						5)
							exit
							;;
						*)
							echo "Please !!"
					esac
				done
			fi
		fi	
	done
}
#########################
#### main ###-==========================================================================

while :
do
startmenu
read -p "please inpput your choice " choice
case $choice in
    1)
        register
        ;;
    2)
        userlogin
        ;;
    3)
        exit
        ;;
    *)
        echo "please repeat your input"
esac
done

#!/usr/bin/env bash
#
# author: albedo
# email: alebdo@foxmail.com
# date: 20190617
# usage: config mailx
#
yum -y install mailx
cat <<-EOF >>/etc/mail.rc
set from=albedofox@163.com
set smtp=smtp.163.com
set smtp-auth-user=albedofox
set smtp-auth-password=
set smtp-auth=login
EOF

#!/usr/bin/env bash
#
# author: albedo
# email: alebdo@foxmail.com
# date: 20190617
# usage: config mailx
#
yum -y install mailx
cat <<-EOF >>/etc/mail.rc
set from=albedo@foxmail.com
set smtp=
set smtp-auth-user=albedo@foxmail.com
set smtp-auth-password=
set smtp-auth=login
EOF

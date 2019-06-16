#!/usr/bin/env bash
#
# author: albedo
# email: albedo@foxmail.com
# date: 20190615
# usage: intall packages for make install
#
yum -y groupinstall "Development Tools"
yum -y install gcc make zlib-devel pcre pcre-devel openssl-devel  ncurses-devel git gcc-c++ libxml2-devel

+++
title = "鲲鹏"
date =  2021-04-16T10:35:44+08:00
description= "鲲鹏机器"
weight = 5
+++

## 镜像构建：


安装虚拟机： [QEMU](https://www.qemu.org/download/)

运行docker： https://github.com/multiarch/qemu-user-static

## node_exporter
手动安装

下载arm64 node_exporter，其它安装配置同x86

## k3s
手动安装

安装同x86的rpm包
需要替换k3s和image，

修改启动： k3s.service

改用fannel作为网络插件

## 应用镜像构建

产出目录： hub.dns.360.cn

## 安装

需要注意修改 配置文件 中的镜像名；

license初始化修改grafana地址等


## clickhouse 

coredump

https://github.com/ClickHouse/ClickHouse/issues/18121
https://github.com/ClickHouse/ClickHouse/issues/20


最终是由版本： hub.dns.360.cn/library/clickhouse-arm64:20.3.19.4
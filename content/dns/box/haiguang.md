+++
title = "海光麒麟机器安装"
date =  2021-03-22T14:52:20+08:00
description= "海光麒麟机器安装"
weight = 5
+++

1、配置文件参数修改

```shell
# 禁用下载检查
pandora_enable_download: false
pandora_k3s_disable_manager_nic: true
enable_kernel_task: false
```

需要手动执行磁盘初始化： 分区， 目录挂载


2、机器初始化

下载k3s依赖软件：yum install 需要手动执行

安装k3s需要关闭selinux

```shell
setenforce 0
```
修改文件：
```shell
/etc/selinux/config
```
修改行：
```
SELINUX=disabled
```

重启系统

禁用firewalld, 它会扰乱iptables

```shell
systemctl stop firewalld
systemctl disable firewalld
```

3、 安装k3s
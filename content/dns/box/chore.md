+++
title = "讨论"
date =  2021-04-14T09:34:02+08:00
description= "讨论区"
weight = 5
+++

## 1、dns产品使用rpm或者ansible安装？

安装涉及到：
- dns产品的磁盘分区（数据库）
- 网卡初始化
- 密码初始化（grafana,coredns）
- 配置文件文件生成

优缺点：

rpm:
  + 安装方便，基本无依赖
  + 只能对系统进行简单的初始化操作
  + 定制化较严重，缺少灵活性

ansible:
  + 安装有依赖
  + 可以定制系统（磁盘，网络等）
  + 可定制化，安装灵活


## 2、arm64 image

基础镜像：

library/postgres-arm64
library/php-nginx-arm64
library/openjdk-arm64
library/nginx-worker-arm64
library/nginx-arm64
library/kafka-zookeeper-arm64
library/golang-kafka-arm64
library/golang-arm64
library/clickhouse-arm64
library/ubuntu-arm64
library/alpine-arm64
hub.dns.360.cn/library/node-arm64:10.23.3
hub.dns.360.cn/library/clickhouse-arm64:21.1.2.15
hub.dns.360.cn/library/prometheus:v2.20.1
hub.dns.360.cn/library/dashboard-arm64:v2.0.4
hub.dns.360.cn/library/grafana-arm64:7.1.5

业务相关：

hub.dns.360.cn/dns/kafka-zookeeper-arm64:latest
hub.dns.360.cn/dns/nginx-worker-arm64:latest
hub.dns.360.cn/dns/postgres-arm64:v2.7.4
hub.dns.360.cn/dns/clickhouse-arm64:v2.7.4

hub.dns.360.cn/dns/coredns-box-prepare-arm64:latest
hub.dns.360.cn/dns/coredns-box-arm64:v2.7.5
hub.dns.360.cn/dns/grafana-arm64:v2.7.3
hub.dns.360.cn/dns/prometheus-arm64:v2.7.3
hub.dns.360.cn/dns/cron-report-arm64:v2.7.3
hub.dns.360.cn/dns/sms-arm64:v2.7.4

hub.dns.360.cn/dns/qdns/web-box-prepare-arm64:latest
hub.dns.360.cn/dns/web-box-arm64:v2.7.4

hub.dns.360.cn/dns/php-build-arm64:latest
hub.dns.360.cn/dns/php-box-arm64:v2.7.6


## 3、容器用户及进程问题

- 以postgres为例：

```shell
[root@localhost ~]# ps  -ef | grep postgres
UID          PID    PPID  C STIME TTY          TIME CMD
70       2094186 2093529  0 4月16 ?       00:01:11 postgres
```

可以看到启动的 uid为70, 进场id是 2094186 父进程id是：2093529

- 查看父进程：

```shell
[root@localhost ~]# ps  -ef | grep 2093529
UID          PID    PPID  C STIME TTY          TIME CMD
root     2093529       1  0 4月16 ?       00:30:42 /data/k3s/data/07bf5246a6ab2127234428fbf3023ce85b0376a7b946bbdaee2726b7d9a6fad8/bin/containerd-shim-runc-v2 -namespace k8s.io -id 7359ee63fdefabc6987f19a251075166c632c9771cdc4696cb2b15ade4c5f927 -address /run/k3s/containerd/containerd.sock
```

可以看到父进程用户是root，进场id是：2093529 ,父进程是1号进程。

- 看下用户：

```shell
cat /etc/passwd | grep 70
```
当前系统没有70这个用户

- 进入容器

```shell
[root@localhost ~]# kubectl exec -it box-postgres-bff79d55c-p452q -- bash
bash-5.0# ps -ef
PID   USER     TIME  COMMAND
1 postgres  1:11 postgres
```

容器进程是1号，用户 postgres

- 容器中的用户
- 
postgress 用户属于容器中

```shell
bash-5.0# cat /etc/passwd | grep 70
postgres:x:70:70:Linux User,,,:/var/lib/postgresql:/bin/sh
```

结论：

容器中的用户不存在实际机器中。容器中进程的pid由containerd父进程创建，容器中的进程均是containerd的子进程。

+++
title = "本脑安装"
date =  2021-02-24T11:41:23+08:00
weight = 5
description= "本地安全大脑安装"
+++

## 1、机器名不能相同
  如果机器名相同，请修改成不同机器名 hostname

## 2、磁盘创建

为clickhouse创建一个单独的磁盘：
只需要很小即可

```shell
lvcreate -L 30G -n clickhouse-hdd VolGroup00
```

## 3、配置文件生成及修改

```shell
make gen
```
后生成的配置文件修改：


使用v2.7.3版本

手动修改配置文件：
集群分为master节点和node节点，请分别配置

`inventories/gen/hosts`

```ini
[master]
ip1

[node]
ip2

[all:children]
master
node
```

配置文件复制
目录 `inventories/gen/host_vars`
host1.yml
复制出
host2.yml

更改配置文件参数：

```shell
## clickhouse hdd使用磁盘

## 禁止初始化eth0网络
pandora_local_test: true
pandora_k3s_clustered: true
```

交换kafka和clickhouse的磁盘分区配置

## 4、安装dns

```shell
# 初始化机器yum kernel等
make install-machine
# 初始化网络 磁盘
make install-prepare-machine
# 下载镜像 请确认docker运行中  注意： 若安装机器有网，且镜像源为外网，可跳过这不执行
make install-prepare-image
# 安装k3s
make install-k3s
# 安装 node exporter
make install-exporter
# 安装 dns应用
make install-dns
```

## 5、为dns打上集群化补丁

这一节的所有操作请到master节点上执行；

安装好后需要修改数据库应用的nodeselecter字段，用于固定应用到指定节点上。

```shell
kubectl get pod -owide | grep -v svclb
```
确定数据库应用全部是running状态,
以上会输出所有应用所在的node。将用于后面的应用补丁


```shell
# 获取所有安装应用
kubectl get deploy
# 更新box-postgres,box-prometheus,box-kafka,box-grafana,box-clickhouse应用
```

脚本生成：

```shell
cat  > patch.sh <<EOF
#!/bin/bash

echo "update \$1..."
INSTANCE=\$(kubectl get deploy \$1 -o jsonpath="{\$.spec.selector.matchLabels['app\.kubernetes\.io/name']}")
if [ -z  \$INSTANCE ]; then
  echo "no instance find"
  exit 1
fi

NODE_NAME=\$(kubectl get po -l app.kubernetes.io/name=\$INSTANCE -owide | grep -v NAME | awk '{print \$7}' |  head -n1)
if [ -z  \$NODE_NAME ]; then
  echo "no node find"
  exit 1
fi

echo "set \$1 node: \$NODE_NAME"
kubectl scale deployment \$1 --replicas=0
sleep 2
kubectl patch deployment \$1 --patch "{\"spec\": {\"template\": {\"spec\": {\"nodeSelector\": {\"k3s.io/hostname\":\"\$NODE_NAME\" }}}}}"
kubectl scale deployment \$1 --replicas=1
EOF
```

添加权限：
```shell
chmod +x patch.sh
```

为应用打补丁,一个一个更新：
为应用 box-prometheus, box-kafka, box-postgres, box-grafana, box-clickhouse
```shell
# eg. 以box-prometheus 为例
./patch.sh box-prometheus
#确认应用替换成功, running状态
kubectl get po -l app.kubernetes.io/name=prometheus -owide 
```

前端应用调整为两个节点，这样每个节点都能直接访问：

```shell
kubectl scale deployment box-web --replicas=2
```

## 6、更新初始化license数据

```shell
make install-data
```

## 7、其它事项

这将修改root密码，若不需要请不要执行下面命令

```shell
make collect-info
```

`coredns` 项目需要更改配置文件
`kafka` 需要更改配置文件，支持集群外对接

coredns 配置文件：

```shell
FIREWALL_HTTP_TOKEN: kKn9UxKilZ2dXkkAXvU1OFWrbLgZHl
FIREWALL_INPUT_KAFKA_BROKERS: box-kafka.default.svc.cluster.local:9092
FIREWALL_INPUT_KAFKA_TOPIC: dns_gb_topic
FIREWALL_KAFKA_BROKERS: box-kafka.default.svc.cluster.local:9092
FIREWALL_OUTPUT_KAFKA_BROKERS: box-kafka.default.svc.cluster.local:9092
FIREWALL_OUTPUT_KAFKA_TOPIC: event_dns
FIREWALL_POSTGRES_URL: light:light@box-postgres.default.svc.cluster.local:5432/light
FIREWALL_WORK_MODE: brain
```
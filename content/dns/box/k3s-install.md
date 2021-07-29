+++
title = "k3s版本安装"
date =  2021-02-24T12:01:30+08:00
description= "2.7以上，使用k3s安装"
weight = 1
+++

# k3s盒子产品安装指南

当前本地虚拟机安装测试完成。

## 1、安装环境依赖

即你执行命令的环境，支持 mac 和 linux 环境。如果你是 windows 系统，请使用虚拟机安装 linux。

软件依赖：

- python3 (sudo apt install python3 python3-pip)
- docker
- make
- sshpass

安装环境需要在公司内网环境，因为需要下载安装镜像！
确认`docker`已经启动！

请确保执行 git submodule 命令！

```shell
git clone git@w.src.corp.qihoo.net:dns/pandora.git
git submodule update --init proto
```

ls proto 查看下 proto 文件是否有内容！

使用下面命令测试：

```shell
docker ps
make
python -c "print('hello')"
```

## 2、安装步骤

查看命令帮助文档

```shell
make
```

### 2.1、进入安装环境

```shell
make k3s
```

### 2.2、 安装

查看当前环境的命令帮助文档

```shell
make
```

初始化参数：

```shell
make gen
```

生成的参数在 `inventories/gen/host_vars/<host>.yml`
测试请自行修改使用到的镜像。

注意：

> 安装分为两种方式： 1、分步安装、2、一步安装；分布安装会逐步安装依赖，一步安装会将所有依赖一起安装；一步安装中间如果报错，修复错误问题后，可使用分步安装从报错步骤开始往后安装。

一、分步安装

分别执行下面命令：

不要跳步执行！

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
# 初始化数据
make install-data
```

二、一步安装

将执行上面分步安装的所有 task！

执行下面命令：

```shell
make install-all
```

注意：

由于项目进度问题，目前 license 初始化接口尚未完成，请联系对应同学手动初始化！！！

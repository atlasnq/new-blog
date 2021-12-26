---
title: CentOS7安装Python3
copyright: true
date: 2019-05-13 22:39:55
tags: [Linux,学习笔记]
categories: Linux
comments: true
urlname: Linux-install-python3
---



{% cq %} 本篇介绍在CentOS7环境下，编译安装Python3。 {% endcq %}

<!--more-->



## 配置yum源

这里我更换为阿里源

①

```bash
进入到 repo 的目录
	cd /etc/yum.repos.d

接着将该目录下的所有文件放入 backup 中
	mkdir  ../backup 
	mv  ./*  ../backup
	mv  ../backup  ./

下载第一个 yum 仓库
	sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
note：到这里，虽然有了阿里源，但是 默认是没有那么多包的，需要添加额外的软件包

下载第二个 epil 仓库
	sudo wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

清空缓存
	yum clean all

重新生成缓存
	yum makecache
```



## 安装库环境

②

```
yum install gcc patch libffi-devel python-devel  zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel -y
```



## 下载并解压python3

我下载的是python3.6版本，链接为：`https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz`

将这个压缩文件，放在/opt/下，然后解压缩：

③

`tar  -xzvf  Python-3.6.9.tgz`



## 指定安装路径

进入到解压缩后的文件，找到一个配置的可执行文件（configure）指定安装路径（prefix）并执行它。

④

`./configure --prefix=/opt/python367 `



## 编译

⑤

`make && make install`



## 配置环境变量

编译完成后，修改环境变量的配置

方式一：

为 python3.6 设置软链接

`ln -sn /opt/python367/bin/python3.6 /usr/local/sbin`

方式二：（推荐）

- /etc/profile，系统全局的配置文件，每个用户在登陆系统的时候，都会加载这个文件

编辑 profile 文件

`vim /etc/profile`

在最底层将python3的bin目录的绝对路径写入环境变量。	

​	写法一：

​		`PATH="/opt/python367/bin:$PATH"`

​	写法二：推荐：		`PATH="/opt/python367/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin"`



让系统重新读取这个文件

​	`source /etc/profile`



注意：将python3的环境变量放在最前面，source 是从左往右读取的。



扩展阅读：

## 创建虚拟环境

由于项目存在模块同名，不同版本号的情况，我们需要为不同项目的创建不同的虚拟环境。

格式：

```
virtualenv --no-site-packages --python=python解释器的绝对路径 虚拟环境名	
```

`--no-site-packages` ：指不携带任何模块，纯净的python解释器环境。

`--python`：指设置python解释器



例如：创建一个使用 django3 的虚拟环境

```bash
virtualenv --no-site-packages --python=/opt/python367/bin/python3.6 venv_dango3
```

执行上面的命令后，就会在当前目录创建一个 venv_dango3 的虚拟环境。



## 使用虚拟环境

进入虚拟环境的bin目录，执行脚本 `activate` 即可。

```
cd 虚拟环境名称/bin 
source activate
```

退出虚拟环境只需要输入 `deactivate`

## 小试一下

为了验证，进入了虚拟环境后：

```python
echo $PATH   # 我们发现，虚拟环境的bin路径在最左侧
which python3.6   # 结果也表明使用的是虚拟环境的python解释器
```

小试一下：

我们安装一个 django3 ，并运行它

```python
安装 django3.0a1
	pip3 install django==3.0a1  
查看安装的 django 版本
	pip3 list  					
创建一个django项目
	django-admin startproject eg_django3  
进入django项目，首先修改settings.py
	cd eg_django3/
	cd eg_django3/
	vim settings.py
		修改 ALLOWED_HOSTS = [] 为 ALLOWED_HOSTS = ['*']
然后回到上一级目录，执行 ：
	python3.6 manage.py runserver 0.0.0.0:8001
```

然后用另一台电脑就可以打开页面了。

note：如果打不开，关闭并清空一下防火墙规则。

```
iptables -F
systemctl stop firewalld.service
```


---
title: Ubuntu使用记录
copyright: true
date: 2019-10-25 20:17:38
tags: [Ubuntu,学习笔记]
categories: Ubuntu
comments: true
urlname:  Learn-Ubuntu-1
---



{% cq %}记录使用Ubuntu时用到的命令。 {% endcq %}

<!--more-->



## 查看&卸载软件

1. 查看安装的软件：

   `dpkg --list`

2. 卸载软件：

   `sudo apt-get --purge remove 包名`（`--purge`是可选项，写上这个属性是将软件及其配置文件一并删除，如不需要删除配置文件，可执行`sudo apt-get remove 包名`）



持续更新中！！！
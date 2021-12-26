---
title: Ubuntu安装Vue-cli
copyright: true
date: 2019-10-25 17:02:26
tags: [Vue.js,学习笔记]
categories: Vue.js
comments: true
urlname:  learn-Vue-4
---



{% cq %}本篇介绍在ubuntu下安装脚手架（vue-cli），从nvm ->node.js -> vue-cli {% endcq %}

<!--more-->





## nvm

由于node.js的版本一直处于不断更新中，所以我们需要一个版本管理器来更好的使用node.js。

nvm是一个开源的node版本管理器，通过它，你可以下载任意版本的node.js，还可以在不同版本之间切换使用。

**注意：安装nvm之前，要确保当前机子中不存在任何版本的node，如果有，则卸载掉。**

github：<https://github.com/creationix/nvm>

安装命令：

```bash
sudo apt-get update
sudo apt install curl
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
source ~/.bashrc
```

常用的nvm命令：

```python
# 查看官方提供的可安装node版本
nvm ls-remote

# 安装执行版本的node,例如：nvm install v10.15.2
nvm install <version>

# 卸载node版本，例如：nvm uninstall v10.15.2
nvm uninstall <version>

# 查看已安装的node列表
nvm ls

# 切换node版本，例如：nvm use v10.15.2
nvm use <version>

# 设置默认版本，如果没有设置，则开机时默认node是没有启动的。
nvm alias default v10.15.2

# 查看当前使用的版本
nvm current
```



## Node.js

Node.js是一个新的后端(后台)语言，它的语法和JavaScript类似，所以可以说它是属于前端的后端语言，后端语言和前端语言的区别：

- 运行环境：后端语言一般运行在服务器端，前端语言运行在客户端的浏览器上
- 功能：后端语言可以操作文件，可以读写数据库，前端语言不能操作文件，不能读写数据库。

node.js的版本有两大分支：

- 官方发布的node.js版本：0.xx.xx 这种版本号就是官方发布的版本

- 社区发布的node.js版本：xx.xx.x  就是社区开发的版本



对于我们只需要安装常用的LTS版本（长线支持版本 Long-Time Support）：

```python
# 安装
nvm install v10.15.2

# 设置为默认版本
nvm alias default v10.15.2

# 查看node.js版本
node -v
```



## npm

npm（node package manager）是nodejs的包管理器，用于node插件管理（包括安装、卸载、管理依赖等）。安装了node以后，就自动安装了npm[不一定是最新版本]。这个工具相当于python的pip管理器。

官方：[https://www.npmjs.com](https://www.npmjs.com/)

文档：[https://www.npmjs.com.cn/](https://www.npmjs.com.cn/)

```bash
npm --version
npm install -g 包名              # 安装模块   -g表示全局安装，如果没有-g，则表示在当前项目安装
npm list                        # 查看当前目录下已安装的node包
npm view 包名 engines            # 查看包所依赖的Node的版本 
npm outdated                    # 检查包是否已经过时，命令会列出所有已过时的包
npm update 包名                  # 更新node包
npm uninstall 包名               # 卸载node包
npm 命令 -h                      # 查看指定命令的帮助文档
```



## cnpm

默认情况下，npm安装插件是从国外服务器下载，受网络影响大，可能出现网络异常。

通过淘宝镜像加速npm

[http://npm.taobao.org/](http://npm.taobao.org/)

```bash
# 打印默认的 registry 地址
npm config -g get registry

# 设置淘宝镜像
npm config -g set registry https://registry.npm.taobao.org
```



## vue-cli

使用前面已经安装好的node版本，进行安装。注意一旦安装以后，以后这个vue-li最好契合当前node版本。也就是说，运行接下来安装的vue-cli时，最好运行的就是本次跑的node版本。如果回头切换到其他版本node来运行vue-cli，有可能因为版本不兼容出现不必要的bug。

文档：[https://cli.vuejs.org/zh/guide/installation.html](https://cli.vuejs.org/zh/guide/installation.html)

安装命令

```bash
npm install -g @vue/cli
npm install -g @vue/cli-init  # vue2.x版本需要安装桥接工具

# 安装完成可以查看版本(这个可不是Vue自己的版本呦)
vue -V

# 搭建项目
# vue2.x
vue init webpack <项目目录名>

# vue3.x
vue create <项目目录名>
```


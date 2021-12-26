---
title: Vue+DRF练习
copyright: true
date: 2019-11-03 19:39:59
tags: [RESTful,Django,DRF,学习笔记]
categories: DRF
comments: true
urlname:  Django-REST-Framework-4
---



{% cq %} 使用Vue与DRF做一个简单的前后端分离练习。 {% endcq %}

<!--more-->

# 练习

1. 使用vue-cli部署一个前端项目，并且使用axios请求上接口drf中提供的省份信息接口数据。

   要求：

   1. 能实现前端增删查改省份信息的功能 

   ​       其中查询数据的时候，显示为案例中的表格格式。

   ​      注意,在drf中可以通过自定义请求头,实现cors,解决axios跨域问题。

   | 国家编号 (id) | 省份 (name) | 占地面积 （area） | 人口 （population/亿） | 国民生产总值 （gdp/万亿） |
   | ------------- | ----------- | ----------------- | ---------------------- | ------------------------- |
   | 1             | 广东        | 17.98             | 1.12                   | 9.73                      |
   | 2             | 江苏        | 10.26             | 0.80                   | 9.26                      |
   | 3             | 山东        | 15.7              | 1.00                   | 7.65                      |
   | 4             | 浙江        | 10.18             | 0.57                   | 5.62                      |
   | 5             | 河南        | 16.7              | 0.96                   | 4.8                       |
   | 6             | 四川        | 48.5              | 0.83                   | 4.07                      |
   | 7             | 湖北        | 18.59             | 0.59                   | 3.94                      |
   | 8             | 湖南        | 21.18             | 0.69                   | 3.64                      |
   | 9             | 河北        | 19                | 0.75                   | 3.6                       |
   | 10            | 福建        | 12.14             | 0.39                   | 3.58                      |



2. 实现点击gdp表头信息,能够进行倒叙排序



# DRF



## 解决跨域问题

使用 `django-cors-headers` 来解决跨域

安装：

```
pip install django-cors-headers
```

修改配置：

```python
# settings.py
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'rest_framework',
    + 'corsheaders',
    'province',
]

# 设置跨域白名单
+ CORS_ORIGIN_WHITELIST = [
    "http://localhost:8081",
	]

MIDDLEWARE = [
    + 'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```

推荐阅读： https://pypi.org/project/django-cors-headers/



## 排序









# Vue

## axios

对于 axios 设置为 `Vue.prototype` 的属性，这样可以在其它地方引用。

```js
// index.js 
import axios from "axios";
Vue.prototype.$axios = axios
```



```vue
// Home.vue
// 使用 this.$axios 来使用 axios 发送 Ajax 请求

this.$axios.get("http://127.0.0.1:8000/province/", {
                    params: {"ordering": 'gdp'}
                }).then(response => {
                    this.province = response.data;

                }).catch(error => {
                    console.log(error);
                    console.log(error.response);
                })
```


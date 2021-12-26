---
title: Vue-axios与后端的数据交互
copyright: true
date: 2019-10-24 01:17:24
tags: [Vue.js,学习笔记]
categories: Vue.js
comments: true
urlname:  learn-Vue-2
---





{% cq %}本篇介绍在Vue中使用axios与后端进行数据交互。 {% endcq %}

<!--more-->



# 通过axios实现数据请求

vue.js 默认没有提供 ajax 功能的。

- 所以使用vue的时候，一般都会使用axios的插件来实现ajax与后端服务器的数据交互。

注意，axios本质上就是javascript的ajax封装，所以会被**同源策略**限制。

插件： http://www.axios-js.com/

下载地址：

```
https://unpkg.com/axios@0.18.0/dist/axios.js
https://unpkg.com/axios@0.18.0/dist/axios.min.js
```

axios提供发送请求的常用方法有两个：axios.get() 和 axios.post() 。



一睹为快：

```javascript
	// 发送get请求
    // 参数1: 必填，字符串，请求的数据接口的url地址，例如请求地址：http://www.baidu.com?id=200
    // 参数2：可选，json对象，要提供给数据接口的参数
    // 参数3：可选，json对象，请求头信息
	axios.get('服务器的资源地址',{ // http://www.baidu.com
    	params:{
    		参数名:'参数值', // id: 200,
    	}
    
    }).then(function (response) { // 请求成功以后的回调函数
    		console.log("请求成功");
    		console.log(response.data); // 获取服务端提供的数据
    
    }).catch(function (error) {   // 请求失败以后的回调函数
    		console.log("请求失败");
    		console.log(error.response);  // 获取错误信息
    });

	// 发送post请求，参数和使用和axios.get()一样。
    // 参数1: 必填，字符串，请求的数据接口的url地址
    // 参数2：必填，json对象，要提供给数据接口的参数,如果没有参数，则必须使用{}
    // 参数3：可选，json对象，请求头信息
    axios.post('服务器的资源地址',{
    	username: 'xiaoming',
    	password: '123456'
    },{
        responseData:"json",
    })
    .then(function (response) { // 请求成功以后的回调函数
      console.log(response);
    })
    .catch(function (error) {   // 请求失败以后的回调函数
      console.log(error);
    });

```





# Ajax

- ajax，一般中文称之为："阿贾克斯"，是英文 “Async Javascript And Xml”的简写，译作：异步js和xml数据传输数据。

- ajax的作用： ajax可以让 js 代替浏览器向后端程序发送http请求，与后端通信，在用户不知道的情况下操作数据和信息，从而实现页面局部刷新数据/无刷新更新数据。

- 所以开发中ajax是很常用的技术，主要用于操作后端提供的**数据接口**，从而实现网站的**前后端分离**。

- ajax技术的原理是实例化 js 的XMLHttpRequest（XHR）对象，使用此对象提供的内置方法就可以与后端进行数据通信。



## 数据接口

- 数据接口，也叫api接口，表示**后端提供**操作数据/功能的url地址给客户端使用。

- 客户端通过发起请求向服务端提供的url地址申请操作数据【操作一般：增删查改】

- 同时在工作中，大部分数据接口都不是手写，而是通过函数库/框架来生成。

- 例如：浏览器输入 `http://wthrcdn.etouch.cn/weather_mini?city=北京`，我们就可以拿到数据。



## ajax的使用

ajax的使用必须与服务端程序配合使用：

1. 推荐阅读 [Django-AJAX](https://chennq.com/django/20190713-django_11_ajax.html) ,在这篇文章中使用 jq 给后端发 ajax 请求，后端（Django）进行处理，并返回。





## 同源策略


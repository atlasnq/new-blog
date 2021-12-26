---
title: DRF下的JWT
copyright: true
date: 2019-11-06 23:07:04
tags: [RESTful,Django,DRF,学习笔记]
categories: DRF
comments: true
urlname:  Django-REST-Framework-5
---



{% cq %} 在前后端分离项目中我们常使用JWT来保存用户的登录信息，本篇介绍JWT原理以及在django-restframewrok下使用JWT {% endcq %}


<!--more-->



# 概述

在用户注册或登录后，我们想记录用户的登录状态，或者为用户创建身份认证的凭证。我们不再使用Session认证机制，而使用Json Web Token认证机制。

> Json web token (JWT), 是为了在网络应用环境间传递声明而执行的一种基于JSON的开放标准（(RFC 7519)。该token被设计为紧凑且安全的，特别适用于**分布式站点的单点登录（SSO）场景**。JWT的声明一般被用来在身份提供者和服务提供者间传递被认证的用户身份信息，以便于从资源服务器获取资源，也可以增加一些额外的其它业务逻辑所必须的声明信息，该token也可直接被用于**认证**，也可被**加密**。

单点登录：对于分布式服务器来说，我们登陆一次后，其它服务器也可以登录。

所以，从这一点开始反思 `session` ，如果使用 `session` 的话，我们必须得有一个公共的资源，能够让这些服务器都访问的到。例如，这些服务器共用一个数据库服务器，这样也就可以实现了单点登录。从这个角度考虑的话，JWT 就要简单很多了！



## 结构

JWT就一段字符串，由三段信息构成的，将这三段信息文本用`.`链接一起就构成了Jwt字符串。就像这样:

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

第一部分我们称它为头部（header),第二部分我们称其为载荷（payload, 类似于飞机上承载的物品)，第三部分是签证（signature).



### header

jwt的头部承载两部分信息：

- 声明类型，这里是jwt
- 声明加密的算法 通常直接使用 HMAC SHA256

完整的头部就像下面这样的JSON：

```json
{
  'typ': 'JWT',
  'alg': 'HS256'
}
```

然后将头部进行base64加密（该加密是可以对称解密的),构成了第一部分.

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9
```



### payload

载荷就是存放有效信息的地方。这个名字像是特指飞机上承载的货品，这些有效信息包含三个部分

- 标准中注册的声明
- 公共的声明
- 私有的声明

**标准中注册的声明** (建议但不强制使用) ：

- **iss**: jwt签发者
- **sub**: jwt所面向的用户
- **aud**: 接收jwt的一方
- **exp**: jwt的过期时间，这个过期时间必须要大于签发时间
- **nbf**: 定义在什么时间之前，该jwt都是不可用的.
- **iat**: jwt的签发时间
- **jti**: jwt的唯一身份标识，主要用来作为一次性token,从而回避重放攻击。

**公共的声明** ： 公共的声明可以添加任何的信息，一般添加用户的相关信息或其他业务需要的必要信息.但不建议添加敏感信息，因为该部分在客户端可解密.

**私有的声明** ： 私有声明是提供者和消费者所共同定义的声明，一般不建议存放敏感信息，因为base64是对称解密的，意味着该部分信息可以归类为明文信息。

定义一个payload:

```json
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": 231sldsad2131
}
```

然后将其进行base64.b64encode() 加密，得到JWT的第二部分。

```
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9
```



### signature

JWT的第三部分是一个防止客户端篡改信息的签证信息，这个签证信息由三个小部分组成：

- header (base64后的)
- payload (base64后的)
- secret[秘钥]

这个部分需要base64加密后的header和base64加密后的payload使用`.`连接组成的字符串，然后通过header中声明的加密方式进行加盐`secret`组合加密，然后就构成了jwt的第三部分。

```javascript
// javascript
var encodedString = base64UrlEncode(header) + '.' + base64UrlEncode(payload);

var signature = HMACSHA256(encodedString, 'secret'); // TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

将这三部分用`.`连接成一个完整的字符串,构成了最终的jwt:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

**注意：**

1. **secret是保存在服务器端的，jwt的签发生成也是在服务器端的。**
2. **secret就是用来进行jwt的签发和jwt的验证，所以，它就是你服务端的私钥，在任何场景都不应该流露出去。一旦客户端得知这个secret, 那就意味着客户端是可以自我签发jwt了。**

ps：如果



## 流程

![JWT的流程](DRF下的JWT/JWT的流程.png)



jwt的优势：

1. 天生适用于SSO单点登录
2. 服务端只需要存储秘钥，不需要分别存放用户的jwt信息，降低了服务器的存储压力
3. 比cookie更加安全可靠。
4. 还可以用于提供数据加密传输的功能

jwt的缺点：

1. jwt存放在客户端的，所以一旦签发以后，我们服务端是无法控制或提前回收.
2. 增加客户端的技术难度





# DRF框架下使用JWT

**关于签发和核验JWT，我们可以使用Django REST framework JWT扩展来完成。**

推荐阅读：[官方文档](http://jpadilla.github.io/django-rest-framework-jwt/)



## 安装配置JWT

安装

```shell
pip install djangorestframework-jwt
```

配置

```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_jwt.authentication.JSONWebTokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ),
}

import datetime
JWT_AUTH = {
    'JWT_EXPIRATION_DELTA': datetime.timedelta(days=1),
}
```

- JWT_EXPIRATION_DELTA 指明token的有效期



## 生成jwt

Django REST framework JWT 扩展的说明文档中提供了手动签发JWT的方法

```python
from rest_framework_jwt.settings import api_settings

jwt_payload_handler = api_settings.JWT_PAYLOAD_HANDLER
jwt_encode_handler = api_settings.JWT_ENCODE_HANDLER

payload = jwt_payload_handler(user)
token = jwt_encode_handler(payload)
```



在用户注册或登录成功后，在序列化器中返回用户信息以后同时返回token即可。



## 后端实现登陆认证接口

Django REST framework JWT提供了登录获取token的视图，可以直接使用

在子应用路由urls.py中

```python
from rest_framework_jwt.views import obtain_jwt_token
from django.urls import path
urlpatterns = [
    path("login/", obtain_jwt_token),
]
```

在主路由中，引入当前子应用的路由文件

```python
urlpatterns = [
		...
    path('users/', include("users.urls")),
    # include 的值必须是 模块名.urls 格式,字符串中间只能出现一个圆点
]
```






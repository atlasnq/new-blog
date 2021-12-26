---
title: RESTful API规范
copyright: true
date: 2019-10-28 21:16:52
tags: [RESTful,学习笔记]
categories: RESTful
comments: true
urlname:  RESTful-1
---



{% cq %}本篇介绍10个RESTful API规范。在实际中对于这些规范可以选择性的使用。{% endcq %}

<!--more-->



# 概述

REST全称是Representational State Transfer，中文意思是表述（编者注：通常译为表征）性状态转移。 它首次出现在2000年Roy Fielding的博士论文中。

RESTful是一种定义**Web API接口的设计风格**，尤其适用于前后端分离的应用模式中。

这种风格的理念认为后端开发任务就是提供数据的，对外提供的是数据资源的访问接口，所以在定义接口时，客户端访问的URL路径就表示这种要操作的数据资源。

而对于数据资源分别使用POST、DELETE、GET、UPDATE等请求动作来表达对数据的增删查改。



**HTTP请求动词**

| 请求方法 | 请求地址     | 后端操作           |
| -------- | ------------ | ------------------ |
| GET      | /movies      | 获取所有电影       |
| POST     | /movies      | 添加电影           |
| GET      | /movies/<pk> | 获取编号为pk的电影 |
| PUT      | /movies/<pk> | 修改编号为pk的电影 |
| DELETE   | /movies/<pk> | 删除编号为pk的电影 |



事实上，我们可以使用任何一个框架都可以实现符合restful规范的API接口。

参考文档：http://www.runoob.com/w3cnote/restful-architecture.html



## 序列化

API接口开发，最核心最常见的一个过程就是序列化，所谓序列化就是把**数据转换格式**，序列化可以分两个阶段：

**序列化**： 把我们识别的数据转换成指定的格式提供给别人。

例如：我们在django中获取到的数据默认是模型对象，但是模型对象数据无法直接提供给前端或别的平台使用，所以我们需要把数据进行序列化，变成字符串或者json数据，提供给别人。

**反序列化**：把别人提供的数据转换/还原成我们需要的格式。

例如：前端JS提供过来的JSON数据，对于python而言就是字符串，我们需要进行反序列化换成模型类对象，这样我们才能把数据保存到数据库中。

接收数据(反序列化)   --->   操作数据   --->   响应数据(序列化)





# 规范

## 域名 ***

应该尽量将API部署在专用域名之下。

```http
https://api.example.com
```

如果确定API很简单，不会有进一步扩展，可以考虑放在主域名下。

```http
https://example.org/api/
```



## 版本（Versioning） ***

应该将API的版本号放入URL。

```http
http://www.example.com/app/1.0/foo

http://www.example.com/app/1.1/foo

http://www.example.com/app/2.0/foo
```

另一种做法是，将版本号放在HTTP头信息中，但不如放入URL方便和直观。[Github](https://developer.github.com/v3/media/#request-specific-version)就采用了这种做法。

因为不同的版本，可以理解成同一种资源的不同表现形式，所以应该采用同一个URL。版本号可以在HTTP请求头信息的Accept字段中进行区分（参见[Versioning REST Services](http://www.informit.com/articles/article.aspx?p=1566460)）：

```http
Accept: vnd.example-com.foo+json; version=1.0

Accept: vnd.example-com.foo+json; version=1.1

Accept: vnd.example-com.foo+json; version=2.0
```



## 路径（Endpoint）**

路径又称"终点"（endpoint），表示API的具体网址，每个网址代表一种资源（resource）

**(1) 资源作为网址，只能有名词，不能有动词，而且所用的名词往往与数据库的表名对应。**

举例来说，以下是不好的例子:

```http
/getProducts
/listOrders
/retreiveClientByOrder?orderId=1
```

对于一个简洁结构，你应该始终用名词。 此外，利用的HTTP方法可以分离网址中的资源名称的操作。

```http
GET /products ：将返回所有产品清单
POST /products ：将产品新建到集合
GET /products/4 ：将获取产品 4
PATCH（或）PUT /products/4 ：将更新产品 4
```

**(2) API中的名词应该使用复数。无论子资源或者所有资源。**

举例来说，获取产品的API可以这样定义

```http
获取单个产品：http://127.0.0.1:8080/AppName/rest/products/1
获取所有产品: http://127.0.0.1:8080/AppName/rest/products
```



## HTTP动词  ***

对于资源的具体操作类型，由HTTP动词表示。

常用的HTTP动词有下面四个（括号里是对应的SQL命令）。

- GET（SELECT）：从服务器取出资源（一项或多项）。
- POST（CREATE）：在服务器新建一个资源。
- PUT（UPDATE）：在服务器更新资源（客户端提供改变后的完整资源）。
- DELETE（DELETE）：从服务器删除资源。

还有三个不常用的HTTP动词。

- PATCH（UPDATE）：在服务器更新(更新)资源（客户端提供改变的属性）。
- HEAD：获取资源的元数据。
- OPTIONS：获取信息，关于资源的哪些属性是客户端可以改变的。

下面是一些例子。

```http
GET /zoos：列出所有动物园
POST /zoos：新建一个动物园（上传文件）
GET /zoos/ID：获取某个指定动物园的信息
PUT /zoos/ID：更新某个指定动物园的信息（提供该动物园的全部信息）
PATCH /zoos/ID：更新某个指定动物园的信息（提供该动物园的部分信息）
DELETE /zoos/ID：删除某个动物园
GET /zoos/ID/animals：列出某个指定动物园的所有动物
DELETE /zoos/ID/animals/ID：删除某个指定动物园的指定动物
```



## 过滤信息（Filtering）**

如果记录数量很多，服务器不可能都将它们返回给用户。API应该提供参数，过滤返回结果。

下面是一些常见的参数。query_string 查询字符串,地址栏后面问号后面的数据,格式: name=xx&sss=xxx

```http
?limit=10：指定返回记录的数量
?offset=10：指定返回记录的开始位置。
?page=2&per_page=100：指定第几页，以及每页的记录数。
?sortby=name&order=asc：指定返回结果按照哪个属性排序，以及排序顺序。
?animal_type_id=1：指定筛选条件
```

参数的设计允许存在冗余，即允许API路径和URL参数偶尔有重复。比如，GET /zoos/ID/animals 与 GET /animals?zoo_id=ID 的含义是相同的。



## 状态码（Status Codes）**

服务器向用户返回的状态码和提示信息，常见的有以下一些（方括号中是该状态码对应的HTTP动词）。

> - 200 OK - [GET]：服务器成功返回用户请求的数据
> - 201 CREATED - [POST/PUT/PATCH]：用户新建或修改数据成功。
> - 202 Accepted - [*]：表示一个请求已经进入后台排队（异步任务）
> - 204 NO CONTENT - [DELETE]：用户删除数据成功。
> - 400 INVALID REQUEST - [POST/PUT/PATCH]：用户发出的请求有错误，服务器没有进行新建或修改数据的操作
> - 401 Unauthorized - [*]：表示用户没有权限（令牌、用户名、密码错误）。
> - 403 Forbidden - [*] 表示用户得到授权（与401错误相对），但是访问是被禁止的。
> - 404 NOT FOUND - [*]：用户发出的请求针对的是不存在的记录，服务器没有进行操作，该操作是幂等的。
> - 406 Not Acceptable - [GET]：用户请求的格式不可得（比如用户请求JSON格式，但是只有XML格式）。
> - 410 Gone -[GET]：用户请求的资源被永久删除，且不会再得到的。
> - 422 Unprocesable entity - [POST/PUT/PATCH] 当创建一个对象时，发生一个验证错误。
> - 500 INTERNAL SERVER ERROR - [*]：服务器发生错误，用户将无法判断发出的请求是否成功。

状态码的完全列表参见[这里](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html)或[这里](https://zh.wikipedia.org/wiki/HTTP%E7%8A%B6%E6%80%81%E7%A0%81)。



## 错误处理（Error handling）

如果状态码是4xx，服务器就应该向用户返回出错信息。一般来说，返回的信息中将error作为键名，出错信息作为键值即可。

```json
{
    error: "Invalid API key"
}
```

这个就有些勉强了！



## 返回结果

针对不同操作，服务器向用户返回的结果应该符合以下规范。

- GET /collection：返回资源对象的列表（数组）
- GET /collection/ID：返回单个资源对象(json)
- POST /collection：返回新生成的资源对象(json)
- PUT /collection/ID：返回完整的资源对象(json)
- DELETE /collection/ID：返回一个空文档(空字符串)



## 超媒体（Hypermedia API）

RESTful API最好做到Hypermedia（即返回结果中提供链接，连向其他API方法），使得用户不查文档，也知道下一步应该做什么。

比如，Github的API就是这种设计，访问[api.github.com](https://api.github.com/)会得到一个所有可用API的网址列表。

```json
{
"current_user_url": "https://api.github.com/user",
"authorizations_url": "https://api.github.com/authorizations",
// ...
}
```

从上面可以看到，如果想获取当前用户的信息，应该去访问[api.github.com/user](https://api.github.com/user)，然后就得到了下面结果。

```json
{
  "message": "Requires authentication",
  "documentation_url": "https://developer.github.com/v3"
}
```

上面代码表示，服务器给出了提示信息，以及文档的网址。





## 其他

服务器返回的数据格式，应该尽量使用JSON，避免使用XML。






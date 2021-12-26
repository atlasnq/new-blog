---
title: RequestContetxt/AppContext对象
copyright: true
date: 2019-12-14 15:12:33
tags: [Web前端,Flask,学习笔记]
categories: Flask
comments: true
urlname:  flask_5
---



{% cq %} 在前两篇我们介绍了Local类与LocalStack类，得到了一个数据隔离的栈，那么这个栈用来存放什么呢？RequestContetxt对象与AppContext对象。本篇将介绍这两个对象 {% endcq %}

<!--more-->

在前两篇我们介绍了Local类与LocalStack类，得到了一个**数据隔离的栈**，那么这个栈用来存放什么呢？RequestContetxt对象与AppContext对象。它们是Flask中的两种上下文。

引用一段对上下文较为通俗的解释：

> *每一段程序都有很多外部变量。只有像Add这种简单的函数才是没有外部变量的。一旦你的一段程序有了外部变量，这段程序就不完整，不能独立运行。你为了使他们运行，就要给所有的外部变量一个一个写一些值进去。这些值的集合就叫上下文。*
> *– vzch*

​	Flask中的上下文定义是在 `globals.py` 中的，我在前文 [使用LocalStack对象维护栈] 也介绍了 LocalStack 的实现方式，在此基础上，我们只需要对LocalStack进行实例化，用单例方式去使用它！

```python
# flask/globals.py

"""
    flask.globals
    ~~~~~~~~~~~~~    
    Defines all the global objects that are proxies to the current
    active context.
    定义作为当前活动上下文代理的所有全局对象。
"""
from functools import partial

from werkzeug.local import LocalProxy
from werkzeug.local import LocalStack


_request_ctx_err_msg = 
"""
......省略
"""
_app_ctx_err_msg = 
"""
......省略
"""


def _lookup_req_object(name):
    top = _request_ctx_stack.top
    if top is None:
        raise RuntimeError(_request_ctx_err_msg)
    return getattr(top, name)


def _lookup_app_object(name):
    top = _app_ctx_stack.top
    if top is None:
        raise RuntimeError(_app_ctx_err_msg)
    return getattr(top, name)


def _find_app():
    top = _app_ctx_stack.top
    if top is None:
        raise RuntimeError(_app_ctx_err_msg)
    return top.app


# context locals
_request_ctx_stack = LocalStack()     
_app_ctx_stack = LocalStack()
current_app = LocalProxy(_find_app)   # 使用代理，可以实现动态更新的效果
request = LocalProxy(partial(_lookup_req_object, "request"))
session = LocalProxy(partial(_lookup_req_object, "session"))
g = LocalProxy(partial(_lookup_app_object, "g"))
```



为什么要用LocalStack？

1. 保证线程/协程之间的数据隔离
2. 为了在多应用情景下让一个请求可以很简单的知道当前上下文是哪个。



关于上下文的几点：

1. 当用户请求到来之后，flask内部会创建两个对象:

   ```python
   ctx = ReqeustContext() # 内部封装request/sesion
   app_ctx = AppContext() # 内部封装app/g
   ```

2. 实例化各自的LocalStack对象后，然后将ctx、app_ctx添加进去。

   ```python
   _request_ctx_stack = LocalStack()
   _app_ctx_stack = LocalStack()
   # 将各自的对象添加到local中.
   ```

3. Local是一个特殊结构,他可以为每个线程(协程)维护一个空间进行存取数据。

4. LocalStack的作用是将Local中维护成一个栈。

5. 内部更细节的结构为

   ```
   storage = {
           1212:{stack:[ctx,]}
   	}
   	
   storage = {
       	1212:{stack:[app_ctx,]}
       }
   ```

6. 视图函数如果想要获取:request/session/app/g,只需要导入即可,导入的本质是去各自storage中获取各自的对象,并调用封装其内部:request/session/app/g. (获取栈顶的数据top)

7. 请求处理完毕,将各自storage中存储的数据进行销毁。




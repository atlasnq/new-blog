---
title: 使用LocalStack对象维护栈
copyright: true
date: 2019-12-10 10:15:12
tags: [Web前端,Flask,学习笔记]
categories: Flask
comments: true
urlname:  flask_4
---



{% cq %} 前篇介绍了Flask中实现了数据隔离的Local类，对于这个类我们该怎么用呢？本篇介绍使用LocalStack对象维护栈 {% endcq %}

<!--more-->

文章脉络：

1. 首先我将先自行实现一个LocalStack类
2. 然后在与源码的实现方式进行比较



## 自定义LocalStack

- 在上一篇实现的Local类的基础上，我们增加一对key-value，key为'stack'，value为列表，在此基础上我们定义LocalStack类。
- 它的属性是 Local类的实例，方法是对 `storage = { 线程/协程id :{'stack':[]}}` 模拟栈的操作

```python
# globals.py
import threading

'''
目标
storage = {
    1231:{stack:[123,456]}
}
'''


class Local(object):
    def __init__(self):
        object.__setattr__(self, 'storage', {})

    def __setattr__(self, key, value):
        ident = threading.get_ident()  # 12960
        if ident in self.storage:
            self.storage[ident][key] = value
        else:
            self.storage[ident] = {key: value}

    def __getattr__(self, item):
        # def __getattribute__(self, item):  # 这个会报奇怪的错误
        ident = threading.get_ident()  # 12960
        if ident not in self.storage:
            return
        if item not in self.storage[ident]:
            return
        return self.storage[ident][item]

    def release(self):
        pass


class LocalStack(object):
    def __init__(self):
        self._local = Local()

    def push(self, value):
        '''将值放入栈'''
        if not self._local.stack:
            # 第一次
            self._local.stack = [value]
        else:
            self._local.stack.append(value)

    def pop(self):
        '''从栈中取值'''
        stack = self._local.stack
        if stack is None:
            return
        elif len(stack) == 1:
            self._local.release()  # 将列表删除
            return stack[-1]
        else:
            return stack.pop()

    @property
    def top(self):
        '''查看栈顶的数据'''
        if not self._local.stack:
            return
        return self._local.stack[-1]


ctx_stack = LocalStack()
app_ctx_stack = LocalStack()

```

使用 LocalStack 

```python
# run.py
from globals import ctx_stack
from globals import app_ctx_stack

import threading


# 一旦有用户请求到来

def task():
    print('id:',threading.get_ident())
    ctx_stack.push(123)        # 第一个 storage = { 84 : {stack:[123]}, 3012：{stack:[123]}
    app_ctx_stack.push(456)    # 第二个 storage = { 84 : {stack:[456]}, 3012：{stack:[456]}

    print('ctx_stack:',ctx_stack.top)
    print('app_ctx_stack:',app_ctx_stack.top)
    print('--------')


for i in range(2):
    t = threading.Thread(target=task, )
    t.start()
```

这样我们就实现了数据隔离的栈



## Flask源码中的LocalStack

Local的定义

```python
# werkzeug.local.py
class Local(object):
    __slots__ = ("__storage__", "__ident_func__")

    def __init__(self):
        object.__setattr__(self, "__storage__", {})
        object.__setattr__(self, "__ident_func__", get_ident)

    def __iter__(self):
        return iter(self.__storage__.items())

    def __call__(self, proxy):
        """Create a proxy for a name."""
        return LocalProxy(self, proxy)

    def __release_local__(self):
        self.__storage__.pop(self.__ident_func__(), None)

    def __getattr__(self, name):
        try:
            return self.__storage__[self.__ident_func__()][name]
        except KeyError:
            raise AttributeError(name)

    def __setattr__(self, name, value):
        ident = self.__ident_func__()
        storage = self.__storage__
        try:
            storage[ident][name] = value
        except KeyError:
            storage[ident] = {name: value}

    def __delattr__(self, name):
        try:
            del self.__storage__[self.__ident_func__()][name]
        except KeyError:
            raise AttributeError(name)
```

LocalStack定义

```python
# werkzeug.local.py
class LocalStack(object):

    def __init__(self):
        # 封装了Local实例
        self._local = Local()

    def __release_local__(self):
        self._local.__release_local__()

    def _get__ident_func__(self):
        # 获取查看标识id（线程/协程）的方法
        return self._local.__ident_func__

    def _set__ident_func__(self, value):
        # 封装标识方法
        object.__setattr__(self._local, "__ident_func__", value)

    __ident_func__ = property(_get__ident_func__, _set__ident_func__)
    del _get__ident_func__, _set__ident_func__

    def __call__(self):
        def _lookup():
            rv = self.top
            if rv is None:
                raise RuntimeError("object unbound")
            return rv

        return LocalProxy(_lookup)

    def push(self, obj):
        """从栈中Pushes一个新值"""
        rv = getattr(self._local, "stack", None)
        if rv is None:
            self._local.stack = rv = []
            # 这两个变量指向同一个列表
        rv.append(obj)  # 跟self._local.stack.append的结果一样
        return rv

    def pop(self):
        """
        pop栈顶元素，如果返回值为None，则该栈为空   
        """
        stack = getattr(self._local, "stack", None)
        if stack is None:
            return None
        elif len(stack) == 1:
            # 对只有一个元素的栈进行pop，需要删除该栈
            release_local(self._local)
            return stack[-1]
        else:
            return stack.pop()

    @property
    def top(self):
        """
        返回栈顶元素的值，如果为None，则该栈为空  
        """
        try:
            return self._local.stack[-1]
        except (AttributeError, IndexError):
            return None
```



### 为什么要使用LocalStack？

换句话理解就是为什么我们不直接使用Local？而要通过LocalStack类将其封装成栈的操作？

**为了在多应用情景下让一个请求可以很简单的知道当前上下文是哪个。**如在多app嵌套的时候，`print(current_app)` 打印出的就是当前的app

```python
from my_app01 import app01
from my_app02 import app02

from flask import current_app
 
with app01.app_context(): # 入栈
    print(current_app) # app01
    with app02.app_context(): # 入栈
        print(current_app) # app02    
	print(current_app) # app01
    
'''
在with的上下文管理中：
	__enter__中 push  app_ctx
 	__exit__中 pop  app_ctx
'''
```





## 总结

1. 在Local的基础上，我们存放了'stack'为key，列表为value的键值对，形成了栈空间
2. 在栈空间的基础上我们定义了push，pop，top等方法来操作栈空间
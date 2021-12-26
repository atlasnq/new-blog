---
title: Flask中的Local类以及原理剖析
copyright: true
date: 2019-12-08 15:11:42
tags: [Web前端,Flask,学习笔记]
categories: Flask
comments: true
urlname:  flask_3
---



{% cq %} 本篇介绍Flask中实现数据隔离的Local类以及原理剖析 {% endcq %}

<!--more-->

文章脉络：

1. 首先我将先自行实现一个Local类
2. 然后在与源码的实现方式进行比较



## 双下方法介绍

类的实例是可以存放数据的，我们通过“点”的方式来赋予/获取对象的属性，这是归功于类中定义的 `__setattr__` 方法与 `__getattribute__` 方法。

```python
class Foo(object):
    pass


obj = Foo()
obj.x1 = 123                              # 类中的 __setattr__ 方法
object.__setattr__(obj, 'x1', 456)        # 本质上运行的
print(obj.x1)                             # 类中的 __getattribute__ 方法
print(object.__getattribute__(obj,'x1'))  # 本质上运行的

```

当然也存在错误的用法：

```python
# 例如：
class Foo(object):
    def __setattr__(self, name. value):
    self.name = value
    # 因为每次属性幅值都要调用 __setattr__()，所以这里的实现会导致递归
    # 这里的调用实际上是 self.__setattr('name', value)。因为这个方法一直
    # 在调用自己，因此递归将持续进行，直到程序崩溃

# 可以使用 如下方式进行解决
class Foo(object):
    def __setattr__(self, name, value):
        self.__dict__[name] = value # 使用 __dict__ 进行赋值
        # 定义自定义行为
```



## 维护DATA_DICT全局字典

我们可以把数据存在DATA_DICT，对象本身可以不存储值

```python
DATA_DICT = {}
class Foo(object):

    def __setattr__(self, key, value):
        DATA_DICT[key] = value

    def __getattr__(self, item):
        return DATA_DICT[item]

# 这样的写法是表明，对象可以不存储值，可以存在别的地方
obj = Foo()
obj.x1 = 123
print(obj.x1)
```



## 维护storage字典

全局变量的方式是不合适的，在我们初始化一个对象后，我们给该对象封装一个名为 storage 的字典，用来存储数据。

```python
class Local(object):
    def __init__(self):
        object.__setattr__(self, 'storage', {})

    def __setattr__(self, key, value):
        self.storage[key] = value

    def __getattr__(self, item):
        return self.storage[item]


'''
这样所有的数据都放到了 storage 中
'''

obj = Local()
obj.x1 = 123
print(obj.x1)
```



## 为每一个线程创建一个字典

但是上面的这个对象对于所有线程是共享数据的，我们想为每一个线程创建一个字典。所以我们修改这两个封装属性的双下划线方法，以当前线程id为key来进行存取。

```python
'''
storage = {
    1231:{x1:0}
    1432:{x1:1}
    ...
    1211:{x1:9}
}
'''
import threading
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
        ident = threading.get_ident()  # 12960
        return self.storage[ident][item]


'''
这样所有的数据都放到了 storage 中
'''

obj = Local()

def task(arg):
    '''
    0  1231  obj.x1 = 0
    1  1432  obj.x1 = 1
    ...
    9  1211  obj.x1 = 9
    '''
    obj.x1 = arg
    print(obj.x1)


for i in range(10):
    t = threading.Thread(target=task,args=(i,))
    t.start()
```

- 意义：为每一个线程独立开辟空间，进行存取值！

  

## Flask中的Local类的源码实现

```python

'''
优先获取协程id的方法，如果没有则使用线程id的方法，
'''
try:
    from greenlet import getcurrent as get_ident
except ImportError:
    try:
        from thread import get_ident
    except ImportError:
        from _thread import get_ident

class Local(object):
    __slots__ = ("__storage__", "__ident_func__")

    def __init__(self):
        object.__setattr__(self, "__storage__", {})   		  # self.__storage__ = {}
        object.__setattr__(self, "__ident_func__", get_ident)  # self.__ident_func__ = get_ident 封装标识id（线程/协程）的方法。

    def __iter__(self):
        return iter(self.__storage__.items())

    def __call__(self, proxy):
        """Create a proxy for a name."""
        return LocalProxy(self, proxy)

    def __release_local__(self):
        # 从字典中删掉以线程id/协程id为key对应的值。
        self.__storage__.pop(self.__ident_func__(), None)

    def __getattr__(self, name):
        try:
            return self.__storage__[self.__ident_func__()][name]
        except KeyError:
            raise AttributeError(name)

    def __setattr__(self, name, value):
        ident = self.__ident_func__()  # 获取标识id
        storage = self.__storage__     
        try:
            # 后续
            storage[ident][name] = value   
        except KeyError:
            # 初始化
            storage[ident] = {name: value} # 

    def __delattr__(self, name):
        try:
            del self.__storage__[self.__ident_func__()][name]
        except KeyError:
            raise AttributeError(name)
```

将我们的代码与源码进行比较，发现源码做的更细致，它可以在协程级别实现数据隔离！

### 为什么不直接使用 `threading.local` 呢？

- 因为 `threading.local` 只能做到线程之间的数据隔离，所以需要重新定义并使用 `greenlet` 来兼容协程。



## 总结

1. 对象可以不直接存储数据，我们可以把数据存放在字典中，然后让这个字典做对象的属性。
2. 在字典的基础上，以线程/协程id为key，值为字典，这样的设计方式可以实现不同级别的数据隔离。


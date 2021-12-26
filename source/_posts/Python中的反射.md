---
title: Python中的反射
date: 2019-04-12 15:58:44
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-reflection
copyright: true
---



{% cq %}首先介绍什么是反射，然后是反射的四大方法，这其中我们最常用的是hasattr,getattr；然后从四个角度来演示如何使用反射，最后是总结。{% endcq %}

<!-- more -->



## 什么是反射



通过字符串去操作一个对象

- 字符串：字符串类型
- 对象：实例，类，当前文件（模块），其它模块



## 四大方法



### hasattr(object, name)

参数是一个对象和一个字符串。如果字符串是对象属性之一的名称，返回True，否则返回False 。（查）

（这 是 通 过 调 用 并 观 察 它 是 否 引 发 一 个 实 现 的 。 ）



### getattr(object, name [, default ])

返回对象(object)的指定属性的值。 名称(name)必须是字符串。如果字符串是对象属性之一的名称，则结 果是该属性的值。如果指定的属性不存在，则返回默认值（default）， 否则返回异常。（拿来使用）



### setattr(object, name, value)

它与getattr()方法相对应。参数是一个对象(object)，一个字符串(name)和一个任意值(value)。该字符串可以命名现有的属性或新的属性。如果该对象允许，该函数将该值分配给该属性。（修改/增加）



### delattr(object, name)

它与setattr()方法相关，参数是一个对象(object)和一个字符串(name),该字符串必须是对象属性/方法的名字，然后这个函数会删除以name命名的属性。



## 四个角度

### 从实例的角度研究反射

```
class A:
    static_field = '静态属性'

    def __init__(self,name,age):
        self.name = name
        self.age = age

    def func(self):
        print(f'in A func')

obj = A('小黑',18)
print(obj.name)
# 类属性的增删查改
print(hasattr(obj,'name'))
print(getattr(obj,'name',None))
print(getattr(obj,'name1',None))
# 给对象封装属性
setattr(obj,'hobby','玩')
print(getattr(obj,'hobby',None))
# 删除对象的某个属性
delattr(obj,'name')
print(hasattr(obj,'name'))
# 查看静态属性
if hasattr(obj,'static_field'):
    print(getattr(obj,'static_field'))
# 调用方法
if hasattr(obj,'func'):
    print(getattr(obj,'func'))
    getattr(obj,'func')()
```



### 从类的角度研究反射

```
class A:
    static_field = '静态属性'

    def __init__(self,name,age):
        self.name = name
        self.age = age

    def func(self):
        print(f'in A func')

print(hasattr(A,'static_field'))
print(getattr(A,'static_field'))
print(getattr(A,'func'))
obj = A('小黑',18)
getattr(A,'func')(obj)
```



### 从当前脚本研究反射

```
def func1():
    print('in func1')
def func2():
    print('in func2')
def func3():
    print('in func3')
class B:
    static = '静态'
    pass
import sys


print(sys.modules)  					# 字典
print(sys.modules[__name__])  			# 当前模块这个对象(module)  
print(__name__)   # __main__
this_modules = sys.modules[__name__]	# 从这个字典中获取模块这个对象
print(hasattr(this_modules,'func1'))
getattr(this_modules,'func1')()
cls = getattr(this_modules,'B')
obj = cls()
print(obj.static)
```

- sys.modules是一个字典，它的键是模块名，值是对象。
-  `__name__`这个变量引用的是当前的模块名.(以脚本运行时值为 `__main__`)



### 在其它模块研究反射

```
other_modules.py
def func():
    print('in func')

本模块
import other_modules as om
getattr(om,'func')()
```


---
title: Django的View
date: 2019-07-04 17:45:16
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_5
copyright: true
---



{% cq %}本篇介绍Django 的MTV结构中的 View。 {% endcq %}

<!--more-->

----------------

通过这篇文章，你能了解到：

- view是什么?
- 定义视图的两种方式
- 给视图加装饰器，来增加额外的功能



# View

一个视图函数（或视图类），简称视图，是一个简单的Python 函数（类），它接受Web请求并且返回Web响应。

响应可以是一张网页的HTML内容，一个重定向，一个404错误，一个XML文档，或者一张图片。 

无论视图本身包含什么逻辑，都要返回响应。代码写在哪里也无所谓，只要它在你当前项目目录下面。除此之外没有更多的要求了——可以说“没有什么神奇的地方”。为了将代码放在某处，大家约定成俗将视图放置在项目（project）或应用程序（app）目录中的名为`views.py`的文件中。



# FBV与CBV

## FBV 

function based view  基于函数的视图

定义FBV：

```python
def AddPublisher(request):
	'''功能逻辑''' 
	return HttpResponse('ok')
```

对应关系：

```python
url(r'^publisher_add/', views.AddPublisher),
```



## CBV  

class based view  基于类的视图

定义 CBV：

- 较于FBV会更清晰

```python
from django.views import View

class AddPublisher(View):

    def get(self, request, *args, **kwargs):
        # 处理 GET 请求
        return HttpResponse('ok')

    def post(self, request, *args, **kwargs):
        # 处理 POST 请求
        return HttpResponse('ok')
```

- 修改对应关系，执行as_view()方法

```python
url(r'^publisher_add/', views.AddPublisher.as_view()),
```



## 源码剖析

1. 项目启动时，运行 urls.py ；as_view方法去执行，返回view函数

2. 请求到来时，执行view函数

   1. 实例化AddPublisher  ---> self

   2. self.request = request

   3. 执行view函数中的 self.dispatch(request, *args, **kwargs) 方法

      1. 判断请求方式是否被允许 `if request.method.lower() in self.http_method_names:`

         1. 允许

            list中有这个方法，且在自定义的类中也写了这个方法。

            通过反射获取请求方式对应的方法 ---> handler       （重要）

         2. 不允许

            list中没有该方法

            `handler = self.http_method_not_allowed`  ---> handler

      2. 执行handler，获取响应

         1. 允许

         2. 不允许

            执行 `http_method_not_allowed` ，返回一个HttpResponse

最终目标就是将我们自定义的类中的 get 或 post 方法返回！

```python
    def view(request, *args, **kwargs):
        self = cls(**initkwargs)
        if hasattr(self, 'get') and not hasattr(self, 'head'):
            self.head = self.get
            self.request = request
            self.args = args
            self.kwargs = kwargs
            return self.dispatch(request, *args, **kwargs)
```

dispatch

```python
    def dispatch(self, request, *args, **kwargs):
        if request.method.lower() in self.http_method_names:
            handler = getattr(self, request.method.lower(), self.http_method_not_allowed)
        else:
            handler = self.http_method_not_allowed
        return handler(request, *args, **kwargs)
```

handler

```python
def http_method_not_allowed(self, request, *args, **kwargs):
    logger.warning(
    'Method Not Allowed (%s): %s', request.method, request.path,
    extra={'status_code': 405, 'request': request}
    )
return http.HttpResponseNotAllowed(self._allowed_methods())		# 状态码 405
```



# 给视图加装饰器

装饰器是在不修改源代码以及调用方式的情况下，增加新的功能。

## 定义装饰器

这里定义一个计算执行时间的装饰器

```python
from functools import wraps

def timer(func):
    @wraps(func)
    def inner(*args,**kwargs):
        '''inner'''
        start_time = time.time()
        ret = func(*args,**kwargs)
        print(f'执行时间：{time.time() - start_time}')
        return ret
    return inner

@timer
def blog(request, *args, **kwargs):
    '''blog'''
    return HttpResponse('ok')
```

note：对于inner函数，我们需要使用 wraps 装饰器装饰，这样可以把被装饰函数的配置信息（`__name__`, `__doc__`）等与inner函数的配置信息进行替换。



## 添加装饰器的几种方式

由于视图分为FBV与CBV，对于FBV，可以给它直接加装饰器，对于CBV的绑定方法，有下列几种情况



### 直接加（不建议）

```python
@timer
def get(self, request):
	return render(request, 'publisher_add.html')
```

### 在方法的定义上使用 `method_decorator` 装饰

通过 `method_decorator` 可以把函数装饰器转为方法装饰器

```python
from django.utils.decorators import method_decorator
@method_decorator(timer)
def get(self, request):
    return render(request, 'publisher_add.html')
```



### 在类的定义上使用 `method_decorator` 装饰

```python
@method_decorator(timer, name='post')
@method_decorator(timer, name='get')
class AddPublisher(View):
    def get(self, request):
        # 处理 GET请求
        print(self.request is request)
        return render(request, 'publisher_add.html')
        
    def post(self, request):
        error, pub_name = '', ''
        pub_name = request.POST.get('pub_name')
        obj = models.Publisher.objects.filter(name=pub_name)
        if not pub_name:
            # 提交空数据
            error = '数据为空'
        elif obj:
            # 表中数据存在
            error = '出版社名称重复'
        else:
            # 正确情况下，向数据库添加,并跳转到展示页面
            models.Publisher.objects.create(name=pub_name)
            return redirect('/publisher_list/')
        return render(request, 'publisher_add.html', {'error': error, 'pub_name': pub_name})
```



### 批量添加

对于前面这些，都是单独给一个函数或方法来加装饰器，那如果批量添加该怎么做呢？

通过前面对源码的剖析，在 `dispatch` 方法中，它按照请求方式的不同返回不同的方法，所以我们可以给 `dispatch` 方法加上装饰器，从而达到给这些方法加上装饰器的目的。



#### 给父类的  `dispatch`  加装饰器    （推荐）

- 当子类没有`dispatch` 方法的时候，会调用父类的 `dispatch` 方法，这样把装饰器加到了父类的 `dispatch` 上达到批量添加的目的。

```python
@method_decorator(timer, name='dispatch')     # 加到父类的dispatch里
class AddPublisher(View):
    ...
```



#### 子类重写 `dispatch`      （不推荐）

```python
@method_decorator(timer)
def dispatch(self, request, *args, **kwargs):
    start_time = time.time()
    print('dispatch 前')
    ret = super().dispatch(request, *args, **kwargs)
    print('dispatch 后')
    print(f'执行时间：{time.time() - start_time}')
    return ret
```



### 加不加 method_decorator 的区别

- @timer直接装饰方法的话：把这个方法当作一个函数， args内的第一个参数是self，第二个参数是request对象

- 加上 method_decorator 把它当作绑定方法，args内的第一个参数是request对象

- 它们功能上没有不同，但是就参数的位置上来说是不同的。只要可以确定request对象的位置，正确使用就行。



# 小结

当了解了view之后，还需要对参数request对象和返回值response对象做一个了解，下一篇为 [Django的request与response](https://chennq.com/django/20190704-django_5_1.html)。


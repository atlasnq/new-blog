---
title: Django的路由系统
copyright: true
date: 2019-07-05 21:16:54
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_6_url
---



{% cq %}本篇介绍Django的路由系统。{% endcq %}

<!--more-->

通过这篇文章，你能了解到：

- Django中的URL是什么？
- 路由分发、命名URL与URL的反向解析
- 名称空间的使用



# 概述



URL配置(URLconf)就像Django所支撑网站的目录。它的本质是URL与要为该URL调用的视图函数之间的映射表。



## URLconf配置



- 基本格式

```python
from django.conf.urls import url
urlpattern = [
	url(正则表达式,视图,参数,别名)
]
# 这个参数可以是一个字典，如{'foo': 'bar'}
# 当传递额外参数的字典中的参数和URL中捕获值的命名关键字参数同名时，函数调用时将使用的是字典中的参数，而不是URL中捕获的参数。
```



- Django是如何识别这个URL呢？settings中有设置：

```python
ROOT_URLCONF = '项目名.urls'
```



- 在Django2.0中用 re_path 来代替 url

```python
from django.urls import path，re_path

urlpatterns = [
    path('articles/2003/', views.special_case_2003),
    path('articles/<int:year>/', views.year_archive),
    path('articles/<int:year>/<int:month>/', views.month_archive),
    path('articles/<int:year>/<int:month>/<slug:slug>/', views.article_detail),
]
```



note：

1. urlpatterns中的元素按照书写顺序从上往下逐一匹配正则表达式，一旦匹配成功则不再继续。
2. 若要从URL中捕获一个值，只需要在它周围放置一对圆括号（分组匹配）。
3. 不需要添加一个前导的反斜杠，因为每个URL 都有。例如，应该是^articles 而不是 ^/articles。
4. 每个正则表达式前面的'r' 是可选的但是建议加上。



# 正则表达式

## 常用规则

- 开头不能加 `/`
- 从上到下匹配，匹配到一个就执行函数（$结尾，防止截胡）
- 使用 r 表示原生字符串，不转义
- ^ $  []{}  \d \w ?  +  * . 
- 更多规则详见 [正则匹配与Re模块](https://chennq.com/learn-python/20190407-Regular_Expression_and_Python_Re_module.html)



## 分组

- 正则中捕获到的参数传递给视图函数
- 将捕获的参数按照**位置参数**传递给视图

```python
from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^articles/2003/$', views.special_case_2003),
    url(r'^articles/([0-9]{4})/$', views.year_archive),
    url(r'^articles/([0-9]{4})/([0-9]{2})/$', views.month_archive),
    url(r'^articles/([0-9]{4})/([0-9]{2})/([0-9]+)/$', views.article_detail),
]

例如：
① 对于 /articles/2005/03/ 来说，它将调用 views.month_archive(request, '2005', '03') ,而且在它成功匹配后，也不再与后面的进行匹配。
② 对于 /articles/2003/03/03/ 将调用： views.article_detail(request, '2003', '03', '03')
```



## 命名分组

- `?P<name>` 
- 按照 **关键字参数** 传递视图
- 更加明确，参数的顺序可以改变，但是这是在牺牲简洁的条件下完成的。

```python
from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^articles/2003/$', views.special_case_2003),
    url(r'^articles/([0-9]{4})/$', views.year_archive),
    url(r'^articles/([0-9]{4})/([0-9]{2})/$', views.month_archive),
    url(r'^articles/([0-9]{4})/([0-9]{2})/([0-9]+)/$', views.article_detail),
]

① 对于 /articles/2005/03/ 来说，它将调用 views.month_archive(request, year='2005', month='03') ,而且在它成功匹配后，也不再与后面的进行匹配。
② 对于 /articles/2003/03/03/ 将调用： views.article_detail(request, year='2003', month='03', day='03')
```

note：**捕获的参数永远都是字符串**。



# 路由分发

- include （去包含另一个urlConf）
- ROOT__URLCONF这个配置

```python
urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^app01/', include('app01.urls', namespace='app01')),
    url(r'^app02/', include('app02.urls', namespace='app02')),
]
```



在前面我们的目标是在urls.py中路由时给view函数传递参数，这是正向的过程。

反向解析：

- 在模板中：使用url模板标签。
- 在Python 代码中：使用django.core.urlresolvers.reverse() 函数。
- 在更高层的与处理Django 模型实例相关的代码中：使用get_absolute_url() 方法。

反向解析是为了得到这个URL，然后使用redirect，href，等等。



# 命名URL和URL反向解析

# 静态路由

- 命名   
  - 设置name参数
- 模板中使用：
  - url 'name参数对应的值' 
- py文件：
  - `from django.urls import reverse`
  - `reverse('name参数对应的值')`



## URL命名

在url函数的第四个参数， 设置name  别名

```python
url(r'^blog/$', views.blog, name='blog'),
```



## 反向解析

通过name 拿到 url 路径，如果是在路由分下的情况下，也会把它给带上。



### 模板中

```html
{% url 'blog' %} ---> 'url地址'  # 将来替换成以前写死的地址
```



### views中

shortcuts  import reverse

快捷键

reverse 最终是在 urls 中 

```python
reverse('blog')  ---> '/blog/'
```

在redirect，可以直接用别名，而不用reverse，它里面写到过这种情况



# 动态路由

- 传参

- 分组：

- 命名分组：多一种方式



## 分组

```python
url(r'^blog/([0-9]{4})/([0-9]{2})', views.blogs,name='blogs'),
```



### 模板中

```python
<a href="{% url 'blogs' '2019' '07' %}">xxx</a>
```

### views文件中

```python
reverse('blogs','2019','07')
```

分组与参数要一一对应



## 命名分组

```python
url(r'^blog/(?P<year>[0-9]{4})/(?P<month>[0-9]{2})', views.blogs,name='blogs'),
```



### 模板中

- 顺序得对应

```python
<a href="{% url 'blogs' '2019' '07' %}">xxx</a>
```

### views中

```python
reverse('blogs','2019','07')
```

分组与参数要一一对应



### 关键字传参

- 位置顺序不受到限制了

```python
<a href="{% url 'blogs' month='07' year='2019' %}">xxx</a>
```

- views中

```python
reverse('blogs',year='2019',month='07')  
reverse('blogs', kwargs={year:'2019',month:'07'})
```



# 名称空间

解决，app下重名而产生的覆盖现象

**养成习惯，路由分发后就写namespace**



- 当都起一个相同的别名 name='home'，这样显示的是后面的

- 因为从上往下解析，后面的覆盖前面的。所以这样就会产生混淆（反向解析中）。

- 所以需要用区分namespace，include 有namespace默认参数，修改

- 反向解析时： `名称空间:别名`

- `根的名称空间:子的名称空间:别名`


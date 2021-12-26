---
title: Django图书管理系统的优化
date: 2019-07-03 17:43:39
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_4
copyright: true
---



{% cq %}本篇将对前面的图书管理系统进行优化：代码简化；添加分页；添加token；部分代码使用CBV；优化静态文件配置；设置名称空间，命名URL与反向解析；使用ajax来完成局部刷新。 {% endcq %}

<!--more-->



# 代码简化

- Django模板引擎中最强大、最复杂的是模板继承。通过定义一个基础的模板，在定义子模版的时候，只需要覆盖母板中的块，就可以达到简化的目的。

- 具体来说，对于定义的所有模板它们都是很重复的，导航相同，左侧栏相同，只有内容不同。在这个基础上，将相同的地方抽取出来作为母版 `base.html`



## 定义母板

- `base.html` 这里包含了，导航栏，左侧栏，以及内容的一个外框架。

- 在需要修改的地方留下**块**。
- 具体方法 移步 [django模板系统](https://atlasnq.github.io/django/20190701-django_3.html#more)

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    {% load static %}
    <link href="{% get_static_prefix %}plugins/bootstrap-3.3.7/css/bootstrap.min.css" rel="stylesheet">
    <link href="{% get_static_prefix %}css/dashboard.css" rel="stylesheet">
    <style>
        .table > tbody > tr > td {
            vertical-align: middle;
        }
    </style>
    {% block css %}
    {% endblock %}
    {# 留给子代去加载自己的css，js等 #}

</head>
<body>
<nav class="navbar navbar-inverse navbar-fixed-top">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar"
                    aria-expanded="false" aria-controls="navbar">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#">图书管理系统</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
            <ul class="nav navbar-nav navbar-right">
                <li><a href="#">Dashboard</a></li>
                <li><a href="#">Settings</a></li>
                <li><a href="#">Profile</a></li>
                <li><a href="#">Help</a></li>
            </ul>
            <form class="navbar-form navbar-right">
                <input type="text" class="form-control" placeholder="Search...">
            </form>
        </div>
    </div>
</nav>
<div class="container-fluid">
    <div class="row">
        <div class="col-sm-3 col-md-2 sidebar">
            <ul class="nav nav-sidebar">
                <li class="{% block pub_active %}{% endblock %}"><a href="/publisher_list/">出版社</a></li>
                <li class="{% block book_active %}{% endblock %}"><a href="/book_list/">图书</a></li>
                <li class="{% block auth_active %}{% endblock %}"><a href="/author_list/">作者</a></li>
            </ul>
        </div>
        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
            <div class="panel panel-primary">
                {% block content %}
                    <h1>母版</h1>
                {% endblock %}
            </div>
        </div>
    </div>
</div>
</body>
</html>
```

note：这个页面在后面有些改动，会将导航栏剥离出去。



## 子模板中导入

- 在子模板的最上方使用 `extends` 标签进行导入 
- 在 `block` 标签中覆写。

例如：在`author_list.html` 中，导入母板后，覆写了两块内容，一块是在左侧栏中，如果当前是作者页面的话改为被点击的状态；一块是对作者信息进行展示的 `table` 。

```html
{% extends 'base.html' %}

{% block auth_active %}
    active
{% endblock %}

{% block content %}
    <div class="panel-heading">作者管理</div>
    <div class="panel-body">
        <a href="/author_add" class="btn btn-primary btn-sm">添加</a>
        <table class="table table-striped table-hover">
            <thead>
            <tr>
                <th>序号</th>
                <th>ID</th>
                <th>名字</th>
                <th>著作</th>
                <th>操作</th>
            </tr>
            </thead>
            <tbody>
            {% for author in all_authors %}
                <tr>
                    <td>{{ forloop.counter }}</td>
                    <td>{{ author.pk }}</td>
                    <td>{{ author.name }}</td>
                    <td>
                        {# author.books.all这里不加括号也是可以的#}
                        {% for book in author.books.all %}
                            《{{ book.title }}》
                        {% endfor %}
                    </td>
                    <td>
                        <a href="/author_del/?pk={{ author.pk }}" class="btn btn-danger btn-sm">删除</a>
                        <a href="/author_edit/?pk={{ author.pk }}" class="btn btn-warning btn-sm">编辑</a>
                    </td>
                </tr>
            {% endfor %}
            </tbody>
        </table>
        <span style="color: red">{{ error }}</span>
    </div>
{% endblock %}
```



对于添加和编辑页面，我们不想要左侧栏，只需要导航栏和内容框就可以，这样的话使用组件，可以达到要求。



## 将导航栏做成组件

- 定义 nav.html
- 使用导航栏的时候，只需要使用 `include` 标签就行
- 组件的理解：将子模版渲染并嵌入当前HTML中

`nav.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    {% load static %}
    <link href="{% get_static_prefix %}plugins/bootstrap-3.3.7/css/bootstrap.min.css" rel="stylesheet">
    <link href="{% get_static_prefix %}css/dashboard.css" rel="stylesheet">
    <style>
        .table > tbody > tr > td {
            vertical-align: middle;
        }
    </style>
</head>
<body>
<nav class="navbar navbar-inverse navbar-fixed-top">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar"
                    aria-expanded="false" aria-controls="navbar">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#">图书管理系统</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
            <ul class="nav navbar-nav navbar-right">
                <li><a href="#">Dashboard</a></li>
                <li><a href="#">Settings</a></li>
                <li><a href="#">Profile</a></li>
                <li><a href="#">Help</a></li>
            </ul>
            <form class="navbar-form navbar-right">
                <input type="text" class="form-control" placeholder="Search...">
            </form>
        </div>
    </div>
</nav>
</body>
```



`author_add.html`

- 一部分是通过 include 导入
- 另一部分写剩下的内容（一个表单）

```html
{% include 'nav.html' %}
<div class="panel panel-primary col-lg-8 col-lg-offset-2">
    <div class="panel-heading">添加作者</div>
    <div class="panel-body">
        <form action="" method="post">
            {% csrf_token %}
            <div class="form-group">
                <label for="name" class="col-sm-2 col-sm-offset-2 control-label">名字:</label>
                <div class="col-sm-6">
                    <input type="text" name="name" id="name" class="form-control">
                </div>
            </div>
            <div class="form-group">
                <label for="books" class="col-sm-2 col-sm-offset-2 form-group">著作:</label>
                <div class="col-sm-6">
                    <select name="books" id="books" multiple class="form-control">
                        {% for book in all_books %}
                            <option value="{{ book.pk }}">{{ book.title }}</option>
                        {% endfor %}
                    </select>
                </div>
            </div>
            <button class="btn btn-primary btn-sm col-sm-offset-6 ">提交</button>
        </form>
        <span style="color: red">{{ error }}</span>
    </div>
</div>
```



编辑的做法与添加的做法相同，这里就不再重复了。



## 修改母板

由于开始定义母版的时候是把导航栏放在里面的，我们把它剥离出来。

`base.html`

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    {% block css %}
    {% endblock %}
    {# 留给子代去加载自己的css，js等 #}

</head>
<body>
{% include 'nav.html' %}
<div class="container-fluid">
    <div class="row">
        <div class="col-sm-3 col-md-2 sidebar">
            <ul class="nav nav-sidebar">
                <li class="{% block pub_active %}{% endblock %}"><a href="/publisher_list/">出版社</a></li>
                <li class="{% block book_active %}{% endblock %}"><a href="/book_list/">图书</a></li>
                <li class="{% block auth_active %}{% endblock %}"><a href="/author_list/">作者</a></li>
            </ul>
        </div>
        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
            <div class="panel panel-primary">
                {% block content %}
                    <h1>母版</h1>
                {% endblock %}
            </div>
        </div>
    </div>
</div>
</body>
</html>
```



## 小结

以上对于相同部分，我们做成母版只定义一次。从而达到简化代码的效果。



# 添加分页

 

分页是直接使用的bootstrap中的分页组件

```html
<nav aria-label="Page navigation">
  <ul class="pagination">
    <li>
      <a href="#" aria-label="Previous">
        <span aria-hidden="true">&laquo;</span>
      </a>
    </li>
    <li><a href="#">1</a></li>
    <li><a href="#">2</a></li>
    <li><a href="#">3</a></li>
    <li><a href="#">4</a></li>
    <li><a href="#">5</a></li>
    <li>
      <a href="#" aria-label="Next">
        <span aria-hidden="true">&raquo;</span>
      </a>
    </li>
  </ul>
</nav>
```

在开始之前做一个区分，前面将导航栏做成组件的方法可以用来实现分页吗？不行，因为分页的数量不是固定的。



## inclusion_tag

使用 `inclusion_tag` 可以返回一个动态的页面

### 定义

1. 先做**app01**下创建一个python包，名为 `templatestags` 

2. 在这个包内创建py文件，文件名可以自定义    my_tags.py

3. 在这个创建的py文件内写入：

   ```python
   from django import template
   register = template.Library()   # register的名字不能变
   
   或
   from django.template import Library
   register = Library()
   ```

4. 定义函数 + 装饰器

   ```python
   @register.inclusion_tag('page.html')	# 这里必须指定模板
   def page(num):
   	return {'num':range(1,num+1)} 
   ```

   

### 使用

- 在 `author_list.html` 的 table 下方导入
- 分为3页

```html
{% load my_tags %}
{% my_page 3 %}
```





# 添加token

- 在前面我们将settings.py的中间件中关于csrf注释了，这是因为在提交post请求时没有携带token，服务器拒绝接收。

- 那我们只需要在form表单中写如下内容即可：

  ```
  <form action="" method="post">	
  	{% csrf_token %}
  </form>
  ```

- 放在form标签后，form表单中产生有一个隐藏的标签 name = 'csrfmiddlewaretoken' ，这个标签的name:value 会在表单提交的时候一并提交。



# 优化静态文件配置

- 如果我们修改了settings.py 中的 `STATIC_URL = '/static/'`那么其它文件的导入都需要修改，那么怎样能避免修改呢？

```
加载：	
	{% load static %}
方式一：
	href={% static 'css/dashbord.css'%}
方式二：
	href="{% get_static_prefix %}css/dashbord.css"
```

- load static表示执行 `static.py` 这个文件 
- static 表示执行这个函数，将相对路径转成绝对路径
- get_static_prefix 执行这个函数，可以得到静态文件的前缀，如我们以前的 `/static/`



# 使用CBV优化

我们先前在 `views.py` 中写的是函数是 `FBV` ，但这种方式存在一个缺点，就是我们需要手动判断请求方式，这样的话不同请求方式会不断地叠加，不够清晰。所以重新以CBV来改造。





# 命名URL





```python
url(r'^del/', views.publisher_del, name='del'),
```



```html
<a href="{% url 'publish:del' %}/?pk={{ publisher.pk }}" class="btn btn-danger">删除</a>
```



改后: (整合到url中)

```python
url(r'^del/(\d+)', views.publisher_del, name='del'),
```

```html
<a href="{% url 'publish:del' %}/{{ publisher.pk }}" class="btn btn-danger">删除</a>
```





待补充！！！
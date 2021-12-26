---
title: Django-自定义权限组件(RBAC)
copyright: true
date: 2019-07-25 18:00:21
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_16_RBAC
---



{% cq %}当完成基础业务后，就该着手解决用户的权限问题了。 {% endcq %}

<!--more-->

通过这篇文章，你能了解到：

- RBAC是什么?
- 实现思路与流程
- 实现代码



## RBAC是什么?

在Django中，对于我们来说什么是权限呢？具体能体现在什么地方呢？

- 有权限的话就能访问这个url，所以url对应着权限。

那么权限该怎么存储呢？还需要什么呢？

- 除了权限，我们还有用户，最初级的版本是用户与权限建立对应关系，但是随着用户的增多，很多用户具有相同的权限，这样就产生了角色（用户组）的概念；
- 所以我们需要权限，用户，角色，角色与权限，用户与角色五张表。





## 思路

1. 登陆验证：首先用户会进行登录，登录完成后，我们需要将这个用户的权限信息（url）写到session中；
2. 权限校验：登陆后，当我们访问别的页面的时候，我们从session中获取该用户的权限，如果当前请求的 `url` 在权限中就可以访问，如果不在就告知无法访问。当然我们需要设置白名单，因为对于 login，register，admin 这类是不需要校验的，对于 index 这种是登录后所有人都能访问的。



## 流程

1. 定义视图函数：在 `auth.py` 中写登录函数，用户名密码验证通过后就查询该用户的权限，并将其放入session中，此外在session中加入登录状态（is_login）

2. 定义中间件：在中间件这个类中，定义 `process_request` 方法，在该方法中，我们将进行权限的校验，
   1. 首先，确定当前 `url` 不在白名单中（login，register，admin）；
   2. 获取登陆状态，确定当前 `url` 不在免校验名单（index ）；
   3. 获取用户权限，确定当前url在不在用户权限内，在的话就能访问，不在则不能访问。



## 实现代码



模型如下：

```python
from django.db import models


class Permission(models.Model):
    url = models.CharField(max_length=108, verbose_name='权限')
    title = models.CharField(max_length=32, verbose_name='标题')

    def __str__(self):
        return self.title


class Role(models.Model):
    name = models.CharField(max_length=32)
    permission = models.ManyToManyField('Permission', verbose_name='拥有权限', related_name='role', blank=True)

    def __str__(self):
        return self.name


class User(models.Model):
    username = models.CharField(max_length=32, verbose_name='用户名')
    password = models.CharField(max_length=32, verbose_name='密码')
    role = models.ManyToManyField('Role', verbose_name='所属角色', blank=True)

    def __str__(self):
        return self.username

```

登录验证如下：

```python
# auth.py
from django.shortcuts import render, redirect
from rbac import models

def login(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user_obj = models.User.objects.filter(username=username, password=password).first()
        if not user_obj:
            return render(request, 'login.html', {'error': '用户名或密码不存在'})
        request.session['is_login'] = True   # 会进行序列化
        # 查询该用户拥有的权限，并放在session中
        permissions = user_obj.role.filter(permission__url__isnull=False).values('permission__url')
        if not permissions:
            request.session['permission'] = None
        else:
            permissions = list(permissions.distinct())
            request.session['permission'] = permissions
        return redirect('index')

    return render(request, 'login.html')


def index(request):
    return render(request, 'index.html')
```

权限校验如下：

```python
# rbac.py
from django.utils.deprecation import MiddlewareMixin
from django.shortcuts import HttpResponse,redirect
from django.conf import settings
import re

class RbacMiddleWare(MiddlewareMixin):
    def process_request(self,request,*args,**kwargs):
        url = request.path_info
        for i in settings.WHITE_LIST:
            if re.match(i,url):
                return
        is_login = request.session.get('is_login')
        if not is_login:
            return redirect('login')
        for i in settings.LAISSER_PASSER:
            if re.match(i, url):
                return
        permission = request.session.get('permission')
        if permission:
            print(url)
            for i in permission:
                print(i)
                if re.match(i['permission__url'], url):
                    return
        return HttpResponse('无权访问，请通知管理员')
```


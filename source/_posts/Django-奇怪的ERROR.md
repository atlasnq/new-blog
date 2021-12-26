---
title: Django-奇怪的ERRORS
copyright: true
date: 2019-07-26 17:09:48
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_16_strange-ERRORS
---



{% cq %}记录学习Django时，遇到的奇怪的错误以及解决方式。 {% endcq %}

<!--more-->

①

ERRORS:

`<class 'rbac.admin.PermissionAdmin'>: (admin.E124) The value of 'list_editable[0]' refers to the first field in 'list_display' ('title'), which cannot be used unless 'list_display_links' is set.`

我的model：

```python
class Permission(models.Model):
    url = models.CharField(max_length=108, verbose_name='权限')
    title = models.CharField(max_length=32, verbose_name='标题')
    is_menu = models.BooleanField(default=False, verbose_name='是否是菜单')
    icon = models.CharField(max_length=50, verbose_name='图标', blank=True, null=True)

    def __str__(self):
        return self.title
```

我的admin.py

```python
from django.contrib import admin
from rbac import models


# Register your models here.
class PermissionAdmin(admin.ModelAdmin):
    list_display = ['title', 'url', 'is_menu', 'icon']
    # list_editable = ['title','url', 'is_menu', 'icon', ]
    list_editable = list_display

admin.site.register(models.Permission, PermissionAdmin)
```

解决方式如下：

- 添加一个 list_display_links

```python
from django.contrib import admin
from rbac import models


# Register your models here.
class PermissionAdmin(admin.ModelAdmin):
    list_display = ['title', 'url', 'is_menu', 'icon']
    # list_editable = ['title','url', 'is_menu', 'icon', ]
    list_editable = list_display
    list_display_links = None

admin.site.register(models.Permission, PermissionAdmin)
```

参考 [Check rule for list_display_links is incorrect](https://code.djangoproject.com/ticket/22792).



 


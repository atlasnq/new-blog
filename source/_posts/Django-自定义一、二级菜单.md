---
title: Django-自定义一、二级菜单
copyright: true
date: 2019-07-27 20:54:44
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_17_Custom_menu
---



{% cq %}本篇将自定义可重用的一、二级菜单。 {% endcq %}

<!--more-->



通过这篇文章，你能了解到：

- 定义一、二级菜单的思路
- 核心代码



## 前提

本篇是在自定义 RBAC组件 的基础上进行的补充，RBAC见~~~~

## 一级菜单

思路：

在登陆验证中，我们需要将用户信息写入到session中，需要写入的信息有：is_login（登录状态）、permission（权限信息/该用户可访问的 `url` 地址）、menu_list（菜单信息）。









## 二级菜单

目标：

一级菜单做展示，二级菜单做跳转。

思路：

- 在一级菜单，我们是将菜单信息写在Permission表中的，但是对于二级菜单的话，写在Permission中就不太合适了，重新定义一个Menu表，这个表中有两个字段：title（一级菜单标题）、icon（图标）
- 定义了model之后，就可以在一级菜单的基础上进行改进。

```python
class Menu(models.Model):
    icon = models.CharField(max_length=50, verbose_name='图标', blank=True, null=True)
    title = models.CharField(max_length=32, verbose_name='一级菜单标题')

    def __str__(self):
        return self.title


class Permission(models.Model):
    """
    menu_id  有menu_id  当前的权限是一个二级菜单
             没有menu_id   当前的权限时一个普通的权限
    """
    url = models.CharField(max_length=108, verbose_name='权限')
    title = models.CharField(max_length=32, verbose_name='标题')
    menu = models.ForeignKey('Menu', verbose_name='一级菜单', blank=True, null=True)

    def __str__(self):
        return self.title
```



数据结构

```python
{
	'menu_id': {
		'title': 'menu_title',
		'icon': 'fa-connectdevelop',
		'children': [{
			'title': 'title',
			'url': 'url'
		}]
	},
	'menu_id': {
		'title': 'menu_title',
		'icon': 'fa-code-fork',
		'children': [{
			'title': 'title',
			'url': 'url'
		}]
	}
}
具体如下：
{
    '1': {
		'title': '账单管理',
		'icon': 'fa-code-fork',
		'children': [{
			'title': '支付信息',
			'url': '/payment/list/'
		}]
	}
	'2': {
		'title': '客户管理',
		'icon': 'fa-connectdevelop',
		'children': [{
			'title': '客户信息',
			'url': '/customer/list/'
		}]
	},

}
```



实现如下：

```python
menu_dict = {}
for i in data:
    if i['permissions__menu_id']:
        menu_dict[i['permissions__menu_id']] = menu_dict.get(i['permissions__menu_id']) or {
            'title': i['permissions__menu__title'],
            'icon': i['permissions__menu__icon'],
            'children': []
        }
        menu_dict[i['permissions__menu_id']]['children'].append(
            {
                'title': i['permissions__title'],
                'url': i['permissions__url'],
            })
```


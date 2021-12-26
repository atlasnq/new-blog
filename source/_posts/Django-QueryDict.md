---
title: Django-QueryDict
copyright: true
date: 2019-07-19 19:41:50
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_14_QueryDict
---



{% cq %} QueryDict 是一个类字典对象，新增的属性与方法都需要了解。 {% endcq %}

<!--more-->

通过这篇文章，你能了解到：

- QueryDict是什么？
- QueryDict的属性与方法



## 源码

源码中 `QueryDict` 定义如下：

```python
class QueryDict(MultiValueDict):
    """
    A specialized MultiValueDict which represents a query string.

    A QueryDict can be used to represent GET or POST data. It subclasses
    MultiValueDict since keys in such data can be repeated, for instance
    in the data from a form with a <select multiple> field.

    By default QueryDicts are immutable, though the copy() method
    will always return a mutable copy.

    Both keys and values set on this class are converted from the given encoding
    (DEFAULT_CHARSET by default) to unicode.
    """

    # These are both reset in __init__, but is specified here at the class
    # level so that unpickling will have valid values
    _mutable = True
    _encoding = None

    def __init__(self, query_string=None, mutable=False, encoding=None):
        super(QueryDict, self).__init__()
        if not encoding:
            encoding = settings.DEFAULT_CHARSET
        self.encoding = encoding
        query_string = query_string or ''
        parse_qsl_kwargs = {
            'keep_blank_values': True,
            'fields_limit': settings.DATA_UPLOAD_MAX_NUMBER_FIELDS,
            'encoding': encoding,
        }
        ...
        self._mutable = mutable
        
    def _assert_mutable(self):
        if not self._mutable:
            raise AttributeError("This QueryDict instance is immutable")
        
    def __setitem__(self, key, value):
        # 当修改值时调用这个方法，
        self._assert_mutable()	# 会先判断是否 mutable
        key = bytes_to_text(key, self.encoding)
        value = bytes_to_text(value, self.encoding)
        super(QueryDict, self).__setitem__(key, value)
        
    @classmethod
    def fromkeys(cls, iterable, value='', mutable=False, encoding=None):
        """
        Return a new QueryDict with keys (may be repeated) from an iterable and
        values from value.
        """

    def setlist(self, key, list_):

    def setlistdefault(self, key, default_list=None):

    def appendlist(self, key, value):

    def pop(self, key, *args):

    def popitem(self):

    def clear(self):

    def setdefault(self, key, default=None):

    def copy(self):
        """Returns a mutable copy of this object."""

    def urlencode(self, safe=None):
        """
        Returns an encoded string of all query string arguments.

        :arg safe: Used to specify characters which do not require quoting, for
            example::

                >>> q = QueryDict(mutable=True)
                >>> q['next'] = '/a&b/'
                >>> q.urlencode()
                'next=%2Fa%26b%2F'
                >>> q.urlencode(safe='/')
                'next=/a%26b/'
        """  
```



## 属性



| 属性名      | 解释                                                         |
| ----------- | ------------------------------------------------------------ |
| `_mutable`  | 在实例化的时候，mutable=False，默认为False，不能对键对应值进行修改，修改`_mutable`为True后就可以修改了。 |
| `_encoding` | 在实例化的时候，encoding=None，默认使用settings.DEFAULT_CHARSET进行编码 |



## 方法



| 方法名                                         | 解释                                                         |
| ---------------------------------------------- | ------------------------------------------------------------ |
| `setlist(self, key, list_)`                    |                                                              |
| `setlistdefault(self, key, default_list=None)` |                                                              |
| `appendlist(self, key, value)`                 |                                                              |
| `pop(self, key, *args)`                        |                                                              |
| `popitem(self)`                                |                                                              |
| `clear(self)`                                  |                                                              |
| `setdefault(self, key, default=None)`          |                                                              |
| `copy(self)`                                   | 深拷贝 + 可修改                                              |
| `urlencode(self, safe=None)`                   | 将所有的参数（query string）编码后拼接在一起。这样不会被request因为&而进行切分。 |



## 例子（编辑之后重定向）



背景：当我们完成编辑时，希望返回的是进入编辑前的页面，而不是其它页面，所以我们需要对展示页面中a标签的链接进行一个修改，从而完成编辑后能返回这个展示页面，目标结果如下：

```
/crm/customer_edit/22?next=/crm/customer_search/?page=2&search=1
```

- `/crm/customer_edit/22` 是将要打开的编辑页面

- `?next=/crm/customer_search/?page=2&search=1` next后面记录了我们当前展示页面的url，这样在完成编辑后，就可以通过这个next，回到展示页面。

但在实际中，新的request请求会按照&进行切分，next对应的值就不完整了，所以实际中需要进行编码，效果如下

```
/crm/customer_edit/22?next=/crm/customer_search/%3Fpage%3D2%26search%3D1
```

方式：使用simple_tag，来生成可返回的url地址。

关键在于：**url上面携带着成功后要跳转的地址**

定义：

1. 将待前往**编辑的url**，通过reverse反向解析生成
2. 创建可变的QueryDict，并把当前完整的url 放在这个QueryDict中。
3. 使用 `urlencode` 进行编码得到 **历史url**，参数safe会在url前面加一个 `/` 这样保证是从 `/` 开始
4. 将这两个url进行拼接，中间用 `?` 连接。

```python
# my_tags.py
from django import template
from django.shortcuts import reverse
from django.http.request import QueryDict

register = template.Library()
@register.simple_tag
def url_tag(request, name, *args, **kwargs):
    # 目标 ：将前往的url?next=/crm/customer_search/?page=2&search=1  将这个进行转化 不然下一次的request请求会以&进行切分
    url = reverse(name, args=args, kwargs=kwargs)  # 待前往编辑的url
    qd = QueryDict(mutable=True)
    qd['next'] = request.get_full_path()  # 将历史url转化放在next
    ret = url + '?' + qd.urlencode(safe='/')  # 待前往的地址 ? next=以前的地址
    print(ret)
    return ret
```

使用：

html中使用 simple_tag

```html
<td><a href="{% url_tag request "crm:customer_edit" q.pk  %}" class="btn btn-danger btn-sm">编辑</a></td>
```

视图中只需要从request中拿到这个next参数就可以

```python
# views.py
next = request.GET.get('next')  
return redirect(next)
```

效果如下：

```
/crm/customer_edit/38?next=/crm/customer_search/%3Fpage%3D2%26search%3D1
```


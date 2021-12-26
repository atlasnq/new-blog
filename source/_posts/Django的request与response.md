---
title: Django的request与response
copyright: true
date: 2019-07-04 21:10:01
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_5_1
---



{% cq %}在系统内部Django使用request和response对象来进行状态的传递。本篇介绍Django中的request对象与response对象 {% endcq %}

<!--more-->

----------------

通过这篇文章，你能了解到：

- request是什么？
- HttpRequest的属性和方法有哪些？
- response是什么？
- HttpResponse的属性和方法有哪些？



# Request对象

当浏览器发出一个请求时，Django创建一个包含request的元信息（metadata）的HttpRequest对象，他作为视图函数的第一个参数。

wsgi 给封装的对象

```
<WSGIRequest: GET '/func/'>
<class 'django.core.handlers.wsgi.WSGIRequest'>
```



## 源码剖析

```python
class HttpRequest(object):
    """A basic HTTP request."""
    ...

class WSGIRequest(http.HttpRequest):
    def __init__(self, environ):
        script_name = get_script_name(environ)
        path_info = get_path_info(environ)
        if not path_info:
            # Sometimes PATH_INFO exists, but is empty (e.g. accessing
            # the SCRIPT_NAME URL without a trailing slash). We really need to
            # operate as if they'd requested '/'. Not amazingly nice to force
            # the path like this, but should be harmless.
            path_info = '/'
        self.environ = environ
        self.path_info = path_info
        ...
```



## 属性

| HttpRequest对象的属性 | 描述                                                         |
| --------------------- | ------------------------------------------------------------ |
| path                  | 表示提交请求页面完整地址的字符串，不包括域名和后面的参数。如 "/music/bands/the_beatles/"。 |
| path_info             | 表示提交请求页面完整地址的字符串，不包括域名和后面的参数。如 "/music/bands/the_beatles/"。 |
| method                | 表示提交请求使用的HTTP方法。如：GET、POST                    |
| GET                   | 一个类字典对象，包含所有的HTTP的GET参数的信息。见 QueryDict 文档。 |
| body                  | 请求体： bytes 类型， get没有请求体                          |
| POST                  | 一个类字典对象，包含所有的HTTP的POST参数的信息。见 QueryDict 文档。<br /> 通过POST提交的请求有可能包含一个空的 POST 字典，也就是说， 一个通过POST方法提交的表单可能不包含数据。因此，不应该使用 if request.POST 来判断POST方法的使用，而是使用 if request.method == "POST" 。提取数据可以使用get方法。<br />request.POST实际上是从request.body提取的，如果request.POST没有值，去request.body进行检查。<br />注意： POST 并 不 包含文件上传信息。见 FILES 。 |
| COOKIES               | 一个标准的Python字典，包含所有cookie。键和值都是字符串。     |
| FILES                 | 一个类字典对象，包含所有上传的文件。 FILES 的键来自 `<input type="file" name="" />` 中的 name 。 FILES 的值是一个标准的Python字典，包含以下三个键： <br />filename ：字符串，表示上传文件的文件名。 <br />content-type ：上传文件的内容类型。 <br />content ：上传文件的原始内容。 <br />注意 FILES 只在请求的方法是 POST ，并且提交的 `<form>` 包含enctype="multipart/form-data" 时才包含数据。否则， FILES 只是一个空的类字典对象。我们也可以使用ajax来上传文件。 |
| META                  | 一个标准的Python字典，包含所有有效的HTTP头信息。有效的头信息与客户端和服务器有关。<br />CONTENT_LENGTH CONTENT_TYPE QUERY_STRING ：未解析的原始请求字符串。 <br />REMOTE_ADDR ：客户端IP地址。 <br />REMOTE_HOST ：客户端主机名。 <br />SERVER_NAME ：服务器主机名。 <br />SERVER_PORT ：服务器端口号。 <br />在 META 中有效的任一HTTP头信息都是带有 `HTTP_` 前缀的键（把 `-` 变为 `_`），例如： HTTP_ACCEPT_ENCODING <br />HTTP_ACCEPT_LANGUAGE <br />HTTP_HOST ：客户端发送的 Host 头信息。 <br />HTTP_REFERER ：被指向的页面，如果存在的。 <br />HTTP_USER_AGENT ：客户端的user-agent字符串。 <br />HTTP_X_BENDER ： X-Bender 头信息的值，如果已设的话。<br />HTTP_X_CSRFTOKEN：X-CSRFToken  csrf值，常在ajax中使用 |
| user                  | 一个 django.contrib.auth.models.User 对象表示当前登录用户。 若当前用户尚未登录， user 会设为 django.contrib.auth.models.AnonymousUser 的一个实例。可以将它们与 is_authenticated() 区别开：  <br />if request.user.is_authenticated():     <br />    # Do something for logged-in users. <br />else:     <br />    # Do something for anonymous users.  <br />user 仅当Django激活 AuthenticationMiddleware 时有效。 |
| session               | 一个可读写的类字典对象，表示当前session。                    |
| raw_post_data         | POST的原始数据。 用于对数据的复杂处理。                      |
| request.is_ajax       | 判断是否是ajax                                               |



### QueryDict对象

我们平时用的 `request.GET` 和 `request.POST` 都是QueryDict对象，这个对象继承自dict，因此用法跟dict相差无几。其中用得比较多的是get方法和getlist方法。

- get方法：用来获取指定key的值，如果没有这个key，默认返回None。
- getlist方法：如果浏览器上传上来的key对应的值有多个，那么就需要通过这个方法获取。

对于QueryDict详见 [Django-QueryDict]

## 方法

| HttpRequest 的方法      | 描述                                           |
| ----------------------- | ---------------------------------------------- |
| request.get_full_path() | 获取完整的路径信息，包含查询参数，不包含ip端口 |
| request.is_secure()     | HTTPS 返回 True                                |
| request.is_ajax()       | 判断是否是ajax请求                             |





### 例子：文件上传

上传文件注意的事项：

1. form表单的属性 `enctype="multipart/form-data"`
2. input type= 'file'
3. request.FILES.get   类字典对象

```python
# 类字典对象
<MultiValueDict: {'f1': [<InMemoryUploadedFile: 转义.png (image/png)>]}>
```

设置multiple可以上传多个文件

- python代码，从request.FILES这个字典中取出文件对象并写到文件。

```python
class FileUpload(View):
    def get(self, request):
        return render(request, 'file_upload.html')

    def post(self, request):
        print(request.FILES)
        file_obj = request.FILES.get('f1')
        print(file_obj)
        with open(file_obj.name, 'wb') as f:
            for i in file_obj.chunks():
                f.write(i)
        return HttpResponse('ok')
```

chunks方法：

```python
# 源码剖析：
def chunks(self, chunk_size=None):
        """
        Read the file and yield chunks of ``chunk_size`` bytes (defaults to
        ``UploadedFile.DEFAULT_CHUNK_SIZE``).
        """
        if not chunk_size:
            chunk_size = self.DEFAULT_CHUNK_SIZE
            # DEFAULT_CHUNK_SIZE = 64 * 2 ** 10 默认每次读64mb

        try:
            self.seek(0)
        except (AttributeError, UnsupportedOperation):
            pass

        while True:
            data = self.read(chunk_size)
            if not data:
                break
            yield data
```



# response对象



## HttpResponse

- `HttpResponse`类定义在 `django.http` 模块中。

- `HttpRequest`对象由Django自动创建，而`HttpResponse`对象则由程序员手动创建.

- 我们编写的每个视图都要实例化、填充和返回一个`HttpResponse`，
- 后面提到的`render`，`redirect`和`JsonResponse`都将返回`HttpResponse`。



### 属性

HttpResponse.content：响应内容，bytes类型。

HttpResponse.charset：响应内容的编码 

HttpResponse.status_code：响应的状态码





## render

render函数的功能：

- 字符串替换，渲染完成
- 还是以HttpResponse对象进行返回

 

```python
def render(request, template_name, context=None, content_type=None, status=None, using=None):
    """
    Returns a HttpResponse whose content is filled with the result of calling
    django.template.loader.render_to_string() with the passed arguments.
    """
    content = loader.render_to_string(template_name, context, request, using=using)
    return HttpResponse(content, content_type, status)
```



## redirect

参数可以是： 

- 一个模型：将调用模型的`get_absolute_url()` 函数
- 一个视图，可以带有参数：将使用`urlresolvers.reverse` 来反向解析名称
- 一个绝对的或相对的URL，将原封不动的作为重定向的位置。



```python
def redirect(to, *args, **kwargs):
    if kwargs.pop('permanent', False):
        redirect_class = HttpResponsePermanentRedirect
    else:
        redirect_class = HttpResponseRedirect

    return redirect_class(resolve_url(to, *args, **kwargs))
```

```
class HttpResponseRedirect(HttpResponseRedirectBase):
    status_code = 302

class HttpResponsePermanentRedirect(HttpResponseRedirectBase):
    status_code = 301
```

- `self['Location'] = iri_to_uri(redirect_to)`
- 如果没有redirect ，只需要在HttpResponse添加Location属性

```python
class HttpResponseRedirectBase(HttpResponse):
    allowed_schemes = ['http', 'https', 'ftp']

    def __init__(self, redirect_to, *args, **kwargs):
        super(HttpResponseRedirectBase, self).__init__(*args, **kwargs)
        self['Location'] = iri_to_uri(redirect_to)
        parsed = urlparse(force_text(redirect_to))
        if parsed.scheme and parsed.scheme not in self.allowed_schemes:
            raise DisallowedRedirect("Unsafe redirect to URL with protocol '%s'" % parsed.scheme) 
```



### 301与302的区别

临时重定向（响应状态码：302）和永久重定向（响应状态码：301）对普通用户来说是没什么区别的，它主要面向的是搜索引擎的机器人。 

- A页面临时重定向到B页面，那搜索引擎收录的就是A页面。
- A页面永久重定向到B页面，那搜索引擎收录的就是B页面。



## JsonResponse

- 向前端传输数据
- 序列化 + content-type



对于前后端分离，传的是数据，不再是页面了，所以需要新的工具

```python
import json
def get_data(request):
    data = {'status': 0, 'data': {'k1':'v1'}}

    # return HttpResponse(data)   # 只显示key
    return HttpResponse(json.dumps(data), content_type)
```



content-Type ：普通文本，需要进行反序列化

方法一：

响应头加自动反序列化

```
return HttpResponse(json.dumps(data), content_type='application/json')
```

方法二：

```
# ret = HttpResponse(json.dumps(data))
# ret['content-typje'] = 'application/json'
```



```python
from django.http.response import JsonResponse

def get_data(request):
    data = {'status': 0, 'data': {'k1': 'v1'}}

    # 方法二：
    # ret = HttpResponse(json.dumps(data))
    # ret['content-typje'] = 'application/json'		# 告诉浏览器类型，它会帮你反序列化
    # return HttpResponse(data)   # 只显示key
    # return HttpResponse(json.dumps(data), content_type='application/json')	
    return JsonResponse(data)
```

对于非字典需要加safe参数

```python
from django.http.response import JsonResponse

def get_data(request):
    li = [1,2,3]
    return JsonResponse(li,safe=False)
```






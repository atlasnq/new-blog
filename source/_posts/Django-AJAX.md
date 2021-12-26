---
title: Django-AJAX
copyright: true
date: 2019-07-13 15:04:55
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_11_ajax
---



{% cq %} 本篇介绍ajax的概念与用法。 {% endcq %}

<!--more-->

通过这篇文章，你能了解到：

- ajax是什么?
- 传输数据的json
- ajax的两个例子（注册与文件上传）



# 铺垫

## JSON

什么是 JSON ？ 

- JSON 指的是 JavaScript 对象表示法（JavaScript Object Notation）
- JSON 是轻量级的文本**数据**交换**格式**
- JSON 独立于语言 
- JSON 具有自我描述性，更易理解

- 序列化与反序列化是实现方式

下图为python与JavaScript的数据交换。

![json](Django-AJAX/json.jpg)



# ajax

回顾之前用到的请求：

1. 浏览器地址栏输入 get请求
2. a标签 get请求
3. form表单 get/post

它们都是返回一个完整的页面，我们的请求也是同步的。





## 例子1

- 在注册页面，当我们输入用户名，input框失去焦点的时候，对用户名进行判断是否在数据库中重复。如果重复提示用户名重复，不存在提示可以使用



```python
# views.py
def register(request):
    return render(request,'register.html')

def userval(request):
    print(666)
    user = request.POST.get('user',None)
    if user:
        obj = models.User.objects.filter(username=user).first()
        if obj:
            return HttpResponse('该用户名已存在')
        else:
            return HttpResponse('可以使用')
    return HttpResponse('请输入用户名')
```

在 return 返回的时候

- render：返回整个页面  （span标签中也将填充这个页面的代码）

- redirect 去重定向的地址找东西，然后将这个地址的内容返回；如果想让前端跳转的话可以设置  `locaiton.href = res` 

  

```html
# register.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    {% load static %}
</head>
<body>
<input type="text" id="user" placeholder='请输入用户名'>
<span id="user_res"></span>
</body>
<script src="{% static 'jquery.min.js' %}"></script>
<script>
    $('#user').blur(function () {
        $.ajax({
            url:'/userval/',
            type:'post',
            data:{
                'user':$('#user').val()
            },
            success:function (res) {
                $('#user_res').text(res)
            }
            error:function (res) {
                $('#user_res').text(res)
            }
        })
    })
</script>
</html>
```

- 结果返回 Forbidden (CSRF token missing or incorrect.): /register/userval
- 对于ajax提交的POST请求，我们需要通过csrf校验。



## ajax通过django的csrf校验的方式

- 网页中渲染 

  ```
  {% csrf_token %}
  ```

  

### 方式一

- 将这个`csrfmiddlewaretoken`对应的值添加到`data`中

```python
<script>
    $('#user').blur(function () {
        $.ajax({
            url:'/userval/',
            type:'post',
            data:{
                'user':$('#user').val(),
                'csrfmiddlewaretoken':$('[name="csrfmiddlewaretoken"]').val()
            },

            success:function (res) {
                $('#user_res').text(res)
            }
        })
    })
</script>
```

### 方式二

- 将这个`csrfmiddlewaretoken`对应的值添加到`headers`的 `x-csrftoken` 键对应的值中。
- note: 这里是headers不是header哦！！！

```html
<script>
    $('#user').blur(function () {
        $.ajax({
            url:'/userval/',
            type:'post',
            data:{
                'user':$('#user').val(),              
            },
            headers:{
              'x-csrftoken':$('[name="csrfmiddlewaretoken"]').val()
            },
            success:function (res) {
                $('#user_res').text(res)
            }
        })
    })
</script>
```



在这里可能会有个疑问，这个Cookie中的csrftoken值是什么时候有的呢？

- 当我们不设置 &#123;&#37; csrf_token %} 的时候，请求与响应中是没有的。

- 当我们的页面中有  &#123;&#37; csrf_token %} 的时候，在我们发GET请求的时候，响应头中有一个 `Set-Cookie: csrftoken=T30RX7O0E...`。

- 用源码解释：
  
  - 这段代码的重点在于对CSRF_COOKIE_USED的检查，如果没有设置，middleware会直接返回response而不在cookie里设置csrftoken。

```python
# django/middleware/csrf.py
	def process_response(self, request, response):
        if not getattr(request, 'csrf_cookie_needs_reset', False):
            if getattr(response, 'csrf_cookie_set', False):
                return response
        # 如果没有设置，middleware会直接返回response而不在cookie里设置csrftoken。
        if not request.META.get("CSRF_COOKIE_USED", False):
            return response

        # Set the CSRF cookie even if it's already set, so we renew
        # the expiry timer.
        self._set_token(request, response)
        response.csrf_cookie_set = True
        return response
```



## 例子2

使用ajax上传文件

- 从post请求中可以拿出filename这个键值对
- 从request.FILES 可以拿出这个文件

```python
# views.py
def file_recv(request):
    print(request.POST.get('filename'))
    file_name = request.POST.get('filename')
    f1 = request.FILES.get('f1')
    with open(file_name,mode='wb') as f:
        for i in f1.chunks():
            f.write(i)

    return HttpResponse('上传成功')

def upload(request):
    return render(request,'upload.html')
```

- 对于file文件，我们可以创建一个FormData对象（字典），来存放键值对，这个对象的好处是会帮你在headers中加 Content-Type: multipart/form-data;
- 我们还需要加入两个信息：processData:false, contentType:false,来告诉js维持原状，不进行处理。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    {% load static %}
    <script src="{% static 'jquery.min.js' %}"></script>
</head>
<body>
{% csrf_token %}
<input type="file" id="file">
<button id="bt">上传</button>
<span id="re"></span>
</body>
<script>
    $('#bt').click(function () {
        var form = new FormData();
        form.append('filename','xxxx');
        form.append('f1',$('#file')[0].files[0]);
        form.append('csrfmiddlewaretoken',$('[name="csrfmiddlewaretoken"]').val());
        $.ajax({
            url:'/file_recv/',
            type:'post',
            processData:false,  // 不处理数据的编码
            contentType:false,  // 不处理contentType的请求头
            data:form,
            success:function (res) {
                $('#re').text(res)
            }
        })
    })
</script>
</html>
```

note: FormData 只能用post发送，get不行。



例子3：

Ajax与modelform配合使用：

- 再modelform中需要重写 `__init__` 方法来为显示的标签添加 bootstrap 样式。
- 使用 JsonResponse 来进行回复。

```python
# views.py
from django import forms
from django.shortcuts import render, HttpResponse, reverse
from django.http.response import JsonResponse
from app01 import models


class StudentForm(forms.ModelForm):
    class Meta:
        model = models.Student
        fields = "__all__"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for i in self.fields.values():
            i.widget.attrs['class'] = 'form-control'

def student_list(request):
    all_students = models.Student.objects.all()

    form_obj = StudentForm()
    return render(request, 'student_list.html', {'form_obj': form_obj, 'all_students': all_students})

def student_add(request):
    form_obj = StudentForm(request.GET)
    if form_obj.is_valid():
        form_obj.save()
        return JsonResponse({'status': 200, 'url': reverse('student_list')})

    return JsonResponse({'status': 404, "data": form_obj.as_p()})
```



页面中：

- `serialize()` 方法通过序列化表单值，创建 URL 编码文本字符串。然后将这个拼接到 url 的后面即可。

```html
<!--模态框内容 -->
<div class="modal-content">
    <div style="padding: 30px">
        <form class="form-horizontal" id="form_1">
            <div id="as_p">
                {{ form_obj.as_p }}
            </div>
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <button id="sub" type="button" class="btn btn-default">新增</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>

    $('#sub').click(function () {
        console.log($('#form_1').serialize());
        $.ajax({
            url: '/student_add/?'+$('#form_1').serialize(),
            type: 'get',
            processData: false,
            contentType: false,
            {#data: $('#form_1').serialize(),#}
            success: function (data) {
                var status = data.status;
                if (status == 200) {
                    location.href = data.url
                }
                else {
                    var as_p = $('#as_p');
                    as_p.html(data.data)
                }
            }
        })
    })
</script>
```


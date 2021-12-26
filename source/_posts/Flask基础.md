---
title: Flask基础
copyright: true
date: 2019-12-03 15:05:09
tags: [Web前端,Flask,学习笔记]
categories: Flask
comments: true
urlname:  flask_1
---



{% cq %} 本篇介绍flask的路由、视图、模板、使用session保存用户会话信息以及特殊的装饰器 {% endcq %}

<!--more-->

## Flask是什么？

Flask是一个基于Werkzeug和Jinja2的微框架。



## Flask和Django的区别？

```
flask是一个轻量级的框架，内置了：路由 / 视图 / 模板（jinja2）/ cookie / session / 中间件， 可扩展强（第三方组件非常多），例如：wtforms / flask-session / flask-sqlalchemy
django是一个重武器，内置了很多功能方便我们使用，例如：admin / orm / 模板 / form / modelform / session / cookie / 中间件 / 路由 / 缓存 / 信号 / 数据库读写分离 / 分页
```

```
flask 短小精悍可扩展强
django 大而全重武器
```

- django好还是flask好?

  ```
  小程序，flask比较好
  中大型，django比较好
  ```



## 快速入门

```
pip install flask
```

### werkzurg

werkzurg是一个wsgi，本质上提供了socket服务端，用于接受用户请求。

django和flask一样，它们内部都没有实现socket服务端，需要依赖wsgi

- django：wsgiref（python内置的）
- flask：werkzeug

uwsgi：性能最好，flask和django都可以用

ps：这三个就像一个瓶盖~

#### wsgiref实现一个网站

<u>本质上是入口！</u>

```python
from wsgiref.simple_server import make_server

class WSGIHandler(object):

    def __call__(self,environ, start_response):
        start_response('200 OK', [('Content-Type', 'text/html')])
        return [bytes('<h1>Hello, web!</h1>', encoding='utf-8'), ]


if __name__ == '__main__':
    obj = WSGIHandler()
    httpd = make_server('127.0.0.1', 8000, obj)
    httpd.serve_forever()
```

补充：对象加括号执行call方法

####  werkzeug实现一个网站

```python
from werkzeug.wrappers import Response
from werkzeug.serving import run_simple

class Flask(object):
    def __call__(self,environ, start_response):
        return Response('Hello World!')(environ, start_response)


if __name__ == '__main__':
    app = Flask()
    run_simple('127.0.0.1', 5000, app)
```



### flask程序

```python
from flask import Flask

# 实例化一个Flask对象
app = Flask(__name__)

# 添加路由关系
@app.route('/index')
def index():
    return '你好'

if __name__ == '__main__':
    # 启动服务端，入口
    app.run() 
```

程序很简单，但在背后我们用到了`werkzeug` ，它是整个程序的入口

```python
from werkzeug.serving import run_simple
	try:
    	run_simple(host, port, self, **options)
	finally:
		self._got_first_request = False
```



## flask用户登录示例

```python
from flask import Flask,render_template,request,redirect

app = Flask(__name__)

@app.route('/login',methods=['GET','POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')
    user = request.form.get('user')
    pwd = request.form.get('pwd')
    if user == 'aaa' and pwd == '123':
        # return redirect('https://www.baidu.com')
        # 在session中存储一个值
        session['user_info'] = user

        return redirect('/index')
        # return redirect(url_for('n2'))  # 反向解析
        # return redirect(url_for('index'))  # 不写endpoint的话，默认是函数名
    return render_template('login.html', error="'用户名或密码错误'")


if __name__ == '__main__':
    app.run()
```



关于返回值

```python
return 'xxx'           			# HttpResponse
return render_template('模板文件',参数)   # render
return redirect('...')  		# redirect
return jsonify({'k1':123})  	# JsonResponse
```



关于模板

```
默认放在根目录的templates文件夹下
```

关于用户请求

django和flask对于请求的处理是不同的：

- django会将用户请求封装成request对象，然后再不断的传递。
- flask会将用户请求放在一个地方，谁用谁去拿。

```python
request.method 	# request.method
request.form 	# request.POST
request.args 	# request.GET
```

关于模板语法

```
jinja2 语法上更像python，比django的模板语法有更多的写法。
```



关于反向解析

```
不写endpoint的话，默认是函数名
	url_for('index')
可以在@app.route中添加 endpoint='n1'
	url_for('n1')
```



关于session

```
默认：将用户名与secret_key进行加密后，存放在了用户浏览器的cookie中
```



关于权限认证（在flask视图中添加装饰器）

- 位置route的下面
- 记得加functools.wraps(...)  保留函数的元信息

```python
from flask import Flask, render_template, request, redirect, url_for, session

app = Flask(__name__)
app.secret_key = 'jsdfojsaodjfoisdj15ad165wa'


@app.route('/login', methods=['GET', 'POST'], endpoint='n1')
def login():
    if request.method == 'GET':
        return render_template('login.html')
    user = request.form.get('user')
    pwd = request.form.get('pwd')
    if user == 'aaa' and pwd == '123':
        # return redirect('https://www.baidu.com')
        # 在session中存储一个值
        session['user_info'] = user

        return redirect('/index')
        # return redirect(url_for('n2'))  # 反向解析
        # return redirect(url_for('index'))  # 不写endpoint的话，默认是函数名
    return render_template('login.html', error="'用户名或密码错误'")


import functools

def login_check(func):
    @functools.wraps(func)  # 保证函数名不在是相同的 inner。
    def inner(*args, **kwargs):
        user = session.get('user_info')
        print(666)
        if not user:
            return redirect('/login')
        return inner(*args, **kwargs)

    return inner


@app.route('/index')
@login_check
def index():
    user_list = ['小明', '小花', '小张', '小强', '小小']
    user_info_list = [
        {'name': '小明', "age": 18},
        {'name': '小花', "age": 19},
        {'name': '小张', "age": 20},
        {'name': '小强', "age": 21},
        {'name': '小小', "age": 22},
    ]
    return render_template('index.html', user_list=user_list, user_info_list=user_info_list)


@app.route('/order')
@login_check
def order():
    return '订单'


if __name__ == '__main__':
    app.run()
    
'''
@functools.wraps(func)  是非常好的解决方法，除此之外，我们还可以在每个route内写endpoint参数。
'''
```



特殊的装饰器

```
before_request 是按注册顺序，顺序执行
after_request 是按注册顺序，逆序执行（源码中对列表进行一个reverse）
```

代码示例：

```python
from flask import Flask, render_template, request, redirect, url_for, session

app = Flask(__name__)
app.secret_key = 'jsdfojsaodjfoisdj15ad165wa'

@app.before_request
def f1():
    print('f1')

@app.before_request
def f11():
    print('f11')


@app.after_request
def f2(response):
    print('f2')
    return response

@app.after_request
def f22(response):
    print('f22')
    return response

@app.route('/login', methods=['GET', 'POST'])
def login():
    print('login')
    return 'login'


@app.route('/index')
def index():
    print('index')
    return 'index'


if __name__ == '__main__':
    app.run()
```



## 总结

1. flask请求的声明周期
   1. wsgi：werkzeug模块
   2. before_request
   3. 视图（业务/模板的处理）
   4. after_request
2. 连接MySQL数据库，自己写pymysql
3. 装饰器的应用场景
4. django与flask的区别？ **
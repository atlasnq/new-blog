---
title: Flask相关（blueprint、DBUtils、wtforms）
copyright: true
date: 2019-12-05 15:06:03
tags: [Web前端,Flask,学习笔记]
categories: Flask
comments: true
urlname:  flask_2
---



{% cq %} 本篇介绍Flask相关的blueprint、DBUtils、wtforms {% endcq %}


<!--more-->

## 蓝图blueprint

- 帮助我们对目录结构进行划分，类似于django中的app

结构如下：

```python
crm 
	crm		
        static
        templates
        views
        utils
        forms
	__init__.py
	manage.py
```

在 `__init__.py`下

```python
from flask import Flask
from .views.user import user
from .views.account import account

def create_app():
	app = Flask(__name__)
    
    @app.before_request
    def f1():
    	'''全局的'''
        print('f1')
    
    app.register_blueprint(user,url_prefix='/x1')
    app.register_blueprint(account)
    
    return app
```

在 manage.py 中

```python
from crm import create_app

app = create_app()

if __name__ == '__main__':
    app.run()
```

在views文件夹下的account.py下

```python
from flask import Blueprint,url_for

# 创建了一个蓝图对象,注意，这个名字不要和下面的名字重名！
account = Blueprint('account',__name__)

@account.before_request
    def xx():
    	'''局部的'''
        print('xx')

@user.route("/login")
def login():
    url  = url_for('account.register')
    print(url)
    return 'login'

@user.route("/register")
def register():
    return 'register'
```

在views文件夹下的user.py下

```python
from flask import Blueprint

# 创建了一个蓝图对象,注意，这个名字不要和下面的名字重名！
user = Blueprint('user',__name__)


@user.route("/user/list")
def user_list():
    return 'user_list'

@user.route("/user/add")
def user_add():
    return 'user_add'
```



除了为我们实现了目录的划分，还有其它的改变：

关于before_request

- django中的process_request，只能批量。而蓝图这里就细致了，可以只在当前的蓝图对象中生效。

关于url_for

- 蓝图名.endpoit

把全局的before_request拿到外面去

```python
from flask import Flask
from .views.user import user
from .views.account import account

def before():
    	'''全局的'''
        print('before')

def create_app():
	app = Flask(__name__)
    
    '''
    @app.before_request
    def f1():
    	'''全局的'''
        print('f1')
    '''
    app.before_request(before)
    
    app.register_blueprint(user,url_prefix='/x1')
    app.register_blueprint(account)
    
    return app
```



## 数据库连接池

### 为什么要使用?

- 不用连接池的话，大量的开销花费在数据库的连接与关闭上，大大降低了效率。

### 安装

```python
pip install DBUtils
```

本身没有，需要使用操作数据库的模块，如pymysql



### 关于数据库连接池

- maxconnections上限怎么办？
  - block： True等待；False主动报错
- mincached：
  - 与数据库保持的最小连接数量
- `conn = POOL.connection()`
  - 从数据库连接池中获取一个连接
- `conn.close()`：
  - 并不是真正的关闭，而是将此连接放还给连接池



### 代码实现

本质：**类 + 单例模式**

下面定义了 **SQLHelper** ，它封装了数据库操作的相关方法，以便之后业务功能调取。

```python
import pymysql

from DBUtils.PooledDB import PooledDB

class SQLHelper(object):
    def __init__(self):
        # 创建数据库连接池
        self.pool = PooledDB(
            creator=pymysql,
            maxconnections=5,
            mincached=2,
            blocking=True,
            host='127.0.0.1',
            port=3306,
            user='root',
            password='123',
            database='test',
            charset='utf8'
        )


    def connect(self):
        conn = self.pool.connection()
        cursor = conn.cursor()
        return conn,cursor


    def disconnect(self,conn,cursor):
        cursor.close()
        conn.close()


    def fetchone(self,sql,params=None):
        """
        获取单条
        :param sql:
        :param params:
        :return:
        """
        if not params:
            params = []
        conn,cursor = self.connect()
        cursor.execute(sql, params)
        result = cursor.fetchone()
        self.disconnect(conn,cursor)
        return result


    def fetchall(self,sql,params=None):
        """
        获取所有
        :param sql:
        :param params:
        :return:
        """
        import pymysql
        if not params:
            params = []
        conn, cursor = self.connect()
        cursor.execute(sql,params)
        result = cursor.fetchall()
        self.disconnect(conn, cursor)
        return result


    def commit(self,sql,params):
        """
        增删改
        :param sql:
        :param params:
        :return:
        """
        import pymysql
        if not params:
            params = []

        conn, cursor = self.connect()
        cursor.execute(sql, params)
        conn.commit()
        self.disconnect(conn, cursor)


db = SQLHelper()
```

```python
from flask import Blueprint,url_for,request,render_template,session,redirect
from ..utils.sqlhelper import db

# 创建了一个蓝图对象
account = Blueprint('account',__name__)


@account.route('/login',methods=['GET','POST'])
def login():

    if request.method == 'GET':
        return render_template('login.html')
    user = request.form.get('user')
    pwd = request.form.get('pwd')

    # 根据用户名和密码去数据库进行校验
    # 连接/SQL语句/关闭
    result = db.fetchone('select * from user where username=%s and password=%s',[user,pwd])
    if result:
        # 在session中存储一个值
        session['user_info'] = user
        return redirect(url_for('user.user_list'))
    return render_template('login.html',error="用户名或密码错误")
```



## wtforms

对用户提交的数据进行格式校验. (类似于 django form)

```
pip install wtforms
```



### forms示例

```python

from wtforms import Form
from wtforms.fields import simple
from wtforms import validators
from wtforms import widgets
from wtforms.fields import core
from wtforms.fields import html5


class LoginForm(Form):
    username = simple.StringField(
        label='用户名',
        validators=[
            validators.DataRequired(message='用户名不能为空'),
            validators.Length(min=6, max=18, message='用户名长度必须大于%(min)d且小于%(max)d')
        ],
        widget=widgets.TextInput(),
        render_kw={'class': 'form-control'}

    )
    password = simple.PasswordField(
        label='密码',
        validators=[
            validators.DataRequired(message='密码不能为空.'),
            validators.Length(min=8, message='用户名长度必须大于%(min)d'),
            # validators.Regexp(regex="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])[A-Za-z\d$@$!%*?&]{8,}",
            #                   message='密码至少8个字符，至少1个大写字母，1个小写字母，1个数字和1个特殊字符')

        ],
        widget=widgets.PasswordInput(),
        render_kw={'class': 'form-control'}
    )



class RegisterForm(Form):
    name = simple.StringField(
        label='用户名',
        validators=[
            validators.DataRequired()
        ],
        widget=widgets.TextInput(),
        render_kw={'class': 'form-control'},
        default='alex'
    )

    pwd = simple.PasswordField(
        label='密码',
        validators=[
            validators.DataRequired(message='密码不能为空.')
        ],
        widget=widgets.PasswordInput(),
        render_kw={'class': 'form-control'}
    )

    pwd_confirm = simple.PasswordField(
        label='重复密码',
        validators=[
            validators.DataRequired(message='重复密码不能为空.'),
            validators.EqualTo('pwd', message="两次密码输入不一致")
        ],
        widget=widgets.PasswordInput(),
        render_kw={'class': 'form-control'}
    )

    email = html5.EmailField(
        label='邮箱',
        validators=[
            validators.DataRequired(message='邮箱不能为空.'),
            validators.Email(message='邮箱格式错误')
        ],
        widget=widgets.TextInput(input_type='email'),
        render_kw={'class': 'form-control'}
    )

    gender = core.RadioField(
        label='性别',
        choices=(
            (1, '男'),
            (2, '女'),
        ),
        coerce=int   # 对于整型必须进行转化（接收到的都是字符串）
    )
    city = core.SelectField(
        label='城市',
        choices=(
            ('bj', '北京'),
            ('sh', '上海'),
        )
    )

    hobby = core.SelectMultipleField(
        label='爱好',
        choices=[],
        coerce=int  
    )

    favor = core.SelectMultipleField(
        label='喜好',
        choices=(
            (1, '篮球'),
            (2, '足球'),
        ),
        widget=widgets.ListWidget(prefix_label=False),
        option_widget=widgets.CheckboxInput(),
        coerce=int,
        default=[1,]
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # self.hobby.choices = db.fetchall('select id,name from hobby',cursor=None)
        self.hobby.choices = ((1, '篮球'), (2, '足球'), (3, '羽毛球'))

    def validate_name(self, field):
        """
        自定义pwd_confirm字段规则，例：与pwd字段是否一致
        :param field:
        :return:
        """
        # 最开始初始化时，self.data中已经有所有的值
        """
        if field.data != self.data['pwd']:
            # raise validators.ValidationError("密码不一致") # 继续后续验证
            raise validators.StopValidation("密码不一致")  # 不再继续后续验证
        """
        if len(field.data) < 8:
            # raise validators.ValidationError("用户名太短了")
            raise validators.StopValidation("用户名太短了")

```



### 登录示例

```python
from flask import Blueprint,url_for,request,render_template,session,redirect
from ..utils.sqlhelper import db
from ..forms.account import LoginForm,RegisterForm

# 创建了一个蓝图对象
account = Blueprint('account',__name__)


@account.route('/login',methods=['GET','POST'])
def login():

    if request.method == 'GET':
        form = LoginForm()
        return render_template('login.html',form=form)

    form = LoginForm(formdata=request.form)
    if not form.validate():
        return render_template('login.html', form=form)

    # 数据库校验
    result = db.fetchone('select * from user where username=%s and password=%s',
                         [form.data['username'], form.data['password']])
    if result:
        # 在session中存储一个值
        session['user_info'] = form.data['username']
        return redirect(url_for('user.user_list'))

    return render_template('login.html', form=form, error="用户名或密码错误")
```



### 注册示例

```python
@account.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'GET':
        # result = db.fetchone('......')
        result = {'name':'数据库中的name',"hobby":[1]}
        # form = RegisterForm(data=result)
        form = RegisterForm()
        return render_template('register.html', form=form)

    form = RegisterForm(formdata=request.form)
    if form.validate():
        print('用户提交数据通过格式验证，提交的值为：', form.data)
        return '校验成功'

    return render_template('register.html', form=form)
```



钩子函数的作用：输入用户名后，查一下用户名是否存在

两种异常：

- `ValidationError` 后续还可以认证
- `StopValidation` 当前字段的后续得校验器不会再使用了，跳到下一个字段



### 知识点

- 定义类

  - 定义字段（label/validate/default/choices）
  - 钩子函数
  - 重写 `__init__` 在 init中去数据库中获取数据并赋值 self.hobby.choices = ...

- 使用类

  - form = Form() , 默认只展示标签

  - form = Form(data={'name':'xx'})，显示标签 + 默认值（用于编辑） 

  - form = Form(formdata=request.form)，接收用户提交的数据，进行校验

    ```python
    if form.validate():
    	form.data
    else:
    	form.errors
    ```



## 今日总结

蓝图

```
面试题：flask蓝图和django得app有什么区别？
	- 相同：
		可以做业务得划分，django可以将不同业务放到不同app中，flask放在蓝图中。
		使用时，都需要注册
		支持在URL中添加前缀
	- 不同点：
		django得app比flask蓝图涵盖得东西更多，models（***），templates（蓝图对象中可以添加参数），static（蓝图对象中可以添加参数）
		url反向解析得时候，flask必须要加蓝图为前缀；django和app无关
		before_request得粒度可以细到蓝图
```

1. DBUtils

2. wtforms

3. flask相关问题

   你都用过flask相关得哪些组件？

   ```
   DBUtils
   wtforms
   ```

   
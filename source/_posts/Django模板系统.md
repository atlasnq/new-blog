---
title: Django模板系统
date: 2019-07-01 22:23:03
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_3
copyright: true
---



{% cq %}本篇介绍Django的模板语言（The Django template language）。 {% endcq %}

<!--more-->

--------------

通过这篇文章，你能了解到：

- 模板是什么?
- 变量与过滤器
- 使用**标签**来执行一段逻辑
- 自定义过滤器，simple_tag，inclusion_tag
- 使用**模板继承**和**组件**来简化代码



# 模板

模板只是一个text文件，他可以生成任意基于文本的格式（HTML,XML,CSV等）。

模板中包含**变量**，这些变量在评估模板时将替换为值，而**变量**则包含控制模板逻辑的**标记**。

Django模板中只需要记两种特殊符号：

- &#123;&#123;  &#125;&#125;   和  &#123; &#37;  &#37; &#125;

- &#123;&#123;   &#125;&#125;  表示变量
-  &#123; &#37;  &#37; &#125; 表示逻辑相关的操作。



推荐阅读 [官方文档](https://docs.djangoproject.com/en/1.11/ref/templates/language/) 。



# 变量

&#123;&#123;  变量名（key）&#125;&#125;     --->   v

变量名由字母数字和下划线组成，*变量名称中不能包含空格或标点符号*。 

点 `.` 在模板语言中有特殊的含义，遇到一个点时，会按以下顺序去查找：

1. 字典查找

2. 属性或方法查找 (方法不能带参数)

3. 数字索引查找

这个顺序体现在：

```python
dic = {
    'cc':'gg'
    'keys':'xxxxx',
}
```

```html
{{ dic.keys }}  # 显示 xxxxx , 而不是dict_keys(['cc']) 
```

note：

- 没有 `[]` 这种写法。所以对于列表的话就没有`[index]` 而是`.index` 、对于字典的话就没有 `[key]` 而是 `.key`
- 没有 `()` 这种写法，所以对于方法是不需要加括号的，不识别括号
- 索引只能是正向索引，负数识别不了



```python
# views.py
# 几个例子：
def index(request):
    num = 1
    string = '哈哈哈'
    li = [1, 2, 3]
    dic = {
        'n': 1,
        'st': 'st',
        'li': [4, 5, 6],
        'dic': {
            'name': '小黑',
            'age': 18,
        }
    }
    context = {
        'num': num,
        'string': string,
        'li': li,
        'dic': dic,    
    }
    return render(request, 'index.html', context)
```

```html
# index.html
{{ num }}
<br>
{{ string }}
<br>
{{ li }}
{{ li.0 }}			# 通过 . 来得到该索引的值
{#{{ li.-1 }}#}		# 负数索引是无法解析的
<br>
{{ dic }}
{{ dic.n }}			# 通过 . 得到键对应的值
{{ dic.keys }}		# 通过 . 调用方法
{{ dic.values }}	

{{request}}     	# 模板中可以直接使用request
```

note：**模板中可以直接使用request**

# Filters

使用**过滤器**修改变量的显示结果。

语法： 

-  &#123;&#123; value|filter_name&#125;&#125;、&#123;&#123; value|filter_name:参数&#125;&#125;  过滤器最多只有一个参数！

- &#123;&#123; text|escape|linebreaks &#125;&#125;  可以一次使用多个管道符

note: 只有 `:` 左右不能有空格，不能有空格！



## default

- 提供默认值
- 如果传过来的变量不存在/或为空，也可以用default，来进行显示。

- 如果使用不存在的变量，模板系统将插入 `string_if_invalid` 选项的值，默认情况下设置为（空字符串）。

```html
# index.html
<p>{{ qq }}</p>  
{#如果没有这个key，就转成一个空的字符串了#}      

{{ x }}		# None
{{ y }}		# ''
{{ z }}		# []
{{ d }}		# {}
{{ qq|default:'lalala' }}	# 虽然设置了default，但还是依照string_if_invalid，显示：'找不到'
{{ x|default:'Nothing' }}	# Nothing
{{ y|default:'String' }}	# String
{{ z|default:'List' }}		# List
{{ d|default:'Dict' }}		# Dict
# 对于None、''、[]、{}会使用default来代替
```



修改setting.py 的 OPTIONS ， 当这个传递的变量在`views.py`中没有定义，就是用默认值

如果 default 与 它一起，还是显示"找不到"。

```python
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')]
        ,
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
            'string_if_invalid':'找不到'
        },
    },
]
```



## slice

切片：参数和以前使用方式是一样的。

```html
# index.html
{{ name_list|slice:'-1::-1' }}
```



## filesizeformat

将值格式化为一个 “人类可读的” 文件尺寸 （例如 '1KB', '4.1 MB', '102 bytes' 等等）

```python
context = {
    'filesize': 1 * 1024 * 1024 * 1024
}
return render(request, 'index.html', context)
```



```html
# index.html
{{ 5|filesizeformat }}      	# 5 bytes
{{ filesize|filesizeformat }}	# 1.0 GB 
```



## add

- 数字的加法
- 字符串拼接
- 列表拼接

```html
{{ '1'|add:'3' }}				# 数字的加法（可以同时是字符串）
{{ 1|add:'3' }}		
{{ string|add:'3' }}   			# 字符串的拼接（字符串与字符串）
{{ name_list|add:name_list }}	# 列表的拼接（左右是列表）
```



## lower/upper/title

- 小写
- 大写
- 标题

```python
context = {
        'st': 'HeLLo',
    }
    return render(request, 'index.html', context)
```



```php+HTML
{{ st }}			# HeLLo
{{ st|upper }}		# HELLO
{{ st|lower }}		# hello
{{ st|title }}		# Hello 
{{ st.title }}    # 当然对于字符串我们可以使用它本身的方法
```



## ljust/rjust/center

- 左对齐
- 右对齐
- 居中

```html
{{ st|ljust:"15" }}
{{ st|rjust:"15" }}
{{ st|center:"15" }}
```

note：但是由于HTML会有空白折叠，所以很鸡肋。

结果只是显示：

```
HeLLo HeLLo HeLLo 
```



## length/length_is

- {{ value|length }} 返回 value 的长度

```html
{{ st|length }}			# 5
{{ st|length_is:4 }}	# False
{{ st|length_is:5 }}	# True
{{ st|length_is:6 }}	# False
```



## first/last

- 取第一个/最后一个元素

- 不用 `.0` 或 `.-1` 方式是因为找不到的话会调用`string_if_invalid`

- `.first`  和 `.last` 在找不到的话，显示为空

```python
li = []
```



```html
{{ li.0 }}			# 找不到 	
{{ li|first }}		# 显示为空
{{ li|last }}		# 显示为空
```



## join

使用字符串拼接列表。同 python 的 `str.join(list)`

```html
{{ name_list|join:'--' }}
```



## truncatechars

如果字符串字符多于指定的字符数量，那么会被截断。截断的字符串将以可翻译的省略号序列（“...”）结尾。（三个点也算在内）

truncatechars:3 三个点 

truncatechars:1 三个点 

```python
context = {        
        'value': '如果字符串字符多于指定的字符数量，那么会被截断。截断的字符串将以可翻译的省略号序列',
    }
    return render(request, 'index.html', context)
```



```html
{{ value|truncatechars:9 }}			# {{ value|truncatechars:9 }}
```



## truncatewords

按空格截断，有几个空格截几次。

```html
{{ value|truncatewords:2 }}
```



## date

- 日期格式化：`'Y-m-d H:i:s'`

- [其余格式](https://docs.djangoproject.com/en/1.11/ref/templates/builtins/#date) 
- note：字符串中写的规则和python的datetime模块中是不一样的，不需要加 `%`，而且有些字母表示也不一样。

```python
    context = {
        'datetime_now': datetime.datetime.now(),
    }
```

```html
{{ datetime_now|date:'Y-m-d H:i:s' }}
```



### 设置显示格式

settings中可以配置，配置后，就会设置显示格式：

```python
USE_L10N = False   # 使这个设置生效
DATETIME_FORMAT = 'Y-m-d H:i:s'	# 不写过滤器的时间按这个格式	{{ datetime_now }}	
DATE_FORMAT = 'Y-m-d'			# date格式 {{ datetime_now|date }}	
TIME_FORMAT = 'H:i:s'			# time格式 {{ datetime_now|time }}	
```



```html
{{ datetime_now }}						# 2019-08-28 17:24:18 
<br>
{{ datetime_now|date }}					# 2019-08-28 
<br>
{{ datetime_now|time }}					# 17:24:18 
<br>
{{ datetime_now|date:'Y-m-d H:i:s'}}	# 2019-08-28 17:24:18 
```



## safe

### 背景

- XSS：跨站脚本攻击(Cross Site Scripting)，为了不和层叠样式表(Cascading Style Sheets,
  CSS)的缩写混淆，故将跨站脚本攻击缩写为XSS。恶意攻击者往Web页面里插入恶意Script代码，当用户浏览该页之时，嵌入其中Web里面的Script代码会被执行，从而达到恶意攻击用户的目的。

- Web存在XSS跨站脚本攻击，所以为了安全，Django中的每个模板都会自动转义每个变量标记的输出。
- 例如：评论中，写的代码，需要进行**转义**，不然的话展示页面的时候会自动执行！
- 转义：就是把html语言的关键字过滤掉。例如Django中这5个字符被转义为HTML实体，防止浏览器将其作为HTML元素：
  - `<` 转换为 `&lt;`
  - `>` 转换为 `&gt;`
  - `'` （单引号）转换为 `&#39;`
  - `"` （双引号）转换为 `&quot;`
  - `&` 转换为 `&amp;`
- 推荐阅读 [DOMXSS典型场景分析与修复指南](https://security.tencent.com/index.php/blog/msg/107)



### safe

- 告诉django不需要做转义，可以执行。

```python
context = {        
        'js': "<script> alert(666) </script>",    	
    }
return render(request, 'index.html', context)
```



```html
{{ js }}		# 默认使转义
{{ js|safe }}	# 使用了safe，就变成一个js脚本并执行
```



上面是在模板中标记安全，还可以在views.py 中标记安全

```python
from django.utils.safestring import mark_safe
context = {     
    	'js1': mark_safe('<script> alert(666) </script>'),
    }
return render(request, 'index.html', context)
```

```html
{{ js1 }}		# 执行js代码
```



推荐阅读：[其它过滤器](https://docs.djangoproject.com/en/1.11/ref/templates/builtins/#built-in-filter-reference)



## 自定义filter

自定义过滤器步骤：

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

4. 在这个文件内定义函数

   ```python
   def new_upper(value,arg=None):   # arg最多有一个
   	return value.upper()	
   ```

5. 给函数加上装饰器就成为了过滤器

   ```python
   # @register.filter(name='xxx') 	# 加上(name='xxx')，就改变了最终过滤器的名字。
   @register.filter
   def new_upper(value,arg=None):  
   	return value.upper()	
   ```

在模板中使用：

```python
导入：
	{% load my_tags %}
使用过滤器：
	{{ 'asd'|new_upper }}    
```



# Tags

## 注释(Comments)

- 这里的注释表示不会再浏览器中渲染的，而js或html的注释还是会进行渲染的。

```html
{# ... #}
```



## widthratio

- 计算乘除

```
{% widthratio 200 1 5 %}    # 200/1*5 = 1000
<br>
{% widthratio 200 5 1 %}	# 200/5*1 = 40
```



## for

```html
<ul>
    {% for n in li %}
    	{{ forloop }}
        <li>{{ n }}</li>
    {% endfor %}
</ul>
```



### forloop字典：

forloop是一个字典：

```
{'parentloop': {}, 'counter0': 0, 'counter': 1, 'revcounter': 5, 'revcounter0': 4, 'first': True, 'last': False} 
```



| key                   | Description                          |
| --------------------- | ------------------------------------ |
| `forloop.counter`     | 当前循环的索引值（从1开始）          |
| `forloop.counter0`    | 当前循环的索引值（从0开始）          |
| `forloop.revcounter`  | 当前循环的倒序索引值（到1结束）      |
| `forloop.revcounter0` | 当前循环的倒序索引值（到0结束）      |
| `forloop.first`       | 当前循环是不是第一次循环（布尔值）   |
| `forloop.last`        | 当前循环是不是最后一次循环（布尔值） |
| `forloop.parentloop`  | 本层循环的外层循环                   |



例子：使偶数行偶数列对应的元素的背景变为红色

- 内层循环决定列，外层循环决定行

- 模板内使用 `divisibleby` 表示能否整除，从而选出偶数列。

```html
<table>
    <tbody>
    {% for i in l2 %}
        <tr>
            {% for j in i %}
                {% if forloop.counter|divisibleby:2 and forloop.parentloop.counter|divisibleby:2 %}
                    <td style="border: 1px solid; background-color: red">{{ j }}</td>
                {% else %}
                    <td style="border: 1px solid">{{ j }}</td>
                {% endif %}
            {% endfor %}
        </tr>
    {% endfor %}
    </tbody>
</table>
```



## for ... empty

```
{% for i in ll %}
	{i}
{% empty %}
	空的数据
{% endfor %}
```



## if、elif、else

`<`等比较符 左右必须有个空格

```
{% if p1.age < 18 %}     
	他还是个弟弟
{% elif p1.age == 18 %}
	刚成年，可以出家
{% else %}
	骚老头子，坏得很
{% endif %}
```

note：

- 条件中可以加过滤器，但是不能嵌套标签。
- 条件中不支持 **算数运算**
- 条件中不支持 %**取余**  -->  过滤器  divisibleby:2  能否被2整除
- 条件中也不支持**连续判断**  a > b >c -->  a > b and a < c    是可以的
  - python的连续判断：10>5>1   True(10>5) and True(5>1)
  - js的连续判断： 10>5==1   True(10>5)==1
  - 条件中如果写了连续判断，虽然会飘红，但逻辑和js的连续判断相同
- if语句支持 and 、or、==、>、<、!=、<=、>=、in、not in、is、is not判断。

```
{% if 10>5>1 %}
真
{% else %}
假
{% endif %}
# 结果为 假
```



## with

- 定义一个中间变量

```html
{{person_list.1.name}}
{{person_list.1.name}}
{{person_list.1.name}} 
# 以上使用太麻烦了 ☝
# 方式一： as
	{% with person_list.1.name as hei %}
	{{hei}}
	{% endwith %}
# 方式二： =
	{% with bai=person_list.1.name %}
	{{bai}}
	{% endwith %}
# 定义多个中间变量
	{% with bai=person_list.1.name age=person_list.1.age %}
	{{age}}
	{% endwith %}
```



## csrf_token

### 背景

- csrf：跨站请求伪造

- 要抵御 CSRF，关键在于在请求中放入黑客所不能伪造的信息，并且该信息不存在于cookie 之中。可以在 HTTP 请求中以参数的形式加入一个随机产生的 token，并在服务器端建立一个拦截器来验证这个 token，如果请求中没有token 或者 token 内容不正确，则认为可能是 CSRF 攻击而拒绝该请求。

- 在Django中，服务器会给客户端发送带有 csrf_token 的表单，如果回执中没有这个 csrf_token ，则不做接收。

### 使用

```
<form action="" method="post">	
	{% csrf_token %}
</form>
```

- 标签放在form标签中，form表单中有一个隐藏的标签 name = 'csrfmiddlewaretoken' value 



## 关于静态文件配置

如果在配置中将 `/static/` 给变了，那么按照以前的方式，都该改变导入的前缀。

为了更加灵活，我们将这样做

- 标签

```
{% load static %}
{% static '相对路径'%} 
方法一：
"{% static 'css/dashbord.css'%}" 
# 加载这个static.py文件，调用这个文件的static函数，给相对路径，返回绝对路径。
```

```
{% get_static_prefix %}   # 获取静态文件前缀
方法二：
href="{% get_static_prefix %}css/dashbord.css"
```



## 补充

```
{% url 'home' %}
```

当我们在url中设置name参数为 home，就可以反向解析。

详见 [Django的路由系统](https://atlasnq.github.io/django/20190705-django_6_url.html)



# 自定义tag

## simple_tag

- 优：和自定义filter相比，可以定义更多的参数
- 缺：他是一个tag，不能嵌套

```python
@register.simple_tag
def join_str(*args,**kwargs):
	return '_'.join(args) + '-' + "*".join(kwargs.values())
```

```
{% join_str 'v1' 'v2' k3='v3' k4='v4' %}
```

note：要用空格隔开



## inclusion_tag

- **组件**虽然细粒度，但它不能灵活的使用变量
- `inclusion_tag` 可以返回一个动态的页面，是一个不错的选择

```python
@register.inclusion_tag('page.html')
def page():
	return {}
目前这样写和组件一样

# 自制分页
@register.inclusion_tag('page.html')
def page(num):
	return {'num':range(1,num+1)}    # 这个字典是传给page.html的参数
```

- 分页的html，由于页数是可变的，这需要传参得到，context充当这个运输工具。

```html
{# page.html #}
<nav aria-label="Page navigation">
    <ul class="pagination">
        <li>
            <a href="#" aria-label="Previous">
                <span aria-hidden="true">&laquo;</span>
            </a>
        </li>
        {% for i in num %}
            <li><a href="#">{{ i }}</a></li>
        {% endfor %}
        <li>
            <a href="#" aria-label="Next">
                <span aria-hidden="true">&raquo;</span>
            </a>
        </li>
    </ul>
</nav>
```

- 这样在使用的时候先load，再写tag标签即可，这这个html就加入了分页！

```html
# author_list.html       
{% load my_tags %}
{% my_page 3 %}
```



## 定义 filter  simple_tag  inclusion_tag 

### 相同的步骤

1. 先做**app01**下创建一个python包，名为 `templatetags` 

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
   @register.filter
   def show_a_plus(value, arg=None):	# arg最多有一个
       return mark_safe(f"<a href='value'>{arg}</a>")
   
   @register.simple_tag()
   def join_str(*args, **kwargs):		# 参数多少都可以
       return '_'.join(args) + '-' + '*'.join(kwargs.values())
   
   @register.inclusion_tag('page.html')	# 这里必须指定模板
   def page(num):
   	return {'num':range(1,num+1)} 
   ```

   

### 不同点

参数：

- 自定义filter的参数数量是有限的
- inclusion_tag 后必须加模板的名字
- simple_tag无限制

返回值：  

- inclusion_tag 的返回值必须是一个字典 ，相当于render的第三个参数，做渲染
- 自定义filter 和 simple_tag对返回值没有限制

inclusion_tag 多了一步渲染的过程 ，另外两个至少是做一个返回。

过滤器可以放在 if 判断中，tag不行。



# 模板继承

- Django模板引擎中最强大、最复杂的是模板继承。模板继承允许您构建一个基础“骨架”**模板**，其中包含站点的所有常用元素，并定义子模板可以覆盖的**块**。

## 模版：

1. html页面，提取多个页面的公共部分
2. 定义多个 block  块，需要让子页面覆盖填写

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="x-ua-compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Title</title>
  {% block page-css %}
  	子代导入自己的样式
  {% endblock %}
</head>
<body>

<h1>这是母板的标题</h1>

{% block page-main %}
	子代自己的部分
{% endblock %}
<h1>母板底部内容</h1>
{% block page-js %}
	子代导入自己的样式
{% endblock %}
</body>
</html>
```

继承:

1. &#123; &#37;  entends '模板文件名' &#37; &#125;

2. 重写 block 来覆盖母版。

note：

- block可大可小，可以是一个table，form，可以是一个属性（字符串）。

- `'模板的文件名'` 是一个字符串（值），如果不加引号，就会当成一个变量
- extends 上面不要写入其它内容，extends前面写入内容，是会在html页面内显示的，如果写在后面且不在block内，则不会显示。
- 要显示的内容都要写在block块内。
- 对于每个子页面单独需要的样式，专门定义个block块，然后再子页面中补全。

理解：

- 母版相当于一块布，布里面有一些补丁；在继承的时候，复制了一块布过来，这些补丁可以自行更改。
- **解析子模版并在被父模版包含的情况下展现其被父模版定义的内容**。



# 组件

- 组件：html 页面， 包含一小段代码

- 目的：更加细粒度的拿到代码段。
- 可以使用字符串也可以使用变量名
- 理解：类似python中的import，更准确的是一种"**将子模版渲染并嵌入当前HTML中**"的变种方法,而不应该看作是"解析子模版并在被父模版包含的情况下展现其被父模版定义的内容"。这意味着在不同的被包含的子模版之间并不共享父模版的状态,每一个子包含都是完全独立的渲染过程。

```
{% include '组件名' %}
{% include 'nav.html' %}
```



# 小结

本篇介绍了django的模板系统，目标定制一个动态的，简洁的页面。



下一篇为 [Django的View](https://chennq.com/django/20190704-django_5.html)，这是第二个需要了解的细节，学习了这一块，就可以完善我们的业务逻辑。




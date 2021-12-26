---
title: Django-ModelForm
copyright: true
date: 2019-07-18 21:42:30
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_13_ModelForm
---



{% cq %} 使用ModelForm可以大大减少我们的工作量，在model的基础上使用modelform来展示，创建和编辑表单。 {% endcq %}

<!--more-->





## form组件的缺点

对于定义的model来说，在自定义form组件的时候还需要重新定义一遍字段，所以ModelForm来了，它较form组件更简单，能做的也更多。

最简单的ModelForm：

```python
from django import forms

class RegForm(forms.ModelForm):
    class Meta:
        model = models.UserProfile
        fields = '__all__'  # 也可以使用 ['username']
```

用的时候和form的用法一样。



## ModelForm的缺点

虽然ModelForm帮我们简化了操作，但是这样功能会减少，我们在类似CharField中只能写widget，其它关于error_message,label,min_lenght都是不行的。

- 这样的话只能自定义了。
- 或者改变settings中的默认语言为 zh-hans 凑合着用。



## 添加自定义字段

- 在ModelForm中添加自定义字段同在form中定义字段。

```python
from django import forms

class RegForm(forms.ModelForm):
    # 这里添加自定义字段
    re_password = forms.CharField(widget=forms.PasswordInput(attrs={'class': 'form-control input-medium'}))
    class Meta:
        model = models.UserProfile
        fields = '__all__'  # 也可以使用 ['username']
```



### 重写 `__init__` 方法

- 想把bootstrap的样式应用进去就需要添加，手动添加属性太过繁琐，重写 `__init__` 方法来批量添加属性。

```python
# froms.py
from multiselectfield.forms.fields import MultiSelectFormField
class CustomerForm(forms.ModelForm):
    '''Customer相关'''

    def __init__(self,*args,**kwargs):
        super().__init__(*args,**kwargs)
        # 自定义操作 添加属性class = form-control
        for name,field in self.fields.items():
            # print(name,field)
            if isinstance(field,MultiSelectFormField):
                field.widget.attrs['class'] = 'list-inline'
                continue
            field.widget.attrs['class'] = 'form-control'

    class Meta:
        model = models.Customer
        fields = '__all__'
        exclude = ['last_consult_date']
        labels = {}  # 一般不设置，models中设置verbosename就行
        widegets = {}
```



## 增加与编辑

- 利用modelform来增加和编辑数据是很简单的。
- 对于增加只需要实例化一个空的modelform，渲染后在前端填充完毕，后端通过校验后只需要 save 就可以保存这条记录。
- 对于编辑，实例化的时候将需要待编辑的这个model 传给 instance参数，渲染完毕后在前端进行修改，后端实例化 `(新数据, 原始数据)` ，通过校验后只需要 save 就可以保存编辑。
- 所以增加与编辑的不同之处在于是否使用 `instance`

```python
def customer_change(request, pk=None):
    cus_obj = models.Customer.objects.filter(pk=pk).first()
    form_obj = CustomerForm(instance=cus_obj)
    if request.method == 'POST':
        form_obj = CustomerForm(request.POST, instance=cus_obj)
        if form_obj.is_valid():
            form_obj.save()
            return redirect('crm:my_customer')
    return render(request, 'customer_change.html', {'form_obj': form_obj})
```

note：

- 上面代码可以实现这两个功能的一个前提是: 在 `BaseModelForm` 的 `__init__`中 `instance=None` 。



### 动态创建表单

- 在HTML中，我们只需要遍历ModelForm对象，就可以把所有字段创建出来。
- field.field.required 用来判断这个字段是否是必填字段

```html
<form action="" method="post" class="form-horizontal col-lg-6 col-lg-offset-2" novalidate>
    {% csrf_token %}
    {% for field in form_obj %}
        <div class="form-group {% if field.errors %}has-success{% endif %}">
            <label for="{{ field.id_for_label }}" class="col-sm-2 control-label"
                    {% if not field.field.required %} style="color:gray;"{% endif %}>{{ field.label }}</label>
            <div class="col-sm-10">
                {{ field }}
                <span class="help-block">{{ field.errors.0 }}</span>
            </div>
        </div>
    {% endfor %}
    <button class="btn btn-default btn-sm col-lg-offset-5">提交</button>
</form>
```



## 源码剖析

- 为什么不是 `field.required` ，而是 `field.field.required` ？

找到 `BaseForm` 中的 `__iter__` 方法和 `__getitem__` 方法

```python
def __iter__(self):
    for name in self.fields:
        yield self[name] 
    # self[name] 调用 __getitem__ 方法
        
def __getitem__(self, name):
    "Returns a BoundField with the given name."
    try:
        field = self.fields[name]
    except KeyError:
        raise KeyError(
            "Key '%s' not found in '%s'. Choices are: %s." % (
                name,
                self.__class__.__name__,
                ', '.join(sorted(f for f in self.fields)),
            )
        )
    if name not in self._bound_fields_cache:
        self._bound_fields_cache[name] = field.get_bound_field(self, name)
    return self._bound_fields_cache[name]
	# 这里不再返回字段的field话，field.required就是正确的，这里缓存了字段，所以采用field.field.required
```

点击进入get_bound_field

- 其中的self 是 Field 对象。

```python
def get_bound_field(self, form, field_name):
	"""
	Return a BoundField instance that will be used when accessing the form
    field in a template.
    """
    return BoundField(form, self, field_name)
```

点击进入 BoundField 

```python
class BoundField(object):
    "A Field plus data"
    def __init__(self, form, field, name):
        self.form = form
        self.field = field
        self.name = name
        self.html_name = form.add_prefix(name)
        self.html_initial_name = form.add_initial_prefix(name)
        self.html_initial_id = form.add_initial_prefix(self.auto_id)
```

(form, self, field_name)  --->  (self, form, field, name)

form ---> form

self （Field对象） --->  field

field_name  ---> name

self.field = field    (self )  （是一个Field）
这里就相当于做了一次缓存，所以，使用 field.field.required才能找到。





## 例子

实现一个用户注册

相比于以前我们需要将每个字段进行校验，然后在创建这一行数据，ModelForm为我们简化了很多很多！



```python
from django import forms
from django.core.validators import RegexValidator
from django.core.exceptions import ValidationError
import hashlib


class RegForm(forms.ModelForm):
    password = forms.CharField(
        min_length=6,
        widget=forms.PasswordInput(attrs={'class': 'form-control input-medium', 'placeholder': '密码'}),
        error_messages={
            'min_length': '密码长度要大于6位',
        }
    )
    re_password = forms.CharField(
        min_length=6,
        widget=forms.PasswordInput(attrs={'class': 'form-control input-medium', 'placeholder': '确认密码'}),
        error_messages={
            'min_length': '密码长度要大于6位',
        }
    )

    mobile = forms.CharField(validators=[RegexValidator('^1[3-9]\d{9}$', '手机号格式不正确')], widget=forms.TextInput(
        attrs={'class': 'form-control input-medium', 'placeholder': '手机号'}))  # 会覆盖下面的mobile

    class Meta:
        model = models.UserProfile
        fields = '__all__'              # 也可以使用 ['username']
        exclude = ['is_active']         # 这里排除了就可以使用models中的default默认了
        widgets = {                     # 自定义字段标签，可以加属性
            'username': forms.EmailInput(
                attrs={'class': 'form-control input-medium', 'placeholder': '用户名', 'autocomplete': 'off'}),
            'password': forms.PasswordInput(
                attrs={'class': 'form-control input-medium', 'placeholder': '密码', 'autocomplete': 'off'}),
            'name': forms.TextInput(
                attrs={'class': 'form-control input-medium', 'placeholder': '姓名', 'autocomplete': 'off'}),
            'department': forms.Select(
                attrs={'class': 'form-control input-medium', 'placeholder': '部门', 'autocomplete': 'off'}),
            'mobile': forms.TextInput(
                attrs={'class': 'form-control input-medium', 'placeholder': '手机号', 'autocomplete': 'off'}),
        }
        error_messages = {
            "username": {
                "unique": "邮箱已存在"
            },
        }

    def clean(self):
        self._validate_unique = True
        pwd1 = self.cleaned_data.get('password')
        pwd2 = self.cleaned_data.get('re_password')
        if pwd1 == pwd2:
            if pwd1:
                md5 = hashlib.md5()
                md5.update(pwd1.encode('utf-8'))
                self.cleaned_data['password'] = md5.hexdigest()
            return self.cleaned_data
        else:
            self.add_error('re_password', '两次密码不一致')
            raise ValidationError('两次密码不一致')

# 存在缺陷：具有 Username 的 用户信息 已存在。这回暴露字段名，这种该怎么办？？？ 有一个key叫做unique

def register(request):
    form_obj = RegForm()
    if request.method == 'POST':
        form_obj = RegForm(request.POST)
        if form_obj.is_valid():
            form_obj.save()
            return redirect('crm:login')
    return render(request, 'register.html', {'form_obj': form_obj})
```






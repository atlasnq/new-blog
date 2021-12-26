---
title: python字典
date: 2019-03-25 09:15:00
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-dict
copyright: true
---



{% cq %}本篇介绍了python中字典的概念、操作（增删查改）、字典的嵌套和字典推导式。 {% endcq %}

<!-- more -->

------------------------



### 字典的初识：

why：

- 列表可以存储大量的数据，数据之间的**关联型不强**。
  - ['小白',18,'男','小黑',30,'男']
- 列表的**查询速度比较慢**。

what：

- 容器型数据类型：dict

how：

- 数据类型的分类（可变与不可变）：
  - 可变（不可哈希）的数据类型：列表，字典，集合
  - 不可变（可哈希）的数据类型：str、 bool、int、 tuple
- 字典：{}括起来，以键值对形式存储的容器型数据类型：

```python
dic ={'小白':
     {'name':'小白','age':18},
      'aa':['bb','cc'],
}
```

- 键必须是**不可变的数据类型**：int、str    （bool、tuple几乎不用）
- 值可以是**任意**数据类型，对象。
- 字典3.5版本之前（包括3.5）是无序的。
- 字典在3.6x会按照初次建立字典的顺序排列，学术上不认为是有序的。
- 字典3.7x以后都是有序的。
- 字典的优点：查询速度快，存储关联型数据
- 字典的缺点：以空间换时间。



### 字典的创建方式：**(掌握任意三种方式)**

- 方式一：拆包

```python
dic = dict((('one',1),('two',2),('three',3)))
```

- 方式二：

```python
dic = dict(one=1,two=2,tree=3)
```

- 方式三：官方正规写法

```python
dic = dict({'one': 1, 'two': 2, 'three': 3})
```

- 验证字典的合法性：

```python
dic = {[1,2,3]:'alex',1:666}
#TypeError: unhashable type: 'list'
```

- 字典的增删改查：

  - 键值对：  键，唯一：房间号：0~99  值： 房间：里面放什么都可以。 所以我们只能通过键来找值，不能通过值来找键。

  ```python
  dic = {1:'aa',1:'cc',2,"ee"}   前面的直接被覆盖了
  print(dic)  #{1:'cc',2:'ee'}
  ```

  

### 增：3种

- 方式一：直接增加  （有则改之，无则增加）

```
dic = {'name':'aa','age':18}
#若字典中没有sex 则增加一个键值对
dic['sex'] = '男'
#若字典中有sex， 则改掉
```

- 方式二：setdefalut (有则不变，无则增加)

```
dic.setdefault("hobby") #增加一个键，值为None
dic.setdefault("age",45)
```

- 方式三： update（有则改之，无则增加）

```
dic = {'key1':1}
dic.update(key1 = 2)  mapping 所以关键字不加引号

# 原因：因为字符串无法作为变量使用，所以不能 'key1' = 2 
```



### 删：3

- pop 按照键去删除键值对，返回对应的值
- 和列表不同的是，没有默认删除最后一个这个方式。

```python
print(dic.pop("age"))
```

想删除一些键值对，但不确认，又不想找不到报错

**设置第二个参数则无论字典中有无此键都不会报错，且返回第二个参数的内容**

```python
dic.pop('hoby') ##KeyError: 'hoby'
ret = dic.pop('sex1','没有此键')
print(ret)    #没有此键
```

- clear 清空   剩下{}
- del 按照键去删除  没有这个键会报错，所以常用pop



### 改：2

- 直接改：
- update：无则添加，有则更新



### 查：5

- 通过键查询值  
  - 缺点：若没有这个键就会报错  （不建议）
- get  推荐 (与pop相似，可以设置第二个参数)

```python
l1 = dic.get('hobby')
ret = dic.get('hobby1','没有此键')
print(ret)
```

- keys()  values()  items()
  - 可以转化成列表list(dic.keys())
  - 遍历循环

```python
print(dic.keys())   #dict_keys(['name', 'age', 'hobby'])

list(dic.keys())

for key in dic:
    print(key)
    
for value in dic.values():
	print(value)

print(dic.items())
#dict_items([('name', 'aa'), ('age', 18), ('hobby', ['排球', '足球'])])

for i in dic.items():		
    print(i)			#输出元组
    
for key,values in key.items():
	print(key,values)	#拆包
```

```python
练习：（找菜篮子，放土豆，最后缸里也会有土豆）
# 请在k3对应的值中追加一个元素 44，输出修改后的字典
dic = {'k1': "v1", "k2": "v2", "k3": [11,22,33]}
#法1
# dic['k3'].append(44)
# print(dic)
法2
l1 = dic['k3']
l1.append(44)
print(dic)
法3
dic.get('k3').append(44)

```



### 字典的嵌套

```python
练习：
dic = {
    'name': '汪峰',
    'age': 48,
    'wife': [{'name': '国际章', 'age': 38},],
    'children': {'girl_first': '小苹果','girl_second': '小怡','girl_three': '顶顶'}
}

# 1. 获取汪峰的名字。
na = dic['name']
print(na)
# 2.获取这个字典：{'name':'国际章','age':38}。
dic1 = dic['wife'][0]
print(dic1)
# 3. 获取汪峰妻子的名字。
na2 = dic['wife'][0]['name']
print(na2)
# 4. 获取汪峰的第三个孩子名字。
na3 = dic['children']['girl_three']
print(na3)
```



### 字典推导式

简单的字典推导式

```python
li = [1,2,3,4,5]
dic = {key: '' for key in li}
print(dic)    # {1: '', 2: '', 3: '', 4: '', 5: ''}
```

双层循环会出现问题，所以利用生成器

```
g = (i for i in range(1,11))
b = ['黑桃', '红桃', '梅花', '方板']
dic = {next(g):i for i in  b}
print(dic)
# {1: '黑桃', 2: '红桃', 3: '梅花', 4: '方板'}
```



-----------------------


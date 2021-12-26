---
title: 编写自定义类实现json和pickle文件的多行写入，多行读取
date: 2019-04-5 15:10:55
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-json-and-pickle
copyright: true
---



{% cq %}首先是json与pickle的介绍，然后是对于json不能多次dump的解决办法。 {% endcq %}

<!--more-->



-----



- json与pickle

  - 序列化（serialization）：将内存中的结构化数据转换成字节串。
  - 反序列化（deserialization）：从文件中或网络中获取的数据转换成内存中原来的数据类型
  - 具体方法：dump、dumps、load、loads
    - dump与load是对文件进行操作（序列化与反序列化）
    - dumps与loads时对内存中的数据进行操作（序列化与反序列化）

- pickle 写入多个对象，读取多个对象

  ```python
  pickle支持多次dump，但对于读取文件，我们再不清楚内容（load多少次）时，使用try except EOFError
  
  class A:
      def __init__(self):
          self.li = []
  class B:
      def __init__(self):
          self.li = []
  a = A()
  a.li.append(1)
  b = B()
  b.li.append(2)
  
  import pickle
  class My_pickle():
      def __init__(self,path):
          self.path = path
      def dump(self,*args):
          with open(self.path,mode='wb') as f:
              for i in args:
                  pickle.dump(i,f)
      def load(self):
          with open(self.path,mode='rb') as f:
              while 1:
                  try:
                      yield pickle.load(f)
                  except EOFError:
                      break
               
  p1 = My_pickle('test.pikle')
  p1.dump(a,b)
  for i in p1.load():
      print(i)
  ```

- json写入多行

  ```python
  方式一： 
  将待写入的多种数据（列表，元组，字典）放到一个列表中写入，读取时，将列表反序列化到内存，在逐个返回。
  缺点：一次性取出所有，内存占用大。
  import json
  class My_json():
      def __init__(self,file):
          self.file = file
      def dump(self,*args):
          with open(self.file,mode='w',encoding='utf-8') as f:
              li = []
              for i in args:
                  li.append(i)
              json.dump(li,f)
  
      def load(self):
          with open(self.file,mode='r',encoding='utf-8') as f:
              ret = json.load(f)
              for j in ret:
                  yield j
  j = My_json('test.json')
  j.dump([1,2,3,4,],'ssss')
  for i in j.load():
      print(i)
  ```

  ```python
  方式二:   推荐
      将待写入的多种数据（列表，元组，字典）写入一种数据的同时写入一个\n，这样读取文件的时候，使用for遍历文件句柄，对于得到的字符串使用json.loads()方法进行反序列化。
  import json
  class My_json():
      def __init__(self,file):
          self.file = file
      def dump(self,*args):
          with open(self.file,mode='w',encoding='utf-8') as f:
              for i in args:
                  json.dump(i,f)
                  f.write('\n')
      def load(self):
          with open(self.file,encoding='utf-8') as f:
              for line in f:
                  ret = json.loads(line)
                  print(ret)
  j = My_json('test.json')
  j.dump([1,2,3,4,],'ssss')
  j.load()
  ```

  ```
  方式三:   
     	在方式二的基础上进行的小改，除了先dump(i)在write('\n'),我们还可以先用 dumps(i)序列化数据，然后再write(序列化数据 + '\n')
  import json
  class My_json():
      def __init__(self,file):
          self.file = file
      def dump(self,*args):
          with open(self.file,mode='w',encoding='utf-8') as f:
              for i in args:                
                  f.write(json.dumps(i) + '\n')
      def load(self):
          with open(self.file,encoding='utf-8') as f:
              for line in f:
                  ret = json.loads(line)
                  print(ret)
  j = My_json('test.json')
  j.dump([1,2,3,4,],'ssss')
  j.load()
  ```

  

- pickle和json在对多行写入，写出的区别：

  - pickle 支持多次dump，所以对应着就可以多次load来取这个数据，但当我们不知道文件中有多少个或者不知道该load几次的时候，我们可以使用try except EOFError 来让它停止。
  - json 不支持多次dump，所以在dump一次后，在写入一个换行。 这样在读文件的时候，我们循环遍历文件句柄，读一行，用loads （注意这里的loads是因为，已经对内存的字符串进行处理/而不是文件）



-------------------


---
layout: python
title: Python 函数
date: 2019-04-03 14:01:38
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-function
copyright: true
---



{% cq %}python函数部分的总结。重要的知识点：参数，作用域，三大器，递归。{% endcq %}

<!-- more -->



## 懒惰是一种美德 

​	我们首先接触的代码组织工具，就是函数（function）。通过把一大段程序分成几个小部分，使每个小部分都简单一些，这样做可以令代码更加易读，也更便于使用。函数为**复用**和**重构**提供了契机。例如：对于计算斐波那契数列。

```python
fibs = [0,1]
for i in range(8):
    fibs.append(fibs[-2] + fibs[-1])
print(fibs)
```

​	运行代码后，fibs包含10个斐波那契数。但当我们想要一个包含20个数的该怎么办呢？ 简单呀，修改for循环不就可以了。

```python
fibs = [0,1]
num = int(input('请输入数量：'))
for i in range(num - 2):
    fibs.append(fibs[-2] + fibs[-1])
print(fibs)
```

​	那我如果还想用这些数做其它事情呢? 简单呀，哪儿用在哪儿写不就可以了。 但实际中我们很懒，我们不想重新编写。我们希望按照下面这样来使用。

```python
# 函数是一种抽象。
num = input('How many numbers do you want? ') 
print(fibs(num)) 
```

​	这里只具体地编写了这个程序独特的部分（读取数字，并打印结果），告诉了计算机要这样做，但没有具体告诉它如何做。你需要创建一个名为fibs的函数，并在需要计算斐波那契数列的时候调用它，如果多个地方需要，这样做节省很多精力。

```python
def fibs(num):
    fib = [0,1]
    for i in range(num - 2):
        fib.append(fib[-2] + fib[-1])
    return fib
num = int(input("请输入数量: "))
print(fibs(num))
```



## 抽象和结构

​	抽象可节省人力，但实际上还有个更重要的优点：**抽象是程序能够被人理解的关键所在**（无 论对编写程序还是阅读程序来说，这都至关重要）。计算机本身喜欢具体而明确的指令，但人通常不是这样的。如问路，只要告诉对方沿xx条路走然后看到什么标志物在怎么怎么走就可以了。

​	组织计算机程序时，你也采取类似的方式。程序应非常抽象，如下载网页、计算使用频率、 打印每个单词的使用频率。这很容易理解。下面就将前述简单描述转换为一个Python程序。 

```python
page = download_page()
freqs = compute_frequencies(page) 
for word, freq in freqs:
	print(word, freq)
```

​	看到这些代码，任何人都知道这个程序是做什么的。然而，至于具体该如何做，可以查看它的定义。

​	函数是结构化编程的核心。



## 自定义函数



### 函数

​	以功能（完成一件事儿）为导向；一个函数就是一个功能；函数是一种抽象（隐藏不必要细节的艺术。通过定义处理细节的函数，可让程序更抽象。 ）。



### 优点

1. 减少代码的重复性。
2. 增强了代码的可读性



### 函数的结构与调用

```
# def 关键字，定义函数。 fibs 函数名：与变量设置规则相同，具有可描述性  num是参数：通过参数获取要求的斐波那契数列的长度。
def fibs(num):
    '计算斐波那契数列'   # 这个函数的文档
    fib = [0, 1]
    for i in range(num - 2):
        fib.append(fib[-2] + fib[-1])
    return fib
num = int(input("请输入数量: "))
print(fibs(num))  # 当函数遇到 函数名（）  函数才会执行！！
```



### 给函数编写文档

在def语句后面（以及模块和类的开头），添加这样的字符串很有用。放在函数开头的字符串称为 文档字符串（docstring），将作为函数的一部分存储起来。

```python
print(fibs.__doc__)
# 计算斐波那契数列
```



### 函数名

函数名指向的是函数的内存地址。 

- 函数名 + （）就可以执行此函数。

函数名就是变量。

1. 赋值运算
2. 可以作为容器数据类型的元素。

3. 函数名可以作为函数的参数。

4. 函数名可以作为函数的返回值。



### 函数的返回值

1. return : 在函数中遇到return直接结束函数。（终止函数）(所以严格意义上它并非函数，数学意义上的函数总是返回根据参数计算得到的结果。)
2. return 可以给函数的执行者（函数名+（））返回值：
   1. 没有设置返回值的时候，返回None。
   2. return  单个值      单个值，且数据类型类型与该值数据类型相同仅限关键字参数
   3. return   多个值     返回多个元素，以元组的形式返回给函数的执行者。一个变量接收元组，多个变量可以拆包。



### 函数的参数



#### 形参角度（定义）：

1. 位置参数：一一对应，不能多也不能少

2. 默认值参数：

   - 设置的意义：普遍经常使用的。例如open(file, mode='r' , encoding=None)

3. 万能参数：`*args`，`**kwargs`。

   - `*args`和`**kwargs`本身不特殊（argument：参数）如果不加`*`都是位置参数。在形参位置加上一颗 `*`可以**接收任意数量的位置参数**并将其聚合成一个元组赋值给args；加上 `**`可以**接收任意数量的关键字参数**并将其聚合成一个字典赋值给kwargs。
   - *在形参起到聚合的作用
   - 函数的调用时，*代表打散，用于可迭代对象，成了位置参数。 `**`打散字典，成了关键字参数。

4. 仅限关键字参数（Python 3）：

   - 仅限关键字参数位于`*args`和 `**args`的中间，和关键字参数无先后要求。

5. 形参的最终顺序：位置参数 ---> `*args` ---> 仅限关键字参数/默认值参数 --->  `**kwargs` 

   - 排序依据：在位置参数和关键字参数的基础上添加，b影响a，所以将a放在前面。

   

#### 实参角度（执行/调用）：

1. 位置参数：必须一一对应：不能多也不能少。
2. 关键字参数：位置可以不对应。    
   - 注意：关键字参数不带引号
3. 混合传参：位置参数必须在关键字参数的前面。



### 我能修改参数吗？

​	对于不可变数据类型（immutable）（字符串，数，元组），这些意味着你不能修改它们（即只能替换为新值，新值是局部变量，它在局部作用域内）。因此这些类型作为参数没什么可说的。但如果参数为可变的数据结构（如列表）呢？ 

```python
li = [1,2]
def func(lis):
    lis[0] = 666
func(li)
print(li)    # [666, 2]

# 补充: 可以在局部修改全局的可变数据类型。
li = [1,2]
def func():
    li[0] = 666
func()
print(li)    # [666, 2] 
```

​	在这个例子中，在函数内修改了参数，函数外面这个列表的值也发生了变化。

注意：参数存储在局部作用域内。

​	那么如何避免这种影响呢？**传递的实参是一个副本**，对序列执行切片操作时，返回的切片都是副本。 **如创建覆盖整个列表的切片，得到的将是列表的副本。** 

```python
li = [1,2]
def func(lis):
    lis[0] = 666
func(li[:])
print(li)	# [1,2]
```

上面是对于可变数据类型的修改，以及维持不变的方法。



### 名称空间

变量到底是什么呢?可将其视为指向值的名称。

​	名称空间分为：内置名称空间（builtins.py），全局名称空间(当前py文件)，局部名称空间（函数，函数执行时才开辟）

1. 全局名称空间：记录了整个文件的变量与值的对应关系。
2. 局部/临时名称空间：临时存放了函数中的变量与值的关系。
3. 内置名称空间：python源码给你提供的一些内置的函数，print，input。

```
x = 1
scope = vars()
print(scope)
scope['x'] = 2
# 修改变量的指向
print(scope['x'])
```

​	执行赋值语句x = 1后，名称x指向值 1。这几乎与使用字典时一样（字典中的键指向值），只是你使用的是“看不见”的字典。有一个名为**vars的内置函数**，它返回这个**不可见的字典**。



加载顺序：内置名称空间 ---> 全局名称空间 --->  局部名称空间 （函数执行时才加载）

- 啥也不写，光一个print(666)，证明先加载内置名称空间。



取值顺序: **就近原则**  LEGB（local eclose global Builtin）原则  单向不可逆

1. 调用函数时：局部名称空间 ---> 全局名称空间 ---> 内置名称空间

2. 验证：  证明内置名称空间是最后调用的。

   ```
   input = '小黑'
   def func():
   	input = '小白'
   	print(input)
   func()
   ```



### 作用域

全局作用域：内置名称空间 + 全局名称空间

局部作用域：局部名称空间

全局作用域与局部作用域的联系（***）

1. 局部作用域可以**引用**全局的变量。

2. 全局作用域不能**引用**局部的变量。

3. 局部作用域不能改变全局作用域的变量。 

   ```
   count = 1
   def func():
   	count += 1
   func()
   问：为什么会报错？
   
   #当python解释器读取到局部作用域时，发现了对一个变量进行修改的操作。解释器会认为你在局部已经定义过这个局部变量了，它就从局部找这个变量，所以报错。（面试题）
   ```

关键字 global 与 nonlocal：

1. global可以声明/创建全局变量；它还可以修改全局变量
2. nonlocal不可以修改全局变量，它可以修改外层的非全局变量

内置函数 globals(),locals():

1. globals() 返回字典：字典里面的键值对：全局作用域的所有内容（全局名称空间和内置名称空间 ）  
2. globals这个函数类似于vars，返回一个包含全局变量的字典。（locals返回一个包含局部变量的字典。）

```python
# 通过globals()查看当前作用域的全局变量，它是一个字典（全局名称空间）
print(globals(),type(globals()))
lis = [1,2]
# 在globals中查看lis这个列表
print(globals()['lis'])
# 在globals中修改lis这个列表
globals()['lis'][0] = 2
# 修改后这个列表变了。
print(globals()['lis'])
# 修改这个字典，会影响当前全局作用域中变量的查找
globals()['aaa'] = 666
print(aaa)
```

2. locals()返回字典：字典里面的键值对：当前作用域的所有内容，如果在全局作用域使用和globals的效果一样。

```python
def func():
    aaa = 666
    print(locals()['aaa'])
    locals()['aaa'] = 777
    # locals 是局部名称空间的一个拷贝，改变它并不会改变局部名称空间
    print(locals()['aaa'])   # 666

func()
```



### 作用域嵌套

Python函数可以嵌套，即可将一个函数放在另一个函数内，如下所示：

```python
def foo():
    def bar():
        print('老铁双击666')
    bar()
foo()
```

嵌套通常用处不大，但有一个很突出的用途：使用一个函数来创建另一个函数。这意味着可像下面这样编写函数： 

```python
def func1(num):
    def func2():
        print(f'老铁双击{num}')
    return func2
f = func1(666)
f()		# 老铁双击666
f1 = func1(999)
f1()	# 老铁双击999
```

​	在这里，一个函数位于另一个函数中，且外面的函数**返回里面的函数**。也就是返回一个函数，而不是调用它。重要的是，<u>返回的函数能够访问其定义所在的作用域</u>。换而言之，它携带着自己所在的环境（和相关的局部变量）！ 

​	每当外部函数被调用时，都将重新定义内部的函数，而变量num的值也可能不同。由于Python的嵌套作用域，可在<u>内部函数中访问这个来自外部局部作用域（multiplier）的变量</u>。像num这样存在所在作用域的函数成为闭包。

​	一句话概括就是：存在于嵌套函数中的，内层函数对外层非全局变量的访问。



## 迭代器

### 定义

1. 字面意思：可更新迭代的工具。
2. 专业角度：内部含有 `__iter__`方法并含有 `__next__`方法的对象就是迭代器。
3. An **iterator** is an object that implements `next`, which is expected to return the next element of the iterable object that returned it, and raise a `StopIteration` exception when no more elements are available.



### 判断一个对象是否是迭代器

```
print('__iter__'in dir(obj) and '__next__' in dir(obj))
```



### 迭代器的取值

```
l1 = [11,22,33,44,55,66]
#转化为迭代器的三种方式
obj3 = l1.__iter__()
obj4 = iter(l1)     

#迭代器取值的三种方式。
print(next(obj3))
print(obj4.__next__())
#一个next对应一个值，超出元素个数就会报错

# 使用for循环会在内部将可迭代对象转成迭代器
for i in l1:
	print(i)
```



#### 可迭代对象与迭代器的相互转化

```
a = [1,2,3]
b = iter(a)
c = list(b)
```



#### while循环模拟for循环机制（**面试**）

```
# 1.将可迭代对象转化成迭代器
l1 = [11,22,33,44,55,66]
obj = iter(l1)
# 2.利用next对迭代器进行取值
while 1:
# 3.利用try except捕获错误，并退出。
    try :
        print(next(obj))
    except StopIteration:
        break

for i in li： #这里的li默认帮我们执行了li.__iter__(),并且程序自动帮我们捕捉了StopIteration这个错误，不用手工写进去。
	print(i)
在源码中：
if (f==NULL || f->f_stacktop == NULL) { // 如果代码块为空或调用栈为空，
//则抛出StopIteration异常
```



### 迭代器的优点

#### 节省内存。

- 迭代器在内存中只占一条。迭代时，上一条在内存中消失了。

#### 惰性机制。

- next一下，取一个值，绝不多取值。



### 迭代器的缺点

1. 不直观
2. 速度慢（以时间换空间）



### 迭代器总结

1. Python的Iterator对象表示的是一个数据流，Iterator对象可以被next()函数调用并不断返回下一个数据，直到没有数据时抛出StopIteration异常。可以把这个数据流看做是一个有序序列，但我们却不能提前知道序列的长度，只能不断通过next()函数实现按需计算下一个数据，所以Iterator的计算是惰性的，只有在需要返回下一个数据时它才会计算。Iterator甚至可以表示一个无限大的数据流，例如全体自然数。而使用list是永远不可能存储全体自然数的。



## 生成器

### 什么是生成器？

1. python社区与迭代器看成一种，生成器的本质就是迭代器。
2. 生成器是构造新的可遍历对象的一种非常简洁的方式。普通函数执行并一次返回单个结果，而生成器则'惰性'地返回一个多结果序列，在每一个元素产生之后暂停，直到下一个请求。
3. 区别：生成器是我们自己用python代码构建的数据结构。迭代器都是提供的，或者转化得来的。
4. 生成器的特点是并没有立即执行,而是记住'生产方式',等被调用时再执行.



### 获取生成器的三种方式：

1. 生成器函数。（自己写的）
2. 生成器表达式。（自己写的）
3. python内部提供的一些。



### 生成器函数获取生成器

```
#普通函数
def func():
    print(111)
    print(222)
    return 3
ret = func()
print(ret)
#生成器函数
def func1():
	print(111)
	print(222)
	yield 3
	yield 4
ret1 = func1()     #当你实际调用生成器时，代码不会立即执行；
print(next(ret1))	#直到你请求生成器中的元素时，它才会执行它地代码
print(next(ret1))   #当next地数量超过 yield 就会报错
```

yield return

- return：函数中只存在一个return结束函数，并且给函数地执行者返回值。
- yield：只要函数中有yield（不论有没有return）那么它就是生成器函数。生成器函数可以存在多个yield，yield不会结束生成器函数，一个yield对应一个next 

```
吃包子练习：
def func():
	li = []
	for i in range(1,5001):
		li.append(f'{i}号包子')
	return li
ret = func()
print(ret)

def func1():
	for i in range(1,5001)
		yield f'{i}号包子'
ret1 = func1()
for i in range(300):
	print(next(ret1))

#疑惑，使用ret1 = func1() 后用for循环是1~...号包子。但是如果直接用func1()就只有1号包子
def gen_func2():
    for i in range(1, 5001):
        yield f'{i}号包子'

print(id(gen_func2()))
for i in range(200):
    print(next(gen_func2()),id(gen_func2()))
#1号包子 2323676793936
#1号包子 2323676793936
#1号包子 2323676793936         ？？？
```

yield from

进阶拔高：

问题1：

```
g=(i for i in range(4))
for i in [1,10]:
    g=(i+j for j in g) 
print(list(g))
#这个会输出什么呢？

g=(i for i in range(4))
for i in [1,10]:
    g=(i+j for j in g)
for i in g:
    print(i) 
#这个会输出什么呢？

<i + j for j in <i + j for j in <0,1,2,3>>>
<i + i + j for j in <0,1,2,3>>
<2i+j for j in <0,1,2,3>>

#记住这种生产方式 
<i+j for j in <i+j j in<0,1,2,3>>>      
< 2i + <0,1,2,3> > 
# 调用的时候开始执行   
```

总结：这样的生成器会产生嵌套的效果，**从里向外去理解**
1. 生成器的特点是并没有立即执行，而是'记住**生产方式**'，等<u>被调用</u>（如list（））时在执行

2.  推导式中地变量是临时变量，不会影响其它地变量。

3. 生成器中的 i 是受保护地，与外部地 i 无关，它地取值一定是0，1，2，3

   ```
   g = (i for i in range(4))
   i = 8
   print(list(g))
   
   #在看一个
   a = 1
      g = (a + i for i in range(4))
      a = 5
      print(list(g))
   ```

4. 这里i是受保护地，而a并没有，由于后续a地值是5，所以打印语句中生成器应该是 `<gen 5+0, 5+1 ,...>`的存在。

5. 分析题目：	

   ```
   第一行的 g = (i for i in range(4))中，i是受保护的，所以它的迭代永远都是0~3
   
   for i in [1,10]:
   	g = (i + j for j in g)
   这里的j也属于受保护的，在第一次循环中，它的值就是g初始时产出的0~3。而这里的i不受保护，只是进行变量绑定，在生成器生成数据时才获取其值
   
   第一次循环后g的值：
   <gen i+0,i+1,i+2,i+3>
   
   第二次循环，推导式中j就是生产的值，虽然此时i=10，但i是后续绑定的，所以生产为 i+0,i+1,i+2,i+3 第二次循环后g的值：
   <gen i+i+0, i+i+1,i+i+2,i+i+3>
   
   最后打印语句时，i的值是循环体最后一次的值（10），所以打印输出20，21，22，23
   
   如果是
   for i in g:
       print(i) 
   这样         #20，41，84，171  
   <gen i+i+0,i+i+1,i+i+2,i+i+3>
   20 20+20+1 41+41+2 84+84+3
      #因为生成器中变量 i一直存在，并没有被释放和回收，在使用变量i去循环g，i的值就产生混乱了。
   
   
   如果是
   for k in g：
   	print(k) 
   ```

   

### 生成器表达式，列表推导式

列表推导式：用一行代码去构建一个比较复杂有规律的列表。

推导式分类：

1. 循环模式：[变量（加工后的变量）for 变量 in iterable]  
2. 筛选模式：[变量（加工后的变量）for 变量 in iterable if 条件]
3. [ f(x) for x in S if P(x)] (多维对象转换成一维列表)

循环模式：

1. 单层：

2. 嵌套：从外层到内层,顺序写下来

   ```
   names = [['Tom', 'Billy', 'Jefferson', 'Andrew', 'Wesley', 'Steven', 'Joe'],
            ['Alice', 'Jill', 'Ana', 'Wendy', 'Jennifer', 'Sherry', 'Evan']]
   
   li = []
   for i in names:
   	for j in i:
   		if j.count('e')>=2:
   			li.append(j)
   #改成一句话
   print([j for i in names for j in i if j.count('e')>=2])
   ```

练习：一行打印扑克牌

```
print([i for i in range(2,10)]+list('JQKA'))
```





## 装饰器



### 开放封闭原则

开放: 对代码的拓展开放的；

封闭：对源码的修改是封闭的。



### 装饰器

- 完全遵循开放封闭原则。
- 在不改变原函数的代码以及调用方式的前提下，为其增加新的功能。
- 装饰器就是一个函数。

现在我们想在登陆博客园函数基础上加一个测试这个函数的执行效率这样一个功能。在遵守开放封闭原则的基础上产生了版本一。

### 版本一：简单版本

```
import time
def index():
    '''有很多代码.....'''
    time.sleep(2) # 模拟的网络延迟或者代码效率
    print('欢迎登录博客园首页')

def timmer(f):
    def inner():
        start_time = time.time()
        f()
        end_time = time.time()
        print(f'测试本函数的执行效率{end_time-start_time}')
    return inner

index = timmer(index)
index()
```



### 版本二：加语法糖

```
import time
def timmer(f):
    def inner():
        start_time = time.time()
        f()
        end_time = time.time()
        print(f'测试本函数的执行效率{end_time-start_time}')
    return inner
@timmer
def index():
    '''有很多代码.....'''
    time.sleep(2) # 模拟的网络延迟或者代码效率
    print('欢迎登录博客园首页')

index()
```



### 版本三：被装饰函数带返回值

```
import time
# timmer装饰器
def timmer(f):
    def inner():
        start_time = time.time()
        # print(f'这是个f():{f()}!!!') # index()
        r = f()
        end_time = time.time()
        print(f'测试本函数的执行效率{end_time-start_time}')
        return r
    return inner

@timmer # index = timmer(index)
def index():
    '''有很多代码.....'''
    time.sleep(0.6) # 模拟的网络延迟或者代码效率
    print('欢迎登录博客园首页')
    return 666
# 加上装饰器不应该改变原函数的返回值，所以666 应该返回给我下面的ret，
# 但是下面的这个ret实际接收的是inner函数的返回值，而666返回给的是装饰器里面的
# f() 也就是 r,我们现在要解决的问题就是将r给inner的返回值。
ret = index()  # inner()
print(ret)
```



### 版本四：被装饰函数带参数

```
import time
# timmer装饰器
def timmer(f):
    # f = index
    def inner(*args,**kwargs):
        #  函数的定义：* 聚合  args = ('小黑',18)
        start_time = time.time()
        # print(f'这是个f():{f()}!!!') # index()
        r = f(*args,**kwargs)
        # 函数的执行：* 打散：f(*args) --> f(*('小黑',18))  --> f('小黑',18)
        end_time = time.time()
        print(f'测试本函数的执行效率{end_time-start_time}')
        return r
    return inner

@timmer # index = timmer(index)
def index(name):
    '''有很多代码.....'''
    time.sleep(0.6) # 模拟的网络延迟或者代码效率
    print(f'欢迎{name}登录博客园首页')
    return 666
index('小白')  # inner('小白')

@timmer
def dariy(name,age):
    '''有很多代码.....'''
    time.sleep(0.5) # 模拟的网络延迟或者代码效率
    print(f'欢迎{age}岁{name}登录日记页面')
dariy('小黑',18)  # inner('小黑',18)
```



### 版本五：标准版装饰器

```
def wrapper(f):
    def inner(*args,**kwargs):
        '''添加额外的功能：执行被装饰函数之前的操作'''
        ret = f(*args,**kwargs)
        ''''添加额外的功能：执行被装饰函数之后的操作'''
        return ret
    return inner
```



### 版本六：装饰器的嵌套

对于这类问题关键的一点在于语法糖：**语法糖默认会向下在读一行**！ 所以是从最下面开始进行转换

```python
# 例1：
def func1(f):
    def inner1():
        print(1)
        f()
        print(1)
    return inner1

def func2(f):
    def inner2():
        print(2)
        f()
        print(2)
    return inner2

def func3(f):
    def inner3():
        print(3)
        f()
        print(3)
    return inner3

@func3  
@func2   
@func1   
def func():
    print(111)

func()


# 例2

def func1(f):
    print(1)
    def inner():
        f()
    return inner

def func2(f):
    print(2)
    def inner():
        f()
    return inner

def func3(f):
    print(3)
    def inner():
        f()
    return inner

@func3
@func2
@func1
def func():
    print(111)

func()

# 例3
def func3(*args):
    def func2(f):
        def func1(*args,**kwargs):
            print("in func1")
            ret = f()
            return ret
        return func1
    return func2

def func6(f):
    def func5(*args,**kwargs):
        print('in func5')
        ret = f(*args,**kwargs)
        return ret
    return func5

@func3()       #@func3() == @func2   func5 = func2(func5)  == func1(func5)
@func6          #func7 = func6(func7) == func5
def func7():
    print('in func7')
func7()
```



### 版本七：带参数的装饰器

- 带参数的装饰器最关键的一点： **我们先执行语法糖后面的**！

```python
def zhuangshi(*args):
	def wrapper(f):
		def inner(*args,**kwargs):
			'''被装饰前'''
			ret = f(*args,**kwargs)
			'''被装饰后'''
			return ret
		return inner
	return wrapper

@zhuangshi()
def func1():
	print('in func1')
@zhuangshi()
def func2():
	print('in func2')
	
这样@zhuangshi() 相当于  @wrapper   相当于   func1 = wrapper(func1)
```



### 版本八：使用functools.wraps 保留被装饰函数原来的信息

```python
import functools

def wrapper1(func):
    @functools.wraps(func)  # 保留着被装饰函数原来的信息
    def inner(*args,**kwargs):
        print('w1')
        return func(*args,**kwargs)
   return inner

# 不加 @functools.wraps(func) 函数名就是 inner
# 加上 @functools.wraps(func) 函数名是 index，它会拷贝，原函数的信息，如注释，函数名（__name__）等

def wrapper2(func):
    @functools.wraps(func)
    def inner(*args,**kwargs):
        print('w1')
        return func(*args,**kwargs)
   return inner

# index = wrapper(index)
@wrapper1  
@wrapper2  
def index(xx)
	print('index')
	pass


'''
理解上：
@wrapper1  
@wrapper2  
def index(xx)
	print('index')
	pass
👇	
@wrapper1
inner
👇
所以，运行的时候是从上到下的，加载的时候是从内到外的。
'''

print(index.__name__)   # "inner"
```

- **运行的时候是从上到下的，加载的时候是从内到外的**





-----














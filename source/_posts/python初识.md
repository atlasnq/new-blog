---
title: python初识
date: 2019-03-20 14:08:37
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-basic-knowledge
copyright: true
---



{% cq %}python的简单介绍，以及一些简单的语法。 {% endcq %}

<!-- more -->


# python介绍

创始人：Guido van Rossum（龟叔）（终身仁慈独裁者 BDFL）

主要应用领域：

- 云计算： 
	- openstack 
- WEB开发：
  - Django
- 科学运算、人工智能：
	- Numpy
	- SciPy
	- Matplotlib
- 系统运维
- 金融
  - 建模
- 图形GUI：
	- PyQT
	- WxPython
	- TkInter
	
## python是一门什么样的语言:&emsp;解释型   动态强类型

- 编译型与解释型 
	- 编译器把源程序的每一条语句都编译成机器语言，并保存成二进制文件。运行时可以直接以机器语言运行，速度很快。
	- 执行程序时，一条一条解释成机器语言给计算机执行，运行速度不如编译后的程序运行的快，但在cache的帮助下，可以提高速度。
		- _pycache
- 静态语言和动态语言 
  - 动态类型语言：数据类型的检查是在运行时做的。用动态类型语言编程时，不用给变量指定数据类型，该语言会在你第一次赋值给变量时，在内部记录数据类型。
  - 静态类型语言：数据类型的检查是在运行前（编译阶段）做的。
- 强类型定义语言与弱类型定义语言  
  - [Why  is Python a dynamic language and also a strongly typed languag](https://wiki.python.org/moin/Why is Python a dynamic language and also a strongly typed language)
  - 强类型定义语言："1" + 2 报错  ；必须用强制转换
  - 弱类型定义语言："1" + 2 得到新的结果
- 编译型VS解释型
  - 编译型
    - 优点：编译只做一次，运行时不需要编译，执行效率高，脱离语言环境独立运行。
    - 缺点：编译之后如果**需要修改**则需将**整个模块重新编译**，开发效率低。不支持跨平台

  - 解释型
    - 优点：兼容性良好（提前安装解释器），任何环境都可以运行。开发效率高，修改代码的时候直接修改就可以。
    - 缺点：每次运行都需要解释一遍，性能上不如解释型语言。

## python的优缺点
- 优点：
	1. 优雅、明确、简单。
	2. 开发效率高，避免重复造轮子
	3. 高级语言（高级的数据结构以及相应的库函数）
	4. 面向对象
	5. 可移植性
	6. 可扩展性
	7. 可嵌入性
	8. 内存管理器（c/c++的内存是需要程序员管理的，而python中内存管理器是由python解释器负责的）


- 缺点：
	1. 速度慢
	2. 代码不能加密
	3. 线程不能利用多CPU	
## python解释器

常用的解释器：

- Cpython：官方推荐，可以转成C语言能识别的字节码
- Jpython：可以转成Java语言能识别的字节码
- Ironpython：可以转成.Net语言能识别的字节码
- pypy：动态编译，一次性全部转化（执行效率与开发效率都高）（未来的趋势）




## python发展史
- 1989年圣诞节假期，Guido开始写Python语言的编译器
- python2.4 Django诞生
- 2008年 python2.6与3.0同时产生



## 算法是什么

计算机编程就是告诉计算机如何做。计算机多才多艺，但不太善于独立思考，我们必须提供详尽的细节，使用它们能够明白的语言将算法提供给它们。<u>算法只不过是流程或菜谱的时髦说法</u>，详尽地描述了如何完成某项任务。



## 语句与表达式

表达式是一些东西（相当于菜谱中的原料），而语句做一些事情（菜谱中的操作说明）。

如表达式： `2*2`

语句：`print(2*2)`



# 第一个python程序
```python
print("hello word")
```

用来测试我们刚配置好的环境能否使用。



## 变量

- why：简洁，将运算的中间结果暂时存到内存，以便后续程序调用

- what：代指一些内容或**表示一种指代关系**，**变量可以指向任何数据类型**

- how：
  - 驼峰：   AgeOfOldboy = 73
  - 下划线： age_of_oldboy
  
- where：代指复杂过长的数据

- 变量扩展： 在内存上的细节（贴标签）

- 值并非存储在变量中，而是存储在变量指向的计算机内存中。多个变量可指向同一个值。

- **变量在内存中是唯一命名的**

- **变量与数据类型的区分**

  

## 常量
- why：生活中存在一直不变的
- what：一直不变的量，python中没有真正不变的常量，为了迎合，全部大写的变量被称为常量
- how：变量名全用大写字母组成来提醒。
- where：BIRTH_OF_CHINA = 1949



## 注释

- why：解释说明，便于理解
- what：注释
- how：
  - 单行注释 #
  -  多行注释''' abc''' 或"""abc """
- where：函数，类，文件都需要注释；难以理解的代码后面。



##  基础数据类型

why：机器是很傻的，分辨不出，所以人为的划分，我们告诉计算机，他能做它相应的一些操作。

what：

- 对数据进行明确的归类划分，便于执行特定的操作。

- int：100、102 就是数字，数字可以做+-*/
  - 32位机器：-2^31~2^31-1
  - 64位机器：-2^63~2^63-1

- list：[1,2,3,'中国'] （list）

- str：'china' 记录信息描述信息(str)

  str(字符型)：'abc' "abc" '''abc''' """abc"""

  - '''abc'''用于换行  

     ```python
     msg=''' 
     今天
     明天
     后天
     '''
     ```

     

  - 单双引号配合使用

     ```python
     content="I'm xiaobai, 18 years old."
     ```

     

  3. 字符串可以拼接（相加）   也可以用字符串与数字相乘

- bool（布尔型）:True False 判断真假

  -  判断变量指向的是什么数据类型type()

  ```
  if type(a) is list :
  ```

- 变量与数据类型的区别：

  - datatype： a data type or simply type is an attribute of data which tells the compiler or interpreter how the programmer intends to use the data. 



## 用户交互

- 内容 = input（提示信息）str数据类型

- 练习：用户输入姓名，年龄，性别，并打印'我叫：，今年：，性别：。

```python
name = input('请输入姓名:')
sex = input('请输入性别:')
age = input('请输入年龄:')
msg = '我叫：'+ name +'，性别：' + sex + '，年龄：' + age + '。'
print(msg)
```





##  流程控制

###  if语句

1. if： 

```python
if 3>2:
   print(666)
print(222)
```



2. if else:

```python
age = int(input("请输入年龄"))

if age > 18 :
	print("恭喜你成年了！")
else:
	print("小屁孩")
```



3. if elif elif...else (多选一，**从上到下运行，一旦满足就退出**):

```python
score = int(input("请输入分数"))
if score >= 80 and score <= 100:
	print("优秀！")
elif score >= 70 :	
	print("良好")
elif score >= 60 :	
	print("及格")	
elif score >= 0 :
	print("不及格")
else:
	print('error')
```



4. if if else else:(尽量不要超过3层嵌套)

```python
username = input("请输入用户名:")
password = input("请输入密码:")
your_code = input("请输入验证码:")
code = 'abc'
name = 'naqin'
pw = '123'
if code == your_code:
	if name == username and password == pw:
	print("成功！")
	else:
	print("账号或密码错误!")
else:
print("验证码错误！")
```



5. 补充：

   在C语言中会出现“悬挂else”的情况，但在python中是不存在的，因为python使用缩进来区分代码块

   

## 循环

### while

- 基本循环

```python
while 条件：
	循环体    
```

- 终止循环

```python
# 通过标志位 flag 终止循环 
# 打印1~100
flag = True
num = 1
while flag :
    if(num == 100):
        flag = False
    print(num)
    num +=1
```



- break

```python
打印1~100之间的偶数
num = 1
while num :
    if(num == 101):
        break
    elif num % 2 ==0:
        print(num)
    num +=1
```



- 调用系统命令：quit(),exit()

- **continue(终止本次循环)** (出错了)

```python
使用while循环打印1 2 3 4 5 6 8 9 10

#错误代码： 错因： 循环驱动放在了条件判断后面，在一次中止后，循环驱动无法改变，所以后面循环部分都无法执行。
num = 1
while num <= 10:
    if num == 7 :
        continue 
    print(num)
    num += 1
    
#正确代码：
num = 0
while num < 10:
    num += 1
    if num == 7:
        continue
    print(num)
      	
	
```

- while...else... 
  - 当while循环正常执行完，中间没有被break中止的话，就会执行else后面的语句。

 

### for

```
for i in list
```



note：虽然python中没有switch语句，我们可以用if-else代替，更优雅的是使用字典来代替。简洁而且查询速度快。

------------


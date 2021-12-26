---
title: Python 字符串相关操作与方法 
date: 2019-04-01 10:28:37
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-string
copyright: true
---



{% cq %}Python字符串相关操作方法：索引，切片，count，startswith，endswith，split，join，format，strip，is系列，find，index，upper，capitalize，center。 {% endcq %}

<!-- more -->

---------------------



## 1. 字符串的索引与切片

1. 字符串从左至右是有顺序的，我们通过索引来确定它的位置。索引类似C语言中的下标
   - s[index]

2. 切片是通过索引(索引：索引：步长)截取字符串的一段，**形成新的字符串**
   - s[start_index : end_index+1 : step]
   - 顾头不顾腚（结尾得往下取一位）
   - 倒序，需要使用反向步长s[::-1]
   - 索引无论使用正数还是负数都仅表示位置。这里是否使用反向步长需要注意一下

```python
print(a[-1:0])  #不能从-1 到 0 
print(a[-1:-5]) #不能从-1 到 -5
print(a[-1:-5:-1]) #以上可以加上步长   #倒序
print(a[-5:-1])    #或从左向右

原因在于默认步长为1，所以不能直接从右向左
```

3. **注意：索引、切片出来的数据与原来是没有联系的。**


```python
s2 = s1[0]
s2 与 s1 没有联系
s2的内容是另开辟的
```





## 2. 字符串的常用操作方法

1. **注意**： 新字符串与原字符串没有联系，这些操作都是产生一个新的字符串。

2. count 

   - 计算字符串中参数出现的个数

   ```python
   res = a.count("a")
   res = a.count("a",4,8)  #对res的切片内容进行a的计数
   ```
   
3. startswith 与 endswith 判断以什么为开头，什么为结尾

```python
a = 'abcdefghijklmnopqrstuvwxyz'
print(a.startswith("a"))   返回True
print(a.startswith("d"))   返回False
print(a.startswith("d",3,6))  返回True
print(a.endswith("z"))     返回True
```

3. split 
   - 形成一个不包含这个分割元素的列表(默认按照空格分格，返回一个链表)
   - **str --->list**

```python
a = 'abcdefghijklmnopqrstuvwxyz'
b = a.split()
print(b,type(b))
##['abcdefghijklmnopqrstuvwxyz'] <class 'list'>
c = a.split('f')
print(c,type(c))
##['abcde', 'ghijklmnopqrstuvwxyz']
```

4. join (iterate)非常好用   联合

   - list ---> str
   - iterate 是可迭代对象 
   - **前提：使用join方法的对象必须是字符串！！！**

   ```python
     s1 = 'xiao'
     s2 = '+'.join(s1)
     print(s2)       #x+i+a+o
   
     l1 = ['xiaobai','xiaohuang','xiaohei'] 
     s3 = ':'.join(l1)
     print(s3)       #xiaobai:xiaohuang:xiaohei
   ```

   

5. format的三种玩法，**格式化输出**

```python
    res = '{}{}{}'.format('naqin',18,'male')
    naqin18male

    res = '{1}{0}{1}'.format('naqin',18,'male')
    18naqin18

    res = '{name}{age}{sex}'.format(name='naqin',age=18,sex='male')
    naqin18male
```

6. format方法

   ```python
   # 占位填充
   format('ab%scd'%5)             # ab5cd
   # 填充
   format('aksfhakefhk','<20')    # 'aksfhakefhk         '
   # 填充:
   format('aksfhakefhk',':<20')   # 'aksfhakefhk:::::::::'
   # 填充*
   format('lfajlajl', '*>30')     # '**********************lfajlajl'
   # 默认
   format(2918)                   # '2918'
   # 十六进制的值
   format(0x500, 'X')             # '500'
   # 在总个数内不填充
   format(3.14, '0=4')            # '3.14'
   # 不够5个就用0填充
   format(3.14, '0=5')            # '03.14'
   # 小数点后保留 2-1 位
   format(3.14159, '.2')          # '3.1'
   # 总数不够就用0 填充
   format(3.14159, '05.3')        # '03.14'
   # 科学计数
   format(3.14159, 'E')           # '3.141590E+00'
   ```

   

7. strip  移除字符串头尾指定的字符

   - 默认去除空格，tab，\t,\n
   - 去除指定的字符  (从前往后从后往前，遇到一个清除一个，若**遇到不含参数内的字符时停止**)

   ```
     s4 = 'rre小r白qsd'
     s5 = s4.strip('rqsed')
     print(s5)  #小r白
   ```

   - 只能删除开头或是结尾的字符，不能删除中间部分的字符。

8. replace

   - replace方法不是对原来的字符串做改变，而是新产生一个改变后的字符串，所以依旧需要赋值替换。

```python
msg = '小白很丑，小白是xx'
msg1 = msg.replace('小白','太黑')
#小黑很丑，小黑是xx
msg1 = msg.replace('小白','太黑'，1)   默认全部替换
```

8. is系列
   - 应用：字符串合法性检查

```python
a.isalnum()  #字符串由字母或数字组成
a.isalpha()  #只由字母组成
a.isdecimal() #只由十进制组成
```

9. find（） 返回找到的元素的索引，找不到返回-1

10. index（）返回找到的元素的索引，找不到报错

11. upper(所有字母大写，中文或数字忽略) 、lower（所有字母小写）

- 应用：验证码（不区分大小写）

12. capitalize（首字母大写）、swapcase(大小写翻转)、title（每个单词大写）

13. center

```python
st = 'runoob'
print(st.center(50,'*'))
**********************runoob**********************
```



--------------------






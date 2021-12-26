---
title: Pandas基础
copyright: true
date: 2019-10-18 17:58:39
tags: [Pandas,数据分析,python,学习笔记]
categories: Pandas
comments: true
urlname:  learning_Pandas_1
---



{% cq %}数据分析三剑客之Pandas。 {% endcq %}

<!--more-->

# 概述

在Pandas中有两个核心数据结构：Series 和 DataFrame。Series 理解为一行数据，DataFrame 理解为由 Series 构成的二维表格。



## Series

Series是一种类似与一维数组的对象，由下面两个部分组成：

- values：一组数据（ndarray类型）
- index：相关的数据索引标签



### Series的创建

两种创建方式：

- 由列表或numpy数组创建

默认索引为0到N-1的整数型索引

```python
import pandas as pd
from pandas import Series,DataFrame
import numpy as np

# 使用列表创建Series
Series(data=[1,2,3])
```

还可以通过设置index参数指定索引

```python
s = Series(data=[1,2,3],index=['a','b','c'])
s
s[0]
s['a']
s.a
```



### Series的索引和切片

可以使用中括号取单个索引（此时返回的是元素类型），或者中括号里<font color=red>一个列表</font>取多个索引（此时返回的是一个Series类型）。

显式索引：

- 使用index中的元素作为索引值
- 使用s.loc[]（推荐）:注意，loc中括号中放置的一定是显示索引

 注意，此时是闭区间



### Series的基本概念

可以使用s.head(),tail()分别查看前n个和后n个值

```python
s = Series(data=[1,1,2,3,4,5,5,6,7,8])
s.head(2)
```

**对Series元素进行去重**

```python
s.unique()
```

当索引没有对应的值时，可能出现缺失数据显示NaN（not a number）的情况

- 使得两个Series进行相加

```python
s1 = Series([1,2,3],index=['a','b','c'])
s2 = Series([1,2,3],index=['a','d','c'])
s = s1 + s2
s
```

可以使用pd.isnull()，pd.notnull()，或s.isnull(),notnull()函数检测缺失数据

```python
s[['a','b','c']]
s[[0,1,2]]
s[[True,False,True,False]]
s.isnull()
s.notnull()
# 将Series中的空值直接进行了清洗
s[s.notnull()]
```

**Series之间的运算**

- 在运算中自动对齐不同索引的数据
- 如果索引不对应，则补NaN



## DataFrame

DataFrame是一个【表格型】的数据结构。DataFrame由按一定顺序排列的多列数据组成。设计初衷是将Series的使用场景从一维拓展到多维。DataFrame既有行索引，也有列索引。

- 行索引：index
- 列索引：columns
- 值：values



### DataFrame的创建

最常用的方法是传递一个字典来创建。DataFrame以字典的键作为每一【列】的名称，以字典的值（一个数组）作为每一列。

此外，DataFrame会自动加上每一行的索引。

使用字典创建的DataFrame后，则columns参数将不可被使用。

同Series一样，若传入的列与字典的键不匹配，则相应的值为NaN。



使用ndarray创建DataFrame

```python
df = DataFrame(data=np.random.randint(0,100,size=(3,4)),index=['a','b','c'],columns=['A','B','C','D'])
df
```

DataFrame属性：values、columns、index、shape

```python
df.values
df.columns
df.index
df.shape
```

使用dict创建DataFrame

```python
dic = {
    'zhangsan':[99,99,99,99],
    'lisi':[0,0,0,0]
}
df = DataFrame(data=dic,index=['语文','数学','英语','理综'])
df
```



### DataFrame的索引

① 对列进行索引

- 通过类似字典的方式  df['q']
- 通过属性的方式     df.q

可以将DataFrame的列获取为一个Series。返回的Series拥有原DataFrame相同的索引，且name属性也已经设置好了，就是相应的列名。



② 对行进行索引

- 使用.loc[]加index来进行行索引
- 使用.iloc[]加整数来进行行索引

 同样返回一个Series，index为原来的columns。



③ 对元素索引的方法

- 使用列索引
- 使用行索引(iloc[3,1] or loc['C','q']) 行索引在前，列索引在后



### 切片

【注意】 直接用中括号时：

- 索引表示的是列索引
- 切片表示的是行切片

```python
df[0:2]  # 行切片
```

在loc和iloc中使用切片(切列) ：      df.loc['B':'C','丙':'丁']

```python
df.iloc[:,0:1]
```



### DataFrame的运算



DataFrame之间的运算

同Series一样：

- 在运算中自动对齐不同索引的数据
- 如果索引不对应，则补NaN
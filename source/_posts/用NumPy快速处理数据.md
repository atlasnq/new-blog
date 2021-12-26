---
title: 用NumPy快速处理数据
copyright: true
date: 2019-10-16 14:45:29
tags: [Numpy,数据分析,python,学习笔记]
categories: Numpy
comments: true
urlname:  learning_Numpy_1
---



{% cq %}本篇介绍使用NumPy快速处理数据。 {% endcq %}

<!--more-->



# 概述

- Numpy（Numerical Python）是Python语言的一个扩展程序库，支持大量的维度数组与矩阵运算，此外也针对数组运算提供大量的数学函数库。

- NumPy 所提供的数据结构是 Python 数据分析的基础。



## 列表与数组

​	标准的 Python 中，用列表 list 保存数组的数值。由于列表中的元素可以是**任意的对象**，所以列表中 list 保存的是**对象的指针**。虽然在 Python 编程中隐去了指针的概念，但是数组有指针，Python 的列表 list 其实就是数组。这样如果我要保存一个简单的数组 [0,1,2]，就需要有 3 个指针和 3 个整数的对象，这样对于 Python 来说是非常不经济的，浪费了内存和计算时间。

​	为什么要用 NumPy 数组结构而不是 Python 本身的列表 list？这是因为列表 list 的元素在系统内存中是分散存储的，而 NumPy 数组存储在一个均匀连续的内存块中。这样数组计算遍历所有的元素，不像列表 list 还需要对内存地址进行查找，从而节省了计算资源。

​	另外在内存访问模式中，缓存会直接把字节块从 RAM 加载到 CPU 寄存器中。因为数据连续的存储在内存中，NumPy 直接利用现代 CPU 的矢量化指令计算，加载寄存器中的多个连续浮点数。另外 NumPy 中的矩阵计算可以采用多线程的方式，充分利用多核 CPU 计算资源，大大提升了计算效率。	

​	当然除了使用 NumPy 外，你还需要一些技巧来提升内存和提高计算资源的利用率。一个重要的规则就是：**避免采用隐式拷贝，而是采用就地操作的方式**。举个例子，如果我想让一个数值 x 是原来的两倍，可以直接写成 `x*=2`，而不要写成 `y=x*2`。



## ndarray 与 ufunc

在 NumPy 里有两个重要的对象：

- ndarray（N-dimensional array object）解决了多维数组问题
- ufunc（universal function object）包含对数组进行处理的函数。



## ndarray 对象

​	ndarray 实际上是多维数组的含义。在 NumPy 数组中，维数称为秩（rank），一维数组的秩为 1，二维数组的秩为 2，以此类推。在 NumPy 中，每一个线性的数组称为一个轴（axes），其实秩就是描述轴的数量。



**创建数组**



**结构数组**



## ufunc 运算

​	ufunc 是 universal function 的缩写，是不是听起来就感觉功能非常强大？确如其名，它能对数组中每个元素进行函数操作。NumPy 中很多 ufunc 函数计算速度非常快，因为都是采用 C 语言实现的。



**连续数组的创建**





**算术运算**





**统计函数**



## Numpy 排序



## 创建ndarray

### 使用np.array()创建



**一维数组创建**

```python
import numpy as np
arr = np.array([1,2,3,4,5])
arr
```

**二维数组创建**

```python
arr = np.array([[1,2,3],[4,5,6]])
arr = np.array([[1,2,3],[4,5.123,6]])
arr
```



注意：

- numpy默认ndarray的所有元素的类型是相同的
- 如果传进来的列表中包含不同的类型，则统一为同一类型，优先级：str>float>int



### 使用np的routines函数创建

`np.linspace(start, stop, num=50, endpoint=True, retstep=False, dtype=None)`  等差数列

```python
np.linspace(0,100,num=10)
```



 `np.arange([start, ]stop, [step, ]dtype=None)`

```python
np.arange(0,100,2)
```



`np.random.randint(low, high=None, size=None, dtype='l')`

- 时间种子（随机因子）：无时无刻都在变化的值（系统时间）
- 固定随机因子就可以固定随机函数的随机性

```python
np.random.seed(90)
np.random.randint(0,100,size=(3,5))
```



`np.random.random(size=None)`  

生成0到1的随机数，**左闭右开**  

```python
np.random.seed(3)
np.random.random(size=(3,4))
```



## ndarray的属性

4个必记参数：

- ndim：维度
- shape：形状（各维度的长度）
- size：总长度
- dtype：元素类型

```python
type(img_arr) 		# numpy.ndarray
img_arr.shape		
arr.shape			
arr.size
arr.dtype
arr.ndim
```



## ndarray的基本操作

### 索引

```python
arr = np.random.randint(0,100,size=(5,8))	# 创建5行8列的数组

arr[0]			# 取第0行
arr[[0,1]]		# 取一、二两行
arr[1,[2,3,4]]	# 取一行中的第2，3，4列
```



### 切片

```python
arr = np.random.randint(0,100,size=(5,8))	# 创建5行8列的数组
# 获取二维数组的前两行
arr[0:2]			
# 获取二维数组前两列
arr[:,0:2]  		 	# arr[hang,lie]
# 获取二维数组前两行和前两列数据
arr[0:2,0:2]
# 将数组的行倒序
arr[::-1,:]       		
# 列倒序
arr[:,::-1]
#全部倒序
arr[::-1,::-1]
```



### 变形

使用arr.reshape()函数，注意参数是一个tuple！

基本使用

1. 将一维数组变形成多维数组

```python
arr = np.random.randint(0,100,size=(16))
arr.reshape((2,8))
```

2. 将多维数组变形成一维数组

```python
arr = np.random.randint(0,100,size=(4,4))
arr.reshape(16)
```



### 级联

`np.concatenate()`

- 一维，二维，多维数组的级联，实际操作中级联多个二维数组

级联需要注意的点：

- 级联的参数是列表：一定要加中括号或小括号
- 维度必须相同
- 形状相符：在维度保持一致的前提下，如果进行横向（axis=1）级联，必须保证进行级联的数组行数保持一致。如果进行纵向（axis=0）级联，必须保证进行级联的数组列数保持一致。
- 可通过axis参数改变级联的方向



例子：

- 合并两张照片

```python
# 使用matplotlib.pyplot获取一个numpy数组，数据来源于一张图片

import matplotlib.pyplot as plt
img_arr = plt.imread('./cat.jpg')

img = np.concatenate((img_arr,img_arr),axis=1)    # axis=1 合并列/横向级联
plt.imshow(img)
img = np.concatenate((img_arr,img_arr),axis=0)    # axis=0 合并行/纵向级联
plt.imshow(img)
```

- 制作九宫格图片

```python
arr_col = np.concatenate((img_arr,img_arr,img_arr),axis=1)
plt.imshow(arr_col)
arr_row = np.concatenate((arr_col,arr_col,arr_col),axis=0)
plt.imshow(arr_row)
```



## ndarray的聚合操作

### 求和np.sum

```python
arr = np.random.randint(0,100,size=(5,8))
arr.sum()              # 所有元素之和
arr.sum(axis=0)        # 合并列
arr.sum(axis=1)        # 合并行
```

### 最大最小值：np.max/ np.min

```python
arr.max()
arr.min()
```

### 平均值：np.mean()

```python
arr.mean(axis=0)
```

### 其他聚合操作

| Function Name | NaN-safe Version | Description                               |
| ------------- | ---------------- | ----------------------------------------- |
| np.sum        | NaN-safe Version | NaN-safe Version                          |
| np.prod       | np.nanprod       | Compute product of elements               |
| np.mean       | np.nanmean       | Compute mean of elements                  |
| np.std        | np.nanstd        | Compute standard deviation                |
| np.var        | np.nanvar        | Compute variance                          |
| np.min        | np.nanmin        | Find minimum value                        |
| np.max        | np.nanmax        | Find maximum value                        |
| np.argmin     | np.nanargmin     | Find index of minimum value               |
| np.argmax     | np.nanargmax     | Find index of maximum value               |
| np.median     | np.nanmedian     | Compute median of elements                |
| np.percentile | np.nanpercentile | Compute rank-based statistics of elements |
| np.any        | N/A              | Evaluate whether any elements are true    |
| np.all        | N/A              | Evaluate whether all elements are true    |
| np.power      |                  | 幂运算                                    |



## ndarray的排序

### 快速排序

np.sort()与ndarray.sort()都可以，但有区别：

- np.sort()不改变输入
- ndarray.sort()本地处理，不占用空间，但改变输入

```python
np.sort(arr,axis=0)		# 按行排序
np.sort(arr,axis=1)		# 按列排序
```




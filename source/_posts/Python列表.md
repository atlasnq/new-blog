---
title: Python列表的相关操作与方法
date: 2019-03-24 15:40:07
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-list
copyright: true
---



{% cq %}Python列表的介绍，以及列表的常用操作与方法，创建，增：append、insert、extend，删：pop、remove、del、clear，查：索引、切片、sorted，改：按索引、切片。 {% endcq %}

<!-- more -->



-------------



## 1.列表

- why：int、bool、str存在缺陷

  - str:存储少量的数据；所有的操作获取的内容都是 str类型，存储的数据类型单一。

- what：

  - 列表可以承载任意数据类型，存储大量的数据。
  - Python常用的容器型数据类型。list 列表，其它语言：Java：数组
  - 列表是有序的，可索引，切片（步长）。  
    - 与字符串稍有一点区别（取出来的元素数据类型不同）

  - 索引、切片(一切片 就是一个小列表)、步长

  ```
  li = [100,'taibai',True,[1,2,3]]
  #索引
  # print(li[0] , type(li[0]))
  # print(li[1],type(li[1]))
  #切片  (顾头不顾腚)
  #print(li[:2])
  ```

  -  相关练习题：

  ```
  li = [1, 3, 2, "a", 4, "b", 5,"c"]
  通过对li列表的切片形成新的列表l1,l1 = [1,3,2]
  通过对li列表的切片形成新的列表l2,l2 = ["a",4,"b"]
  通过对li列表的切片形成新的列表l4,l4 = [3,"a","b"]
  通过对li列表的切片形成新的列表l6,l6 = ["b","a",3]
  ```

## 2. 列表的常用操作与方法

除了pop有返回值，其它方法都没有返回值

### 1. 列表的创建

- 方式一：

```python
l1 = [1,2,'abc']
```



- 方式二：

```python
l1 = list()
l1 = list('feajoijae')
```

- 方式三：列表推导式：
  - 根据现有元素，和已经确定的推导规则，可以依次推出新的列表的每一项。

```python
lis1 = [1,2,3,4,5,6]
lis2 = [x**x for x in lis1]
print(lis2)    #[1, 4, 27, 256, 3125, 46656]
lis3 = [[x, x*x , x**x] for x in lis1]
lis4 = [(x, x*x , x**x) for x in lis1]
lis5 = [{x, x*x , x**x} for x in lis1]
print(lis3)  #[[1, 1, 1], [2, 4, 4], [3, 9, 27], [4, 16, 256], [5, 25, 3125], [6, 36, 46656]]
print(lis4)  #[(1, 1, 1), (2, 4, 4), (3, 9, 27), (4, 16, 256), (5, 25, 3125), (6, 36, 46656)]
print(lis5)  #[{1}, {2, 4}, {27, 9, 3}, {16, 256, 4}, {25, 3125, 5}, {46656, 36, 6}]
```

### 2. 增

1. append， 列表最后追加一个元素

```python
l1 = ['小A','小B','小C','xiao','小D']
l1.append('xx')
print(l1)

#注意:
print(l1.append('xx')) ##None  ##打印错了,只是一种追加的方式，没有返回值
```



2. insert，在列表任意位置插入

```python
l1 = ['太白','女神','吴老师','xiao','阎龙']
l1.insert(2,'xx')
print(l1)
```



3. extend，列表最后**迭代追加**一组数据(组成对象的最小元素)

```python
l1 = ['小A','小B','小C','小D']
l1.extend('abcd')
l1.extend(['xiao'])  #组成对象的最小元素
```

### 2. 删

1. pop 按照索引位置删除,返回删除的元素

   1. （只有pop操作返回，其它都不返回）
   2. pop() 默认删除最后一个

   ```python
   l1 = ['小A','小B','小C','xiao','小D']
   l1.pop(-2)
   ```

2. remove  删除指定元素   

   1. 如果有重名元素呢？默认删除从左数第一个元素

   ```python
   l1.remove('xiao')
   ```

3. clear() 清空   元素没了，为空列表

4. del   

   1. 按照索引删除

   ```python
   del l1[-1]
   ```

   2. 按照切片删除

   ```python
   del l1[::2]
   ```



当我们需要在循环中对循环条件的列表的元素进行删除时，我们可以用 li[:] 做一个浅拷贝，这样的话遍历这个备份，不会丢失元素。

```python
li=[1,2,3]
for i in li[:]
	if i % 2 == 0:
		li.remove(i)
```



### 3. 改

1. 按索引改

```
l[0] = 'nm'
```



2. 按切片改

```
l = ['小A','小B','小C','xiao','小D']
l[1:3] = 'abcdefg'
print(l) # ['小A', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'xiao', '小D']
# 1,2被代替，和extend效果相似。
```

3. 按切片（涉及步长（非1）就有了个数要求）（必须一一对应） 

```
l = ['小A','小B','小C','xiao','小D']
l[::2] = '对应着'
print(l) #['对', '小B', '应', 'xiao', '着']
```

当步长为默认值1的时候，可以把起点到终点之间元素进行替换，可以增可以减少。

```python
# 增
lst = [1,2,9]
lst[0:2:1] = 'abcdefghi'
print(lst)
# ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 9]
```

```python
# 减
lst = [1,2,9]
lst[0:2:1] = ()
print(lst)
# [9]
```



### 4. 查

- 索引、切片
- 循环

- 其它操作：
  - sort 排序
  - reverse 列表中的元素 反向存放
- 列表可以相加也可以与整数相乘

### 5. 列表的嵌套

```
lis = [2, 3, "k", ["qwe", 20, ["k1", ["tt", 3, "1"]], 89], "ab", "adv"]
将列表中的字符串"1"变成数字101（用两种方式）。
#方法1：
del lis[3][2][1][2]
lis[3][2][1].insert(2,101)
#方法2：  ##不知道索引的前提下
def fun(lis):
    for i in lis:
        if type(i) is list:
        # if isinstance(i , list):
            fun(i)
        elif i == '1':
            a = lis.index('1')
            del lis[a]
            lis.insert(a,101)
fun(lis)
print(lis)
```

注意：有些函数是针对字符串的 如replace ，有些是针对列表的，注意使用时候区分



----------


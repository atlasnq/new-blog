---
title: Python集合
date: 2019-03-26 14:14:24
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-set
copyright: true
---



{% cq %}本章介绍了集合，集合最擅长的地方在于它可以排重，求交集并集和补集。 {% endcq %}

<!--more-->



可以使用{} 或者 set（）创建集合，创建空集合必须是set（），因为{}是空字典



## 常用函数与方法



### 添加元素

- add

```python
A = set('abcd')
A.add('e')
print(A) 			# {'b', 'c', 'd', 'a', 'e'}
```



- update

```python
A = set('abcd')
A.update('g')
print(A)    		# {'g', 'c', 'd', 'a', 'b'}
```



### 移除元素

- remove

  - 元素不存在，则会发生错误。

  ```python
  A = set('abcd')
  A.remove('a')
  print(A)    	# {'c', 'd', 'b'}
  A.remove('g')	# KeyError: 'g'
  ```

  

- discard

  - 如果元素不存在，不会发生错误。

  ```python
  A = set('abcd')
  A.discard('a')
  A.discard('g')
  print(A)    # {'c', 'd', 'b'}
  ```

  

- pop

  - 随机删除集合中的一个元素

  ```python
  A = set('abcd')
  A.pop()
  print(A)	# {'d', 'b', 'a'}
  ```

  



### 计算集合元素个数

- len

```python
A = set('abcd')
print(len(A))   # 4个元素
```



### 清空集合

- clear

```python
A = set('abcd')
A.clear()
print(A)          # 变成了空集合 set()
```



- del 集合名字

```python
A = set('abcd')
del A           # 删除后A 就不存在了
print(A)        # NameError: name 'A' is not defined
```



### 判断元素是否在集合中存在

- in  与 not  in

```python
A = set('abcd')
print('e' in A)		# False
print('a' in A)		# True
```



### 将集合变为不可变数据类型

- frozenset

```python
A = set('abcd')
B = frozenset(A)
print(B,type(B))        # frozenset({'c', 'a', 'b', 'd'}) <class 'frozenset'>
print(B.__hash__())     # -2156020053626062124
# print(A.__hash__())   # 报错  可变数据类型是不可hash的
```



## 集合运算	<> & ^ | -



### 判断子集与超集 	< >   或  issubset issuperset

```python
A = set('abcd')
B = set('bd')
print(A < B)			# False
print(A > B)			# True
print(A.issubset(B))	# False
print(B.issubset(A))	# True
print(A.issuperset(B))	# True
```



### 求交集	& 或 intersection 

```python
A = {i for i in range(1,10,2)}
print(A)						# {1, 3, 5, 7, 9}
B = {i for i in range(5,15,2)}
print(B)						# {5, 7, 9, 11, 13}

print(A & B)					# {9, 5, 7}
print(A.intersection(B))		# {9, 5, 7}
```



### 求反交集    ^ 或者  symmetric_difference

```python
A = {i for i in range(1,10,2)}
print(A)						        # {1, 3, 5, 7, 9}
B = {i for i in range(5,15,2)}
print(B)						        # {5, 7, 9, 11, 13}

print(A ^ B)					        # {1, 3, 11, 13}
print(A.symmetric_difference(B))		# {1, 3, 11, 13}
```





### 求并集	| 或 union

```python
A = set('abcde')
B = set('defg')
print(A | B)			# {'b', 'd', 'a', 'g', 'c', 'e', 'f'}
print(A.union(B))		# {'b', 'd', 'a', 'g', 'c', 'e', 'f'}
```



### 求差集	- 或 difference

```python
A = set('abcde')
B = set('defg')
# A有B没有
print(A - B)			# {'b', 'a', 'c'}
print(A.difference(B))	# {'b', 'a', 'c'}
```



## 练习

- 判断一个字典中是否有这些key： ‘AAA’,’BB’,’C’,’DD’,’EEE’(不使用for while)   

```
利用集合判断交集   and
dic = {'AAA':666}
s1 = {'AAA','BB','C','DD','EEE'}
s2 = set(dic.keys())
print(s1 and s2)
```


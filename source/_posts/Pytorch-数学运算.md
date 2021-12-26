---
title: Pytorch-数学运算
copyright: true
date: 2019-06-29 10:16:18
tags: [Pytorch,Deep Learning,学习笔记]
categories: Pytorch学习笔记
comments: true
urlname: learning_PyTorch_6_calculate
---



{% cq %}本篇介绍tensor的数学运算。 {% endcq %}

<!--more-->



# 基本运算

- add/minus/multiply/divide
- matmul
- pow
- sqrt/rsqrt
- round



# 基础运算

- 可以使用 + - * /        推荐
- 也可以使用 torch.add, mul, sub, div

```python
In[3]: a = torch.rand(3,4)
In[4]: b = torch.rand(4)		# 使用broadcast
In[5]: a+b
Out[5]: 
tensor([[0.9463, 1.3325, 1.0427, 1.3508],
        [1.8552, 0.5614, 0.8546, 1.2186],
        [1.4794, 1.3745, 0.7024, 1.1688]])
In[6]: torch.add(a,b)
Out[6]: 
tensor([[0.9463, 1.3325, 1.0427, 1.3508],
        [1.8552, 0.5614, 0.8546, 1.2186],
        [1.4794, 1.3745, 0.7024, 1.1688]])
In[8]: torch.all(torch.eq((a-b),torch.sub(a,b)))	
Out[8]: tensor(1, dtype=torch.uint8)
In[9]: torch.all(torch.eq((a*b),torch.mul(a,b)))
Out[9]: tensor(1, dtype=torch.uint8)
In[10]: torch.all(torch.eq((a/b),torch.div(a,b)))
Out[10]: tensor(1, dtype=torch.uint8)
```

- `torch.all()` 判断每个位置的元素是否相同

  是否存在为0的元素

  ```python
  In[21]: torch.all(torch.ByteTensor([1,1,1,1]))
  Out[21]: tensor(1, dtype=torch.uint8)
  In[22]: torch.all(torch.ByteTensor([1,1,1,0]))
  Out[22]: tensor(0, dtype=torch.uint8)
  ```

  

# matmul

- matmul 表示 matrix mul
- `*` 表示的是element-wise
- `torch.mm(a,b)` 只能计算2D        不推荐
- `torch.matmul(a,b)` 可以计算更高维度，落脚点依旧在行与列。  推荐
- `@` 是matmul 的重载形式   

```python
In[24]: a = 3*torch.ones(2,2)
In[25]: a
Out[25]: 
tensor([[3., 3.],
        [3., 3.]])
In[26]: b = torch.ones(2,2)
In[27]: torch.mm(a,b)
Out[27]: 
tensor([[6., 6.],
        [6., 6.]])
In[28]: torch.matmul(a,b)
Out[28]: 
tensor([[6., 6.],
        [6., 6.]])
In[29]: a@b
Out[29]: 
tensor([[6., 6.],
        [6., 6.]])
```



## 例子

线性层的计算 ： `x @ w.t() + b`

- x是4张照片且已经打平了 (4, 784)
- 我们希望  (4, 784) ---> (4, 512)
- 这样的话w因该是 (784, 512)
- 但由于pytorch默认 第一个维度是 channel-out（目标）， 第二个维度是 channel-in （输入） ， 所以需要用一个转置

note：.t() 只适合2D，高维用transpose 

```python
In[31]: x = torch.rand(4,784)
In[32]: w = torch.rand(512,784)
In[33]: (x@w.t()).shape
Out[33]: torch.Size([4, 512])
```



神经网络 ->  矩阵运算 -> tensor flow



## 2维以上的tensor matmul

- 对于2维以上的matrix multiply ， `torch.mm(a,b)`就不行了。
- 运算规则：只取最后的两维做矩阵乘法
- 对于 [b, c, h, w] 来说，b,c 是不变的，图片的大小在改变；并且也并行的计算出了b，c。也就是支持**多个矩阵并行相乘**。
- 对于不同的size，如果符合broadcast，先执行broadcast，在进行矩阵相乘。

```python
In[3]: a = torch.rand(4,3,28,64)
In[4]: b = torch.rand(4,3,64,32)
In[5]: torch.mm(a,b).shape
RuntimeError: matrices expected, got 4D, 4D tensors at ..\aten\src\TH/generic/THTensorMath.cpp:956
In[6]: torch.matmul(a,b).shape
Out[6]: torch.Size([4, 3, 28, 32])
In[7]: b = torch.rand(4,1,64,32)	
In[8]: torch.matmul(a,b).shape	# 进行了broadcast
Out[8]: torch.Size([4, 3, 28, 32])
In[9]: b = torch.rand(4,64,32)
In[10]: torch.matmul(a,b).shape
RuntimeError: The size of tensor a (3) must match the size of tensor b (4) at non-singleton dimension 1
```



# power

- pow(a, n)   a的n次方  
- `**` 也表示次方（可以是2，0.5，0.25，3）   推荐
- sqrt()   表示 square root 平方根
- rsqrt()  表示平方根的倒数

```python
In[11]: a = torch.full([2,2],3)
In[12]: a.pow(2)
Out[12]: 
tensor([[9., 9.],
        [9., 9.]])
In[13]: a**2
Out[13]: 
tensor([[9., 9.],
        [9., 9.]])
In[14]: aa = a**2
In[15]: aa.sqrt()
Out[15]: 
tensor([[3., 3.],
        [3., 3.]])
In[16]: aa.rsqrt()
Out[16]: 
tensor([[0.3333, 0.3333],
        [0.3333, 0.3333]])
In[17]: aa**(0.5)
Out[17]: 
tensor([[3., 3.],
        [3., 3.]])
```



# Exp log

- exp(n)   表示：e的n次方
- log(a)    表示：ln(a)
- log2() 、 log10()

```python
In[18]: a = torch.exp(torch.ones(2,2))
In[19]: a
Out[19]: 
tensor([[2.7183, 2.7183],
        [2.7183, 2.7183]])
In[20]: torch.log(a)
Out[20]: 
tensor([[1., 1.],
        [1., 1.]])
In[22]: torch.log2(a)
Out[22]: 
tensor([[1.4427, 1.4427],
        [1.4427, 1.4427]])
In[23]: torch.log10(a)
Out[23]: 
tensor([[0.4343, 0.4343],
        [0.4343, 0.4343]])
```



# Approximation

近似相关1

- floor、ceil   向下取整、向上取整
- round    4舍5入
- trunc、frac    裁剪

```python
In[24]: a = torch.tensor(3.14)
In[25]: a.floor(),a.ceil(),a.trunc(),a.frac()
Out[25]: (tensor(3.), tensor(4.), tensor(3.), tensor(0.1400))
In[26]: a = torch.tensor(3.499)
In[27]: a.round()
Out[27]: tensor(3.)
In[28]: a = torch.tensor(3.5)
In[29]: a.round()
Out[29]: tensor(4.)
```



# clamp

近似相关2  （用的更多一些）

- gradient clipping  梯度裁剪  
- (min)      小于min的都变为某某值
- (min, max)   不在这个区间的都变为某某值
- 梯度爆炸：一般来说，当梯度达到100左右的时候，就已经很大了，正常在10左右，通过打印梯度的模来查看 `w.grad.norm(2)`
- 对于w的限制叫做weight clipping，对于weight gradient clipping称为 gradient clipping。

```python
In[30]: grad = torch.rand(2,3)*15
In[31]: grad.max()
Out[31]: tensor(10.6977)
In[32]: grad.clamp(10)		
Out[32]: 
tensor([[10.0000, 10.6977, 10.0000],
        [10.0000, 10.0000, 10.0000]])
In[33]: grad
Out[33]: 
tensor([[ 6.7738, 10.6977,  4.4314],
        [ 7.8088,  4.8236,  3.6213]])
In[34]: grad.clamp(0,10)
Out[34]: 
tensor([[ 6.7738, 10.0000,  4.4314],
        [ 7.8088,  4.8236,  3.6213]])
```


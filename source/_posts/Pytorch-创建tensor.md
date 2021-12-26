---
title: Pytorch-创建tensor
copyright: true
date: 2019-06-24 10:53:52
tags: [Pytorch,Deep Learning,学习笔记]
categories: Pytorch学习笔记
comments: true
urlname: learning_PyTorch_2_create_tensor
---



{% cq %}本篇介绍创建tensor的几种方式。 {% endcq %}

<!--more-->



# Import from numpy

- `from_numpy()`
- float64 是 double 类型，也就是说从numpy导入的float其实是**double类型**。
- 从numpy导入的 int 还是 int 类型

```python
In[2]: import numpy as np
In[3]: import torch
In[4]: a = np.array([2,3.3])
In[5]: torch.from_numpy(a)
Out[5]: tensor([2.0000, 3.3000], dtype=torch.float64)
    
In[6]: a = np.ones([2,3])
In[7]: torch.from_numpy(a)
Out[7]: 
tensor([[1., 1., 1.],
        [1., 1., 1.]], dtype=torch.float64)
```



# Import from List

- 数据量不是很大，不需要numpy作为载体
- `torch.tensor([ ])` 、 `torch.FloatTensor([ ])` 、 `torch.Tensor([ ])`关系在后面介绍
- tensor 与 Tensor易混淆
- 多使用tensor。

```python
# 一维
In[17]: torch.tensor([2, 3.2])
Out[17]: tensor([2.0000, 3.2000])
# 二维 
In[19]: torch.tensor([[2,3.2],[1,22.3]])
Out[19]: 
tensor([[ 2.0000,  3.2000],
        [ 1.0000, 22.3000]])
# 查看数据类型
In[20]: a = torch.tensor([[2,3.2],[1,22.3]])
In[21]: a.type()
Out[21]: 'torch.FloatTensor'
    
# tensor 与 Tensor 易混淆
# tensor只能接收数据，来对向量进行创建
# Tensor既可以通过维度来创建向量，也可以通过接收数据来创建向量.
# 两者的区别在于：前者是以参数的形式(维度1，维度2，...)来组织形状，后者的数据必须放在列表中([数据1,数据2,...]).
# 但建议使用tensor来接收向量，这样减少混淆。
In[24]: a = torch.Tensor([2,3])
In[25]: a
Out[25]: tensor([2., 3.])
In[32]: a = torch.Tensor(2,3)
In[33]: a
Out[33]: 
tensor([[0., 0., 0.],
        [0., 0., 0.]])

a = torch.FloatTensor([1,2])
b = torch.tensor([1,2])
b.type()
Out[42]: 'torch.LongTensor'
# 结论：torch.FloatTensor([1,2]) 不等于 torch.tensor([1,2])
```

- `torch.tensor()` 与 `torch.Tensor()` 默认 生成 `torch.FloatTensor` 类型，增强学习中多为 `torch.DoubleTensor`
- 通过 `torch.set_default_tensor_type(torch.DoubleTensor)` 来更改
- `torch.tensor()` 如果列表中都是int类型，则它会生成 `torch.LongTensor`

```python
In[173]: a = torch.tensor([2.2,3])
In[174]: a.type()
Out[174]: 'torch.FloatTensor'

In[178]: torch.set_default_tensor_type(torch.DoubleTensor)
In[179]: a = torch.tensor([2.2,3])
In[180]: a.type()
Out[180]: 'torch.DoubleTensor'
    
但是对于 tensor([2,3]) 创建的是int64类型的
In[181]: a = torch.tensor([2,3])
In[182]: a.type()
Out[182]: 'torch.LongTensor'
    
a = torch.Tensor([2,3])
a.type()
Out[188]: 'torch.FloatTensor'
# torch.Tensor is an alias for the default tensor type (torch.FloatTensor).
```



# data uninitialized

生成未初始化的数据

- `torch.empty(d1,d2,d3)`
- `torch.FloatTensor(d1,d2,d3)`
- `torch.IntTensor(d1,d2,d3)`

未初始化的tensor将出现的问题

```python
torch.empty(1)
Out[50]: tensor([0.])
torch.Tensor(2,3)
Out[51]: 
tensor([[0.0000e+00, 0.0000e+00, 1.4013e-45],
        [0.0000e+00, 1.4013e-45, 0.0000e+00]])
torch.IntTensor(2,3)
Out[52]: 
Out[78]: 
tensor([[1902983832,      32767,          6],
        [         0,          1,          0]], dtype=torch.int32)
torch.FloatTensor(2,3)
Out[53]: 
tensor([[1.1747e+30, 4.5916e-41, 1.4013e-45],
        [0.0000e+00, 1.4013e-45, 0.0000e+00]])
```

- 这些数据有的特别特别小，有的特别特别大
- 这些数据如果没有后续的处理覆盖，将会产生bug，例如：可能在后面产生无穷大的数

```python
torch.isnan(torch.Tensor(2,3))
# 其布尔元素表示每个元素是否为 'nan'
Out[55]: 
tensor([[0, 0, 0],
        [0, 0, 0]], dtype=torch.uint8)
a = torch.FloatTensor(2,3)
torch.isnan(a)
Out[57]: 
tensor([[0, 0, 0],
        [0, 0, 0]], dtype=torch.uint8)
torch.isfinite(a)
# 其布尔元素表示每个元素是否为有限元素
Out[58]: 
tensor([[1, 1, 1],
        [1, 1, 1]], dtype=torch.uint8)
# 虽然这里都是正常的，但存在后面出现问题的可能
```

- tensor只是一个容器，后面会将自己的数据放入的。



# rand/rand_like, randint

随机初始化

推荐使用随机初始化。

- rand 会随机的在[0, 1] 之间取一个数。
- rand_like( a )  读取向量 a 的shape在送到rand函数
- randint   先指定区间 `[ min, max )` ,然后指定shape，shape要放在列表或元组中



```python
In[189]: torch.rand(3,3)
Out[189]: 
tensor([[0.1364, 0.6610, 0.7115],
        [0.5758, 0.2318, 0.0798],
        [0.1356, 0.9596, 0.3406]])
In[190]: a = torch.rand(3,3)
In[191]: torch.rand_like(a)
Out[191]: 
tensor([[0.5966, 0.9067, 0.6670],
        [0.5968, 0.1216, 0.3202],
        [0.8507, 0.3520, 0.4741]])

In[193]: torch.randint(1,10,(3,3))
Out[193]: 
tensor([[7, 3, 8],
        [8, 2, 1],
        [8, 4, 8]])
In[194]: torch.randint(1,10,[3,3])
Out[194]: 
tensor([[3, 8, 2],
        [3, 5, 2],
        [8, 8, 3]])
```

N(0, 1)

- `randn()`
- 均值为0，方差为1，数据集中在0附近
- 权值w 或 偏置 b 的一个初始化

N(u, std)

- `normal()`

```python
In[201]: torch.randn(3,3)
Out[201]: 
tensor([[ 0.3099, -0.8410, -0.3561],
        [ 1.0023, -0.4343,  0.3544],
        [-0.7071, -0.3124, -0.3938]])
In[202]: torch.normal(mean=torch.full([10], 0), std=torch.arange(1, 0, -0.1))
Out[202]: 
tensor([-3.5323e-01,  7.4789e-01,  5.8816e-01,  1.9938e+00,  3.8165e-01,
        -9.8357e-01,  5.2820e-01, -1.6654e-02, -4.8233e-02,  9.7792e-04])
In[203]: torch.normal(mean=torch.full([10], 0), std=torch.arange(1, 0, -0.1))
Out[203]: 
tensor([-0.3920,  1.2376,  0.3669, -0.8245, -1.2928,  0.4541, -0.0843,  0.1847,
        -0.1818, -0.0868])

# full方法解释
# 生成二维向量
In[204]: torch.full([2,3],7)
Out[204]: 
tensor([[7., 7., 7.],
        [7., 7., 7.]])

# 生成一维向量
In[206]: torch.full([1],7)
Out[206]: tensor([7.])
    
# 生成标量
In[205]: torch.full([],7)
Out[205]: tensor(7.)

```



# arange/range

- 生成等差数列 `arange()` ,默认以1来递增
- range现在已经不建议使用了

```python
In[207]: torch.arange(0,10)
Out[207]: tensor([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
In[208]: torch.arange(0,10,2)
Out[208]: tensor([0, 2, 4, 6, 8])
In[209]: torch.range(0,10)
G:\PyCharm 2019.1.3\helpers\pydev\pydevconsole.py:1: UserWarning: torch.range is deprecated in favor of torch.arange and will be removed in 0.5. Note that arange generates values in [start; end), not [start; end].
  '''
Out[209]: tensor([ 0.,  1.,  2.,  3.,  4.,  5.,  6.,  7.,  8.,  9., 10.])
```



# linspace/logspace

- 等分 `linspace()`   [0,10] , steps=4
- `logspace()` 也是等分，不过是以10^x 来得到输出的。

```python
In[210]: torch.linspace(0,10, steps=4)
Out[210]: tensor([ 0.0000,  3.3333,  6.6667, 10.0000])

# 将11个数 切成10个
In[211]: torch.linspace(0,10, steps=10)
Out[211]: 
tensor([ 0.0000,  1.1111,  2.2222,  3.3333,  4.4444,  5.5556,  6.6667,  7.7778,
         8.8889, 10.0000])
In[212]: torch.linspace(0,10, steps=11)
Out[212]: tensor([ 0.,  1.,  2.,  3.,  4.,  5.,  6.,  7.,  8.,  9., 10.])
    
# 将 0->-1 切成10份，然后乘10
In[213]: torch.logspace(0,-1,steps=10)
Out[213]: 
tensor([1.0000, 0.7743, 0.5995, 0.4642, 0.3594, 0.2783, 0.2154, 0.1668, 0.1292,
        0.1000])
In[214]: torch.logspace(0,1,steps=10)
Out[214]: 
tensor([ 1.0000,  1.2915,  1.6681,  2.1544,  2.7826,  3.5938,  4.6416,  5.9948,
         7.7426, 10.0000])
```



# ones/zeros/eye

- ones()  生成全部为1的
- zeros()  生成全部为0的
- eye()  生成单位向量



```python
In[215]: torch.ones(3,3)
Out[215]: 
tensor([[1., 1., 1.],
        [1., 1., 1.],
        [1., 1., 1.]])
In[216]: torch.zeros(3,3)
Out[216]: 
tensor([[0., 0., 0.],
        [0., 0., 0.],
        [0., 0., 0.]])
In[219]: torch.eye(3,4)
Out[219]: 
tensor([[1., 0., 0., 0.],
        [0., 1., 0., 0.],
        [0., 0., 1., 0.]])

In[220]: torch.eye(3)
Out[220]: 
tensor([[1., 0., 0.],
        [0., 1., 0.],
        [0., 0., 1.]])
In[221]: a = torch.zeros(3,3)
In[222]: torch.ones_like(a)
Out[222]: 
tensor([[1., 1., 1.],
        [1., 1., 1.],
        [1., 1., 1.]])
```



# randperm

- 随机打散 (numpy中是 random.shuffle)
- randperm()

```python
In[223]: torch.randperm(10)
Out[223]: tensor([8, 1, 0, 4, 9, 3, 7, 6, 2, 5])
In[224]: a = torch.rand(2,3)
In[225]: b = torch.rand(2,2)
In[226]: idx = torch.randperm(2)
In[227]: idx
Out[227]: tensor([1, 0])
    # [1,0] 相反；[0,1]维持不变
    
# 需要用同一个索引/维度来shuffle，协同shuffle，保持配对
In[232]: a[idx]
Out[232]: 
tensor([[0.8259, 0.7368, 0.3033],
        [0.2103, 0.2943, 0.0866]])
In[233]: b[idx]
Out[233]: 
tensor([[0.4822, 0.2033],
        [0.3809, 0.8047]])
In[234]: a,b
Out[234]: 
(tensor([[0.2103, 0.2943, 0.0866],
         [0.8259, 0.7368, 0.3033]]), tensor([[0.3809, 0.8047],
         [0.4822, 0.2033]]))
```


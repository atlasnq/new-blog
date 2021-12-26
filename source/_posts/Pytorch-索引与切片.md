---
title: Pytorch-索引与切片
copyright: true
date: 2019-06-25 9:54:34
tags: [Pytorch,Deep Learning,学习笔记]
categories: Pytorch学习笔记
comments: true
urlname: learning_PyTorch_3_index_slice
---



{% cq %}本篇介绍Pytorch 的索引与切片。 {% endcq %}

<!--more-->



# 索引

```python
In[3]: a = torch.rand(4,3,28,28)
In[4]: a[0].shape       # 理解上相当于取第一张图片
Out[4]: torch.Size([3, 28, 28])
In[5]: a[0,0].shape     # 第0张图片的第0个通道
Out[5]: torch.Size([28, 28])
In[6]: a[0,0,2,4]		# 第0张图片第0个通道的第2行第4列的像素点 标量 
Out[6]: tensor(0.4133)  # 没有用 [] 包起来就是一个标量 dim为0
```

# 切片

- 顾头不顾尾

```python
In[7]: a.shape
Out[7]: torch.Size([4, 3, 28, 28])
In[8]: a[:2].shape			# 前面两张图片的所有数据
Out[8]: torch.Size([2, 3, 28, 28])
In[9]: a[:2,:1,:,:].shape      # 前面两张图片的第0通道的数据  
Out[9]: torch.Size([2, 1, 28, 28])
In[11]: a[:2,1:,:,:].shape		# 前面两张图片，第1，2通道的数据
Out[11]: torch.Size([2, 2, 28, 28])
In[10]: a[:2,-1:,:,:].shape		# 前面两张图片，最后一个通道的数据  从-1到最末尾，就是它本身。
Out[10]: torch.Size([2, 1, 28, 28])
```

# 步长

- 顾头不顾尾 + 步长
- `start : end : step`
- 对于步长为1的，通常就省略了。

```python
a[:,:,0:28,0:28:2].shape    # 隔点采样
Out[12]: torch.Size([4, 3, 28, 14])
a[:,:,::2,::2].shape
Out[14]: torch.Size([4, 3, 14, 14])
```



# 具体的索引

- `.index_select(dim, indices)`
  - dim为维度，indices是索引序号
  - 这里的indeces必须是tensor ，不能直接是一个list



```python
In[17]: a.shape
Out[17]: torch.Size([4, 3, 28, 28])
In[19]: a.index_select(0, torch.tensor([0,2])).shape	# 当前维度为0，取第0，2张图片
Out[19]: torch.Size([2, 3, 28, 28])
In[20]: a.index_select(1, torch.tensor([1,2])).shape   	# 当前维度为1，取第1，2个通道
Out[20]: torch.Size([4, 2, 28, 28])
In[21]: a.index_select(2,torch.arange(28)).shape		# 第二个参数，只是告诉你取28行
Out[21]: torch.Size([4, 3, 28, 28])
In[22]: a.index_select(2, torch.arange(8)).shape		# 取8行  [0,8)
Out[22]: torch.Size([4, 3, 8, 28])    
```



# `...`

- `...` 表示任意多维度，根据实际的shape来推断。
- 当有 `...` 出现时，右边的索引理解为最右边
- 为什么会有它，没有它的话，存在这样一种情况 a[0,: ,: ,: ,: ,: ,: ,: ,: ,: ,2]  只对最后一个维度做了限度，这个向量的维度又很高，以前的方式就不太方便了。

```python
In[23]: a.shape
Out[23]: torch.Size([4, 3, 28, 28])
In[24]: a[...].shape		# 所有维度
Out[24]: torch.Size([4, 3, 28, 28])
In[25]: a[0,...].shape		# 后面都有，取第0个图片 = a[0]
Out[25]: torch.Size([3, 28, 28])
In[26]: a[:,1,...].shape
Out[26]: torch.Size([4, 28, 28])
In[27]: a[...,:2].shape		# 当有...出现时，右边的索引理解为最右边，只取两列
Out[27]: torch.Size([4, 3, 28, 2]) 	
```



# 使用mask来索引

- `.masked_select()`
- 求掩码位置原来的元素大小
- 缺点：会把数据，默认打平（flatten），

```python
In[31]: x = torch.randn(3,4)
In[32]: x
Out[32]: 
tensor([[ 2.0373,  0.1586,  0.1093, -0.6493],
        [ 0.0466,  0.0562, -0.7088, -0.9499],
        [-1.2606,  0.6300, -1.6374, -1.6495]])
In[33]: mask = x.ge(0.5)          # >= 0.5 的元素的位置上为1，其余地方为0
In[34]: mask
Out[34]: 
tensor([[1, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 1, 0, 0]], dtype=torch.uint8)
In[35]: torch.masked_select(x,mask)
Out[35]: tensor([2.0373, 0.6300])	# 之所以打平是因为大于0.5的元素个数是根据内容才能确定的
In[36]: torch.masked_select(x,mask).shape
Out[36]: torch.Size([2])
```



# 使用打平（flatten）后的序列

- torch.take(src, torch.tensor([index]))
- 打平后，按照index来取对应位置的元素

```python
In[39]: src = torch.tensor([[4,3,5],[6,7,8]])		# 先打平成1维的，共6列
In[40]: src
Out[40]: 
tensor([[4, 3, 5],
        [6, 7, 8]])
In[41]: torch.take(src, torch.tensor([0, 2, 5]))	# 取打平后编码，位置为0 2 5
Out[41]: tensor([4, 5, 8])
```


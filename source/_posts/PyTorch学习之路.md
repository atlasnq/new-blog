---
title: PyTorch学习之路
date: 2019-06-20 21:01:34
tags: [Pytorch,Deep Learning,学习笔记]
categories: Pytorch学习笔记
comments: true
urlname: learning-PyTorch
copyright: true
---



{% cq %}将PyTorch的学习过程记录下来。 {% endcq %}

<!--more-->



# 什么是PyTorch



## 入门

### 张量与操作

```python
import torch
# 张量
# =============================================================================
x = torch.Tensor(5,3)
print(x)
 #print(x.size(),type(x.size()))
 
# 操作
y = torch.rand(5,3)
# # =============================================================================
  # 法1
print(x + y)
  # 法2
print(torch.add(x,y))
  
  # 定义一个输出张量
result = torch.Tensor(5,3)
torch.add(x,y, out = result)
print(result)
  # in-place追加
y.add_(x)
print(y)
# # =============================================================================
print(y)
 #x.copy_(y)
 #print(x)
x.t_()
print(x)
print(x[:,1])
# =============================================================================
```

注意：torch包中带有下划线的op说明是就地进行的

## Nmupy转换

### 将Torch张量转化为numpy数组

```python
import torch
# =============================================================================
  # Nmupy 转换
a = torch.ones(5)
print(a)
b = a.numpy()
print(b)
 # 当给tensor a列表的每个值加一， numpys列表中的每个值加一
a.add_(1)
print(a)
print(b) 
```



### 将numpy数组转化为Torch张量

```python
import torch
# =============================================================================
# 将numpy数组转换成Torch张量
import numpy as np
a = np.ones(5)
b = torch.from_numpy(a)
np.add(a, 1, out=a)
print(a)
print(b)
a[0] = 333
print(a)
print(b)
## 结论和上面一样，无论是从tensor转换成numpy 还是反过来，都是一个内容修改，另一个也会变
 
# =============================================================================
```



## CUDA传感器

cuda传感器是一个基于Python的科学计算包，主要分入如下2部分：

- 使用GPU的功能代替numpy
- 一个深刻的学习研究平台，提供最大的灵活性和速度

```python
# CUDA传感器
import torch
x = torch.Tensor(5,3)
y = torch.rand(5,3)
if torch.cuda.is_available():  # 判断cuda是否可用
  x = x.cuda()
  print(x)
  y = y.cuda()
  x + y
```



# Autograd：自动分化

autograd包是`PyTorch`所有神经网络的核心。

`autograd`包为`Tensors`上的所有操作提供了自动区分。它是一个逐个运行的框架，这意味着您的`backprop`由您的代码运行定义，每一次迭代都可以不同。



## 变量

`autograd.Variable`是包的**中央类**。它包含一个`Tensor`，并支持几乎所有定义的操作。完成计算后，可以调用`.backward()`并自动计算所有梯度。



变量与变量是有创造关系的，你可以对这些关系组成的函数求导。

创造一个变量：

```python
import torch
from torch.autograd import Variable
x = Variable(torch.ones(2,2),requires_grad= True)
print(x)
```

<u>输出</u>：

```python
tensor([[1., 1.],
        [1., 1.]], requires_grad=True)
```

做一个变量的操作：

```python
y = x + 2
print(y)
```

<u>输出</u>：

```python
tensor([[3., 3.],
        [3., 3.]], grad_fn=<AddBackward0>)
```

`y` 是由于操作造成的，所以它有一个创造者。

```python
print(y.creator)  # 报错，已替换为grad_fn
print(y.grad_fn)
```

<u>输出</u>:

```python
<AddBackward0 object at 0x00000226055E8940>
```

对y进行更多的操作

```python
z = y * y * 3
out = z.mean()
print(z,out)
```

<u>输出:</u>

```python
tensor([[27., 27.],
        [27., 27.]], grad_fn=<MulBackward0>) tensor(27., grad_fn=<MeanBackward0>)
```

**梯度**

```python
out.backward()
```

打印梯度 d(out)/dx

```python
print(x.grad)
```

<u>输出:</u>

```python
tensor([[4.5000, 4.5000],
        [4.5000, 4.5000]])
```



自动求导可以做很多疯狂的事情

```python
x = torch.rand(3)
x = Variable(x, requires_grad= True)
y = x * 2
while y.data.norm()< 1000:
    y = y * 2
    
print(y)
```

解释：

`y.data.norm()`是用来求y的二范数

y的二范数小于1000的约束条件下，y的公式其实是 `y = 1024*x`



<u>输出：</u>

```python
tensor([591.5636, 884.0807, 773.9807], grad_fn=<MulBackward0>)
```

```python
gradients = torch.FloatTensor([0.1, 1.0, 0.0001])
y.backward(gradients)
print(x.grad)
```

<u>输出：</u>

```python
 tensor([1.0240e+02, 1.0240e+03, 1.0240e-01])
```



# LeNet：

![LeNet](PyTorch学习之路/LeNet.png)



## 显示CIFAR数据集图片

```python
import torchvision
import torchvision.transforms as transforms
import torch


transform = transforms.Compose([transforms.ToTensor(),      # 转为tensor
                                transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))  # 归一化
                                ])
trainset = torchvision.datasets.CIFAR10(root="./data", train=True, download=True, transform=transform)
print(len(trainset))
trainloader = torch.utils.data.DataLoader(trainset, batch_size=4,
                                          shuffle=True, num_workers=2)

testset = torchvision.datasets.CIFAR10(root='./data', train=False, download=True, transform=transform)
testloader = torch.utils.data.DataLoader(testset, batch_size=4,
                                          shuffle=False, num_workers=2)
classes = ('plane', 'car', 'bird', 'cat',
           'deer', 'dog', 'frog', 'horse', 'ship', 'truck')
# img, target = trainset[0]
# print(img)

import matplotlib.pyplot as plt
import numpy as np
def imshow(img):
    img =img / 2 + 0.5  # unnormalize
    npimg = img.numpy()
    plt.imshow(np.transpose(npimg, (1,2,0)))
    plt.show()

if __name__ == '__main__':           # 开启多进程
    dataiter = iter(trainloader)
    images, labels = dataiter.next()
    imshow(torchvision.utils.make_grid(images))
    print(' '.join('%5s'%classes[labels[j]] for j in range(4)))
```



## 定义网络

等先把基础写完再继续补充😄



未完待续！！！

----


---
title: Pytorch-常见函数的梯度
copyright: true
date: 2019-07-05 00:12:47
tags: [Pytorch,Deep Learning,学习笔记]
categories: Pytorch学习笔记
comments: true
urlname: learning_PyTorch_10_gradient
---



{% cq %} 本篇介绍Pytorch中常见函数的梯度。  {% endcq %}

<!--more-->



## 线性模型


$$
y=xw+b
$$

- x：参数，理解为神经网络的输入。

- w与b：神经网络的参数（两个自变量），作为优化的目标。

偏微分为：
$$
\frac{\partial y}{\partial w} = x
\quad , \quad
\frac{\partial y}{\partial b} = 1
\quad , \quad
\nabla_{(w,b)} = (x , 1)
$$
ps：这也是感知机的模型。



例如：
$$
f=[y-(xw+b)]^2
$$


偏微分：
$$
\frac{\partial f}{\partial w} = 2(y-(xw+b))*(-x)
\quad , \quad
\frac{\partial y}{\partial b} = 2(y-(xw+b))-1
$$

$$
\nabla_{(w,b)} = (2(y-(xw+b))*(-x), 2(y-(xw+b))-1)
$$



线性感知机的输出和真实label之间的均方差(loss)的导数

有了梯度公式后，对于一个点就能代入更新了。
$$
(w_0,b_0) \rightarrow (\nabla w_0, \nabla b_0)
$$




## 二次模型

$$
y=xw^2+b^2
$$

偏微分为：
$$
\frac{\partial y}{\partial w} = 2xw
\quad , \quad
\frac{\partial y}{\partial b} = 2b
\quad , \quad
\nabla_{(w,b)} = (2xw, 2b)
$$


## 指数模型

$$
y=xe^w+e^b
$$

偏微分为：
$$
\frac{\partial y}{\partial w} = xe^w
\quad , \quad
\frac{\partial y}{\partial b} = e^b
\quad , \quad
\nabla_{(w,b)} = (xe^w, e^b)
$$


## 对数模型


$$
f = y \log (xw+b)
$$
偏微分为：
$$
\frac{\partial f}{\partial w} = y \frac{x}{xw + b}
\quad , \quad
\frac{\partial f}{\partial b} = y \frac{1}{xw + b}
\quad , \quad
\nabla_{(w,b)} = (y \frac{x}{xw + b}, y \frac{1}{xw + b})
$$

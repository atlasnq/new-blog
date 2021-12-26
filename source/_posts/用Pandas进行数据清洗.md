---
title: 用Pandas进行数据清洗
copyright: true
date: 2019-10-19 13:25:17
tags: [Pandas,数据分析,python,学习笔记]
categories: Pandas
comments: true
urlname:  learning_Pandas_2
---



{% cq %}数据分析三剑客之Pandas。 {% endcq %}

<!--more-->



# 数据清理

## 检测过滤缺失值

两种丢失数据：

- None
- np.nan(NaN)



### None

None是Python自带的，其类型为python object。因此，None不能参与到任何计算中。

```python
import numpy as np
import pandas
from pandas import DataFrame
# 查看None的数据类型
type(None)
```



### np.nan（NaN）

np.nan是浮点类型，能参与到计算中。但计算的结果总是NaN。

```python
# 查看np.nan的数据类型
type(np.nan)
```



### pandas中的None与NaN



### pandas中None与np.nan都视作np.nan

创建DataFrame

```python
df = DataFrame(data=np.random.randint(0,100,size=(10,8)))
df
```

```python
#将某些数组元素赋值为nan
df.iloc[1,4] = None
df.iloc[3,6] = None
df.iloc[7,7] = None
df.iloc[3,1] = None
df.iloc[5,5] = np.nan
df
```

### pandas处理空值操作

判断函数

- `isnull()`
- `notnull()`

```python
df.isnull()
df.notnull()
df.isnull().any(axis=1)
df.notnull().all(axis=1)
df.loc[~df.isnull().any(axis=1)]
```

df.dropna() 可以选择过滤的是行还是列（默认为行）:axis中0表示行，1表示的列

```
df.dropna(axis=0)
```

填充函数 Series/DataFrame

- `fillna()`:value和method参数



```python
df_test = df.fillna(method='bfill',axis=1).fillna(method='ffill',axis=1)
df_test
```



```python
#测试df_test中的哪些列中还有空值
df_test.isnull().any(axis=0)
```



## 检测过滤重复值

使用`duplicated()`函数检测重复的行，返回元素为布尔类型的Series对象，每个元素对应一行，如果该行不是第一次出现，则元素为True

- keep参数：指定保留哪一重复的行数据
- 创建具有重复元素行的DataFrame



```python
import numpy as np
import pandas as pd
from pandas import DataFrame

# 创建一个df
df = DataFrame(data=np.random.randint(0,100,size=(12,7)))
# 手动将df的某几行设置成相同的内容
df.iloc[1] = [6,6,6,6,6,6,6]
df.iloc[8] = [6,6,6,6,6,6,6]
df.iloc[5] = [6,6,6,6,6,6,6]
```

- 使用drop_duplicates()函数删除重复的行
  - drop_duplicates(keep='first/last'/False)

```python
df.drop_duplicates()   # 默认first
df.drop_duplicates(keep='last')
df.drop_duplicates(keep=False)
```



## 检测过滤异常值

- 得到鉴定异常值的条件
- 使用聚合操作对数据异常检测并过滤



# 总结

- 检测过滤**缺失值**
  - dropna
  - fillna
- 检测过滤**重复值**
  - drop_duplicated(keep)
- 检测过滤**异常值**
  - 得到鉴定异常值的条件
  - 将异常值对应的行删除






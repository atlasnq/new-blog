---
title: unittest测试框架学习
copyright: true
date: 2020-08-03 16:51:47
tags: [Python, 单元测试,学习笔记]
categories: 单元测试
comments: true
urlname:  Learn-unittest-1
---



{% cq %} 本文介绍Unittest的概念以及基本使用方法 {% endcq %}

<!--more-->



> unittest是python自带的单元测试框架，有时候又被称为”PyUnit”，是 python版本的JUint实现。该框架的作者是 Kent Beck和Erich Gamma。



1. 测试脚手架（test fixture）
   - 负责准备工作，以及所有相关的清理操作。举个例子，这可能包含创建临时或代理的数据库、目录，再或者启动一个服务器进程。（撑起运行环境）
2. 测试用例（test case）
   - 一个测试用例是一个独立的测试单元。它检查输入特定的数据时的响应。 [`unittest`](https://docs.python.org/zh-cn/3.7/library/unittest.html#module-unittest) 提供一个基类： [`TestCase`](https://docs.python.org/zh-cn/3.7/library/unittest.html#unittest.TestCase) ，用于新建测试用例。
3. 测试套件（test suite）
   - *test suite* 是一系列的测试用例，或测试套件，或两者皆有。它用于归档需要一起执行的测试。
4. 测试运行器（test runner）
   - *test runner* 是一个用于执行和输出测试结果的组件。这个运行器可能使用<u>图形接口、文本接口，或返回一个特定的值</u>表示运行测试的结果。



## 简单的例子

```python
import unittest


class TestStringMethods(unittest.TestCase):
    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_isupper(self):
        self.assertTrue('FOO'.isupper())
        self.assertFalse('Foo'.isupper())

    def test_split(self):
        s = 'hello world'
        self.assertEqual(s.split(), ['hello', 'world'])
        with self.assertRaises(TypeError):
            s.split(2)


if __name__ == '__main__':
    # main() 方法
    unittest.main()
```



推荐使用命令行运行：

简略模式：

```
python -m unittest test.py
```

更详细的信息：

```
python -m unittest -v test.py
```

探索性测试（运行时不含参数）

```
python -m unittest
```

```
python -m unittest -v
```



其它参数选项：

```
-f   当出现第一个错误或者失败时，停止运行测试。

```



## 构建自己的测试代码

​		单元测试的构建单位是 *test cases* ：独立的、包含执行条件与正确性检查的方案。在 [`unittest`](https://docs.python.org/zh-cn/3.7/library/unittest.html#module-unittest) 中，测试用例表示为 [`unittest.TestCase`](https://docs.python.org/zh-cn/3.7/library/unittest.html#unittest.TestCase) 的实例。通过编写 [`TestCase`](https://docs.python.org/zh-cn/3.7/library/unittest.html#unittest.TestCase) 的子类或使用 [`FunctionTestCase`](https://docs.python.org/zh-cn/3.7/library/unittest.html#unittest.FunctionTestCase) 编写你自己的测试用例。

​		一个 [`TestCase`](https://docs.python.org/zh-cn/3.7/library/unittest.html#unittest.TestCase) 实例的测试代码必须是完全自含的，因此它可以独立运行，或与其它任意组合任意数量的测试用例一起运行。

```python
class TestAdd(unittest.TestCase):
    def setUp(self) -> None:
        '''
        用于测试用例执行前的初始化工作
        '''
        print('test start')
        self.count = Count(2, 3)

    def test_add(self):

        self.assertEqual(self.count.add(), 5, '计算错误！')

    def tearDown(self) -> None:
        '''
        用于测试用例之后的工作
        '''
        print('test end')
```

注意：

- 多个测试运行的顺序由内置字符串排序方法对测试名进行排序的结果决定。
- 若 [`setUp()`](https://docs.python.org/zh-cn/3.7/library/unittest.html#unittest.TestCase.setUp) 成功运行，无论测试方法是否成功，都会运行 [`tearDown()`](https://docs.python.org/zh-cn/3.7/library/unittest.html#unittest.TestCase.tearDown) 。



## 跳过测试与预计的失败

```
@unittest.skip(reason)
	跳过被此装饰器装饰的测试。 reason 为测试被跳过的原因。
@unittest.skipIf(condition, reason)
	当 condition 为真时，跳过被装饰的测试。
@unittest.skipUnless(condition, reason)
	跳过被装饰的测试，除非 condition 为真。
@unittest.expectedFailure
	把测试标记为预计失败。如果测试不通过，会被认为测试成功；如果测试通过了，则被认为是测试失败。
```


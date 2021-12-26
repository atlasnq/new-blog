---
title: Mock模块
copyright: true
date: 2020-08-03 19:16:03
tags: [Python, 单元测试,学习笔记]
categories: 单元测试
comments: true
urlname:  Learn-mock-1
---



{% cq %} 本文介绍Mock模块的概念以及基本使用方法 {% endcq %}

<!--more-->

​	

## 模拟函数

```python
def zhifu():
    '''假设这里是一个支付的功能,未开发完
    支付成功返回：{"result": "success", "reason":"null"}
    支付失败返回：{"result": "fail", "reason":"余额不足"}
    reason返回失败原因
    '''
    pass

def zhifu_statues():
    '''根据支付的结果success or fail，判断跳转到对应页面'''
    result = zhifu()
    print(result)
    try:
        if result["result"] == "success":
            return "支付成功"
        elif result["result"] == "fail":
            print("失败原因：%s" % result["reason"])
            return "支付失败"
        else:
            return "未知错误异常"
    except:
        return "Error, 服务端返回异常!"
```



测试用例：

```python
import temple
import unittest
from unittest import mock


class Test_zhifu_status(unittest.TestCase):
    # 单元测试用例

    @mock.patch('temple.zhifu')
    def test_suc(self, mock_zhifu):
        '''测试支付成功场景'''
        # 方式一：mock一个支付成功的数据
        # temple.zhifu = mock.Mock(return_value={'result': "success", "reason": "null"})

        # 方式二：mock.path装饰器模拟返回结果
        mock_zhifu.return_value = {'result': "success", "reason": "null"}
        # 根据支付结果测试页面跳转
        status = temple.zhifu_statues()
        print(status)
        self.assertEqual(status, "支付成功")

    @mock.patch('temple.zhifu')
    def test_fail(self, mock_zhifu):
        '''测试支付失败场景'''
        # mock一个支付成功的数据
        mock_zhifu.return_value = {"result": 'fail', "reason": "余额不足"}
        # 根据支付结果测试页面跳转
        status = temple.zhifu_statues()
        self.assertEqual(status, "支付失败")


if __name__ == '__main__':
    unittest.main()
```



## 模拟类的方法

```python
class Zhifu:
    def zhifu(self):
        '''假设这里是一个支付的功能,未开发完
        支付成功返回：{"result": "success", "reason":"null"}
        支付失败返回：{"result": "fail", "reason":"余额不足"}
        reason返回失败原因
        '''
        pass

class Status:
    def zhifu_statues(self):
        '''根据支付的结果success or fail，判断跳转到对应页面'''
        result = Zhifu().zhifu()
        print(result)
        try:
            if result["result"] == "success":
                return "支付成功"
            elif result["result"] == "fail":
                print("失败原因：%s" % result["reason"])
                return "支付失败"
            else:
                return "未知错误异常"
        except:
            return "Error, 服务端返回异常!"
```



测试用例：

```python
import temple
import unittest
from unittest import mock


class Test_zhifu_status(unittest.TestCase):
    # 单元测试用例

    @mock.patch('temple_class.Zhifu')
    def test_suc(self, mock_Zhifu):
        '''测试支付成功场景'''

        # 方式二：mock.path装饰器模拟返回结果
        a = mock_Zhifu.return_value  # 先返回实例，对类名称替换
        a.zhifu.return_value = {'result': "success", "reason": "null"}
        # 根据支付结果测试页面跳转
        status = temple.zhifu_statues()
        print(status)
        self.assertEqual(status, "支付成功")

    @mock.patch('temple.zhifu')
    def test_fail(self, mock_zhifu):
        '''测试支付失败场景'''
        # mock一个支付成功的数据
        mock_zhifu.return_value = {"result": 'fail', "reason": "余额不足"}
        # 根据支付结果测试页面跳转
        status = temple.zhifu_statues()
        self.assertEqual(status, "支付失败")


if __name__ == '__main__':
    unittest.main()
```

小结：函数与方法做个比较即可得出，多出一步 先返回实例的过程 `a = mock_Zhifu.return_value`


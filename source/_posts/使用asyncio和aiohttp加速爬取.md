---
title: 使用asyncio和aiohttp加速爬取
copyright: true
date: 2019-09-24 20:58:55
tags: [网络爬虫,python,并发编程,学习笔记]
categories: 网络爬虫
comments: true
urlname:  Web_Spider_5
---



{% cq %}上一篇中介绍了基于asyncio模块的单线程-多任务的异步协程，本篇与aiohttp（支持异步网络请求模块）配合来加速爬取。 {% endcq %}

<!--more-->



## aiohttp

概念：支持异步的网络请求模块

- 它是基于asyncio实现的

编写流程：

- 写基本架构：

```python
with aiohttp.ClientSession() as s:
    # s.get(url)  # 这里的参数和requests中的get/post 的参数大部分相同，只有proxy = 'http://ip"port"'需要注意
    with await s.get(url) as response:
        page_text = await response.text()     # text 返回的是字符串形式的响应数据，read() 返回的是二进制的响应数据
        return page_text

# note：aiohttp需要我们手动关闭，所以使用with进行上下文管理。
```

- 补充细节：

  - 添加 async 关键字
    - 每一个`with`前 加 async。

  - 添加await关键字
    - 加到每一步的阻塞操前
      - 请求
      - 获取响应数据



## 例子

本例中先在本地搭一个flask服务器，然后对它进行爬取。



首先是flask代码：

```python
# server.py
from flask import Flask,render_template
from time import sleep
app = Flask(__name__)

@app.route('/ip1')
def index_1():
    sleep(2)
    return render_template('ip.html')	# 这个html 随便，有就行。

@app.route('/ip2')
def index_2():
    sleep(2)
    return render_template('ip.html')


app.run(debug=True)  # 有改动就会自动重启
```



接下来写我们的爬虫代码吧：

```python
import asyncio
import requests
from lxml import etree
import time
import aiohttp


# 尝试reuqests
# async def get_request(url):
#     # requests是一个不支持异步的模块
#     page_text = requests.get(url).text
#     return page_text

# 协程函数：发起请求获取页面源码数据
async def get_request(url):
    # aiohttp.ClientSession()  # 定义请求对象，且在用完之后需要使用手动关闭close,使用with做上下文管理
    async with aiohttp.ClientSession() as s:
        # s.get(url)  # 这里的参数和requests中的get/post 的参数大部分相同，只有proxy = 'http://ip"port"'需要注意
        async with await s.get(url) as response:
            page_text = await response.text()     # text 返回的是字符串形式的响应数据，read() 返回的是二进制的响应数据
            return page_text

def parse(task):
    page_text = task.result()
    tree = etree.HTML(page_text)    # 这里使用etree 影响异步吗？不需要，直接执行完就行
    print(tree.xpath('//*[@id="3"]/div/div[2]/p[1]'))


urls = [
    'http://127.0.0.1:5000/ip1',
    'http://127.0.0.1:5000/ip2',
    'http://127.0.0.1:5000/ip1',
    'http://127.0.0.1:5000/ip2',
    'http://127.0.0.1:5000/ip1',
    'http://127.0.0.1:5000/ip2',
]
start = time.time()
# py3.6
# tasks = []  # 任务列表
# for url in urls:
#     # 创建协程对象
#     c = get_request(url)
#     # 创建任务对象
#     task = asyncio.ensure_future(c)
#     # 绑定回调：用作数据解析
#     task.add_done_callback(parse)
#     tasks.append(task)
#
# # 创建事件循环对象
# loop = asyncio.get_event_loop()
# # 注册任务并开启事件循环
# loop.run_until_complete(asyncio.wait(tasks))
#
# print('总耗时：', time.time() - start)

# py3.7

# 定义 asyncio 程序的主入口
async def main():
    tasks = []  # 任务列表
    for url in urls:
        # 创建协程对象
        c = get_request(url)
        # 创建任务对象
        task = asyncio.ensure_future(c)
        # 绑定回调：用作数据解析
        task.add_done_callback(parse)
        tasks.append(task)
    await asyncio.gather(*tasks)


asyncio.run(main())
print('总耗时：', time.time() - start)
```



## 实战



待补充！！！
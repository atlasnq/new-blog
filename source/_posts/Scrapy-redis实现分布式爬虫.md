---
title: Scrapy+redis实现分布式爬虫
copyright: true
date: 2019-10-02 20:32:18
tags: [网络爬虫,python,scrapy,学习笔记]
categories: 网络爬虫
comments: true
urlname:  Web_Spider_9
---



{% cq %}Scrapy + Scrapy-Redis 组件实现的分布式。 {% endcq %}

<!--more-->



# 概述

## 什么是分布式爬虫

- 需要搭建一个由n台电脑组成的机群，然后在每一台电脑中执行同一组程序，让其对同一网络资源进行联合且分布的数据爬取。



## 原生Scrapy无法实现分布式的原因

1. 原生Scrapy中**调度器**不可以被共享
   - 每一台机器都拥有一个调度器，如果一个机群共享一个调度器就可以了。
2. 原生Scrapy中**管道**不可以被共享
   - 每一台机器都拥有自己的管道，如果把Item发送到同一个管道就可以了。



## Scrapy_redis组件的作用是什么？

- 提供可以被共享的管道和调度器



## 分布式的实现流程

**实现分布式的重点在于配置**

- 环境的安装 

  - `pip install scrapy-redis`

- 创建工程

  - 基于Spider：  `scrapy genspider crawl spiderName`       
  - 基于CrawlSpider： `scrapy genspider -t crawl spiderName`       

- cd 工程

- 创建爬虫文件

  - 基于Spider
  - 基于CrawlSpider

- 修改爬虫文件：

  - 导包：
    - `from scrapy_redis.spiders import RedisCrawlSpider`   基于 CrawlSpider 爬虫文件
    - `from scrapy_redis.spiders import RedisSpider` 基于Spider爬虫文件
  - 将父类修改为 RedisCrawlSpider 或  RedisSpider 
  - 删除 allowed_domains 和 start_urls
  - 添加 redis_key = '队列名称'  ：可被共享的调度器队列的名称，向这个队列中放入起始url
  - 根据常规形式编写爬虫文件后续的代码

- 修改settings配置

  - 指定管道

    ```python
    ITEM_PIPELINES = {
        'scrapy_redis.pipelines.RedisPipeline': 400
    }
    ```

    

  - 指定调度器

    ```python
    # 增加了一个去重容器类的配置, 作用使用Redis的set集合来存储请求的指纹数据, 从而实现请求去重的持久化
    DUPEFILTER_CLASS = "scrapy_redis.dupefilter.RFPDupeFilter"
    # 使用scrapy-redis组件自己的调度器
    SCHEDULER = "scrapy_redis.scheduler.Scheduler"
    # 配置调度器是否要持久化, 也就是当爬虫结束了, 要不要清空Redis中请求队列和去重指纹的set。如果是True, 就表示要持久化存储, 就不清空数据, 否则清空数据
    SCHEDULER_PERSIST = True
    ```

    

  - 指定redis数据库

    ```python
    REDIS_HOST = '192.168.13.254'
    REDIS_PORT = 6379
    ```

    

- 修改redis的配置文件

  - 关闭默认绑定
    - 56行  注释 bind 127.0.0.1
  - 关闭保护模式
    - 75行  protected-mode no
    - 这样就可以写数据了

  

- 启动redis的服务端（携带配置文件）和客户端

  - `redis-server.exe redis.windows.conf`

- 启动分布式的程序：

  - 启动之后才会有调度器对象和队列
  - scrapy runspider xxx.py
  - 启动后在等起始url

- 向调度器的队列中扔入一个起始的url

  - 队列是存在于redis中
  - redis的客户端中：lpush  sun  www.xxx.com

- 在redis中就可以查看爬取到的数据



# 例子

使用Scrapy + Scrapy-redis 组件实现的分布式爬取（阳光热线问政平台的投诉帖子）的主题、状态和详细内容

地址为：`http://wz.sun0769.com/html/top/reply.shtml`



## ①

 `scrapy startproject fbsPro`  创建基于fbsPro的工程       

 `scrapy genspider -t crawl fbs 域名`  创建名为fbs的spider文件   

```python 
# fbs.py
# -*- coding: utf-8 -*-
import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule

from scrapy_redis.spiders import RedisCrawlSpider
# from scrapy_redis.spiders import RedisSpider
from fbsPro.items import Item1, Item2

class FbsSpider(RedisCrawlSpider):
    name = 'fbs'
    # allowed_domains = ['www.xxx.com']
    # start_urls = ['http://www.xxx.com/']
    redis_key = 'fbs'       # 可被共享的调度器队列的名称，向这个队列中放入起始url

    start_urls = ['http://wz.sun0769.com/html/top/reply.shtml']
    # 链接提取器（如：获得每一个页码）
    link = LinkExtractor(allow=r'page=\d+')  # 空的话取所有url
    link_1 = LinkExtractor(allow=r'page=$')  # 拿到第一页数据
    link_detail = LinkExtractor(allow=r'question/\d+/\d+\.shtml')  # 拿到第一页数据 . 需要转义

    rules = (
        # 实例化一个Rule（规则解析器）对象
        Rule(link, callback='parse_item', follow=False),
        Rule(link_1, callback='parse_item'),
        Rule(link_detail, callback='parse_detail'),
        # follow = True; 将链接提取器 继续作用到 连接提取器提取到的链接 所对应的 页码源码中
    )

    # 数据解析: 用来解析连接提取器提取到的链接所对应的页码
    def parse_item(self, response):
        # tr_list = response.xpath('/html/body/div[8]/table[2]/tbody/tr')   # xpath中不能含有tbody
        tr_list = response.xpath('/html/body/div[8]/table[2]//tr')

        for tr in tr_list:
            title = tr.xpath('./td[3]/a[1]/text()').extract_first()
            status = tr.xpath('./td[4]/span/text()').extract_first()
            num = tr.xpath('./td[1]/text()').extract_first()
            # print(num, title,status)
            item = Item2()
            item['title'] = title
            item['status'] = status
            item['num'] = num
            yield item
        # print(response)

    # 解析详情页中的新闻内容
    def parse_detail(self, response):
        content = response.xpath('/html/body/div[9]/table[2]//tr[1]/td//text()').extract()
        if content:
            content = ''.join(content)
            num = response.xpath('/html/body/div[9]/table[1]//tr/td[2]/span[2]').extract_first().split(':')[-1].replace(
                r'</span>', '')
            # print(num, content)
            item = Item1()
            item['content'] = content
            item['num'] = num
            yield item
```

## ②

定义Item

```python
# items.py
import scrapy

class Item1(scrapy.Item):
    # define the fields for your item here like:
    content = scrapy.Field()
    num = scrapy.Field()

class Item2(scrapy.Item):
    # define the fields for your item here like:
    title = scrapy.Field()
    status = scrapy.Field()
    num = scrapy.Field()
```



## ③

配置settings.py

```python
#指定管道
ITEM_PIPELINES = {
    'scrapy_redis.pipelines.RedisPipeline': 400
}
#指定调度器
# 增加了一个去重容器类的配置, 作用使用Redis的set集合来存储请求的指纹数据, 从而实现请求去重的持久化
DUPEFILTER_CLASS = "scrapy_redis.dupefilter.RFPDupeFilter"
# 使用scrapy-redis组件自己的调度器
SCHEDULER = "scrapy_redis.scheduler.Scheduler"
# 配置调度器是否要持久化, 也就是当爬虫结束了, 要不要清空Redis中请求队列和去重指纹的set。如果是True, 就表示要持久化存储, 就不清空数据, 否则清空数据
SCHEDULER_PERSIST = True

#指定redis
REDIS_HOST = '192.168.13.254'
REDIS_PORT = 6379
```






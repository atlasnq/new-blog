---
title: 基于Scrapy框架的增量式爬虫
copyright: true
date: 2019-10-03 09:33:32
tags: [网络爬虫,python,scrapy,学习笔记]
categories: 网络爬虫
comments: true
urlname:  Web_Spider_10
---



{% cq %}本篇介绍监测网站数据变化的增量式爬虫。 {% endcq %}

<!--more-->

## 概述

概念：监测

核心技术：去重

- 基于 redis 的一个去重 

适合使用增量式的网站：

- 基于深度爬取的
  - 对爬取过的页面**url**进行一个记录（记录表）
- 基于非深度爬取的
  - 记录表：爬取过的数据对应的数据指纹
    - 数据指纹：原始数据的一组唯一标识
    - 数据  -->  数据指纹  --> 库中查询
    - hashlib

所谓的记录表是以怎样的形式存在于哪？

- redis的set充当记录表



## 例子

爬取4567电影网中影片名称以及简介，当网站有更新时爬取增加的了数据。

- 地址为：`https://www.4567tv.tv/frim/index1.html`
- 该例为基于深度爬取的。

`scrapy startproject zlsPro`

`scrapy genspider  zls  www.xxx.com`

### ①

- 使用手动传参进行深度的爬取
- 使用 `self.conn.sadd('movie_url', detail_url)` 的返回值来判断是否爬取过该电影。

```python
# zls.py
# -*- coding: utf-8 -*-
import scrapy
from zlsPro.items import ZlsproItem
from redis import Redis


class ZlsSpider(scrapy.Spider):
    name = 'zls'
    # allowed_domains = ['www.xxx.com']
    start_urls = ['https://www.4567tv.tv/frim/index1.html']
    conn = Redis('127.0.0.1', 6379)

    def parse(self, response):
        li_list = response.xpath('/html/body/div[1]/div/div/div/div[2]/ul/li')
        for li in li_list:
            title = li.xpath('./div/div/h4/a/text()').extract_first()
            detail_url = 'https://www.4567tv.tv' + li.xpath('./div/div/h4/a/@href').extract_first()
            ret = self.conn.sadd('movie_url', detail_url)
            if ret:
                # 如果成功写入则该url不存在，可以之后后续操作：
                performer = li.xpath('./div/div/p/text()').extract_first()
                item = ZlsproItem()
                item['title'] = title
                item['performer'] = performer
                yield scrapy.Request(detail_url, callback=self.parse_detail, meta={'item': item})
            else:
                print('暂无更新的数据')

    def parse_detail(self, response):
        item = response.meta['item']
        content = response.xpath(
            '//div[@class="stui-content__detail"]/p/span[@class="detail-content"]/text()').extract_first()
        item['content'] = content
        yield item

```

### ②

- 定义Item

```python
# items.py
import scrapy

class ZlsproItem(scrapy.Item):
    # define the fields for your item here like:
    title = scrapy.Field()
    performer = scrapy.Field()
    content = scrapy.Field()
```

### ③

- 定义pipeline
- 传入redis

```python
# pipelines.py
class ZlsproPipeline(object):

    def process_item(self, item, spider):
        title = item['title']
        performer = item['performer']
        content = item['content']
        conn = spider.conn
        conn.lpush('movie', item)
        return item
```


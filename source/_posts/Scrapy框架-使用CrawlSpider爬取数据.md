---
title: Scrapy框架——使用CrawlSpider爬取数据
copyright: true
date: 2019-10-01 15:47:46
tags: [网络爬虫,python,scrapy,学习笔记]
categories: 网络爬虫
comments: true
urlname:  Web_Spider_8
---



{% cq %}本篇介绍Crawlspider，相比于Spider，Crawlspider更适用于批量爬取网页。 {% endcq %}

<!--more-->

# Crawlspider

- Crawlspider适用于对网站爬取批量网页，相对比Spider类，CrawSpider主要使用规则（rules）来提取链接，通过定义一组规则为跟踪链接提供了遍历的机制。
- Crawlspider 的强大体现在自动爬取页面所有符合规则的链接并深入下去！



# 全站数据爬取

## 编码流程

1. 新建一个工程

2. cd 工程

3. 创建爬虫文件： `scrapy genspider -t crawl spiderName 地址`       （crawlspider 继承 scrapy.Spider）

   - 链接提取器  LinkExtractor
     - 可以根据指定的规则对指定的链接进行提取
       - 提取的规则就是构造方法中的 allow('正则表达式') 参数决定
   - 规则解析器  Rule
     - 可以将链接提取器提到的链接进行请求，可以根据指定的规则（callback）对请求到的数据进行解析

   `Rule(link, callback='parse_item', follow=True)` 

   - follow = True 表示每一个页码都当作起始url 然后进行链接提取，如果为 false 只能提取到第一页的几个页码。

   - follow = True; 将链接提取器 继续作用到 连接提取器提取到的链接 所对应的 页码源码中。



scrapy中发送请求的几种方式：

- start_url
- self.Request()    
- 链接提取器   



## 例子

使用CrawlSpider模板批量爬取（阳光热线问政平台的投诉帖子）的主题、状态和详细内容

地址为：`http://wz.sun0769.com/html/top/reply.shtml`

### ① 定义spider

`scrapy genspider -t crawl sun`  创建一个spider

在该spider文件中：

- 定义 `LinkExtractor` 获取每个页面中的页码的url地址。
- 定义 `Rule` ，放入 `LinkExtractor` 以及 `callback` ，对于 follow 值得话，如果为True得话，将继续作用到 `LinkExtractor`  提取到的链接 所对应的 页码源码中。

```python
# sun.py
# -*- coding: utf-8 -*-
import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule
from sunPro.items import Item1, Item2


class SunSpider(CrawlSpider):
    name = 'sun'
    # allowed_domains = ['www.xxx.com']
    start_urls = ['http://wz.sun0769.com/html/top/reply.shtml']
    # 链接提取器（如：获得每一个页码）
    link = LinkExtractor(allow=r'page=\d+')  # 空的话取所有url
    link_1 = LinkExtractor(allow=r'page=$')  # 拿到第一页数据
    link_detail = LinkExtractor(allow=r'question/\d+/\d+\.shtml')  # 拿到第一页数据 . 需要转义

    rules = (
        # 实例化一个Rule（规则解析器）对象
        Rule(link, callback='parse_item', follow=True),	
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



### ② 定义Item类



1. 两个Rule是为了拿到所有页码的url，它对应着 Item2
2. 另一个Rule是为了拿到所有详情页的url，它对应着 Item1

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



### ③ 定义pipeline

定义pipeline做持久化存储！

1. 在 `open_spider` 中开起连接
2. 在 `close_spider` 中关闭连接
3. 在 `process_item` 中执行数据库得插入操作。

遇到的问题：

- 第一个问题：主题和状态与详细内容如何对应起来呢？
  - 通过对页面进行分析发现，使用在这两个页面中都有编号，所以增加一个新的字段变化，来连接这两块。

- 两个数据解析函数不同于使用scrapy.Request进行手动传参，然后通过回调来进行连接。而现在只能定义两个 Item ，在管道中如何判断item类型：
  - `item.__class__.__name__` 表示类名

```python
# pipeline.py
import pymysql

class SunproPipeline(object):
    conn = None
    cursor = None

    def open_spider(self, spider):
        self.conn = pymysql.Connection(host='127.0.0.1', user='root', password="2296",
                                       database='spider', charset='utf8')

    def process_item(self, item, spider):
        self.cursor = self.conn.cursor()
        if item.__class__.__name__ == 'Item1':
            content = item['content']
            num = item['num']
            query_sql = 'select * from sun where num = %s'
            self.cursor.execute(query_sql, (num,))
            ret = self.cursor.fetchall()
            if ret:
                insert_sql = f'update sun set content = %s where num=%s'
                try:
                    self.cursor.execute(insert_sql, (content, num))
                    self.conn.commit()
                except Exception as e:
                    print(e)
                    self.conn.rollback()
            else:
                insert_sql = f'insert into sun(num,content) values (%s, %s)'
                try:
                    self.cursor.execute(insert_sql, (num, content))
                    self.conn.commit()
                except Exception as e:
                    print(e)
                    self.conn.rollback()
        else:
            title = item['title']
            status = item['status']
            num = item['num']
            query_sql = f'select * from sun where num = %s'
            self.cursor.execute(query_sql, (num,))
            ret = self.cursor.fetchall()
            if ret:
                insert_sql = f'update sun set title = %s,status = %s where num=%s'
                try:
                    self.cursor.execute(insert_sql, (title, status, num))
                    self.conn.commit()
                except Exception as e:
                    print(e)
                    self.conn.rollback()
            else:
                insert_sql = f'insert into sun(num,title,status) values (%s, %s,%s)'
                try:
                    self.cursor.execute(insert_sql, (num, title, status))
                    self.conn.commit()
                except Exception as e:
                    print(e)
                    self.conn.rollback()

        return item

    def close_spider(self, spider):
        self.cursor.close()
        self.conn.close()
```


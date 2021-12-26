---
title: 基于requests的爬虫
copyright: true
date: 2019-09-21 10:19:08
tags: [python,网络爬虫,学习笔记]
categories: 网络爬虫
comments: true
urlname:  Web_Spider_3
---



{% cq %}本篇介绍基于requests的爬虫。 {% endcq %}

<!--more-->

# 概述

概念：基于网络请求的模块

作用：用来模拟浏览器发请求，从而实现爬虫

# 通用爬虫

步骤：

1. 指定url
2. 请求发送：get返回的是一个响应对象
3. 获取响应数据: text返回的是字符串形式的响应数据
4. 持久化存储



## 爬取搜狗首页的页面源码数据

```python
import requests
# 1.指定url
url = 'https://www.sogou.com/'
# 2.请求发送：get返回的是一个响应对象
response = requests.get(url=url)
# 3. 获取响应数据: text返回的是字符串形式的响应数据
page_text = response.text
page_text
# 4. 持久化存储
with open('./sogou.html','w',encoding='utf-8') as fp:
    fp.write(page_text)
```



## 实现一个简易的网页采集器

- 请求参数动态化（自定义字典给get方法的params传参）
- 使用UA伪装

```python
url = 'https://www.sogou.com/web'
# 请求参数的动态化
wd = input('enter a key word：')
params = {
    'query':wd
}
# 没有做UA伪装是得不到数据的
headers = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
}

response = requests.get(url=url, params=params,headers=headers)

# 将响应数据的编码格式手动进行指定，来解决乱码问题。
response.encoding = 'utf-8'
page_text = response.text
fileName = wd + '.html'
with open(fileName,'w',encoding='utf-8') as fp:
    fp.write(page_text)
print(fileName,'爬取成功！')
```



## 动态加载的数据

- 页面中想要爬取的内容并不是请求当前url得到的，而是通过另一个网络请求请求到的数据（例如，滚轮滑到底部，会发送ajax，对局部进行刷新）



例子：爬取豆瓣电影中动态加载出的电影详情

我们想爬取的页面是：豆瓣电影分类排行榜 - 科幻片 `https://movie.douban.com/typerank?type_name=%E7%A7%91%E5%B9%BB&type=17&interval_id=100:90&action=`

- 首先在chorme的抓包工具中进行全局搜索发现它不是请求当前url得到的，而是一个新的url： `https://movie.douban.com/j/chart/top_list?`
  
- 当然这是一个ajax请求（在chorme的抓包工具中选择 XHR 可以进行查看）
  
- 在寻找另一部电影，请求的url仍然是 `https://movie.douban.com/j/chart/top_list?`

- 然后我们就需要找参数的规律了：

  ```python
  type: 17
  interval_id: 100:90
  action: 
  start: 0
  limit: 1
  # 第二部
  type: 17
  interval_id: 100:90
  action: 
  start: 20
  limit: 20
  ```

- start 和 limit 是可以变化的，基于例二，我们自定义字典进行传参，然后进行尝试。



```python
url = 'https://movie.douban.com/j/chart/top_list'
# 参数动态化
params = {
    'type': '5',
    'interval_id': '100:90',
    'action': '',
    'start': '01',
    'limit': '20',	
}
# start 决定起始位置，limit 为显示数量。
response = requests.get(url=url, params=params, headers=headers)

# json() 返回序列化好的对象（字典，列表）
movie_list = response.json()  
# 手动反序列化
# import json
# movie_list = json.loads(movie_list)
for movie in movie_list:
    print(movie['title'],movie['score'])
```

note：response.json() 可以免除我们手动使用json进行loads的过程。



## 爬取肯德基的餐厅位置信息

- 地址为：`http://www.kfc.com.cn/kfccda/storelist/index.aspx`

- post请求
- 一次爬取多页数据



思路：

- 首先，数据是动态加载的，分析请求方式为 post 发出的 url 与 data。
- 通过pageSize就可以在循环内完成多所有地址的爬取。

```python
url = 'http://www.kfc.com.cn/kfccda/ashx/GetStoreList.ashx?op=keyword'
data = {
    'cname':'', 
    'keyword':'北京',
    'pageIndex':1,
    'pageSize':10,
    'pid':''
}

with open(data['keyword']+'肯德基地址.txt','w',encoding='utf-8') as f:
    for i in range(1,data['pageSize']+1):
        data['pageIndex'] = i    
        address_dic = requests.post(url=url, data=data, headers=headers).json()
        for address in address_dic['Table1']:
            print(address['addressDetail'])
            f.write(address['addressDetail'] + '\n')          
```

补充：可以使用代理服务器，如搜索：全网代理IP



## 中标公告提取
- 需求
https://www.fjggfw.gov.cn/Website/JYXXNew.aspx 福建省公共资源交易中心

提取内容:

工程建设中的中标结果信息/中标候选人信息

1. 完整的html中标信息

2. 第一中标候选人

3. 中标金额

4. 中标时间

5. 其它参与投标的公司



思路：

1. 从首页打开一个公告，先尝试得到一个公告的信息。
2. 在得到另一个公告的信息进行比较，只有ID是变化的，所以有了ID就可以批量爬取了。
3. 回到首页，判断加载方式，确定数据的请求方式，url以及参数。



实现过程：

- 确认爬取的数据都是动态加载出来的
- 在首页中捕获到ajax请求对应的数据包，从该数据包中提取出请求的url和请求参数
- 对提取到的url进行请求发送，获取响应数据（json），（包含ID信息）
- 从json串中提取到每一个公告对应的id值
- 将id值和中标信息对应的url进行整合，进行请求发送捕获到每一个公告对应的中标信息数据

```python
# 该部分为得到一个公告的信息，但是我们这里的ID不灵活，需要进一步改进。
params = {
    'OPtype': 'GetGGInfoPC',
    'ID': 132458,
    'GGTYPE': 4,
    'url': 'AjaxHandler/BuilderHandler.ashx',
}
headers = {
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
    'Cookie': 'ASP.NET_SessionId=j0ps3kcjisaajyenlgihwwxo; Hm_lvt_94bfa5b89a33cebfead2f88d38657023=1570523570; Hm_lpvt_94bfa5b89a33cebfead2f88d38657023=1570523621; _qddagsx_02095bad0b=115b25431c8f1a2f7f607e8464ba7c5ef5807a77e65a44aa3c9045306ab0ba3bf02c48523e97b816f16d9ff0c57b6e77f46e59f8776b88c64cbd9da7f84676d8c4c9db3686235ef49e9ee7ff1871ec99884e7ba79b8c173e472b039b0c9a8fb61b4049ab036f68e1f5e0857c4bd4131f0c3b7478b98687d0b9c0538352871ec9',
}
url = 'https://www.fjggfw.gov.cn/Website/AjaxHandler/BuilderHandler.ashx'
response = requests.get(url=url, params=params, headers=headers)
response.text
```

完成了对公告详情的爬取后，接下来批量爬取公告。

```python
# 该部分完成了对前5页的公告信息进行爬取
url = 'https://www.fjggfw.gov.cn/Website/AjaxHandler/BuilderHandler.ashx'
headers = {
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
    'Cookie': 'ASP.NET_SessionId=j0ps3kcjisaajyenlgihwwxo; Hm_lvt_94bfa5b89a33cebfead2f88d38657023=1570523570; Hm_lpvt_94bfa5b89a33cebfead2f88d38657023=1570523621; _qddagsx_02095bad0b=115b25431c8f1a2f7f607e8464ba7c5ef5807a77e65a44aa3c9045306ab0ba3bf02c48523e97b816f16d9ff0c57b6e77f46e59f8776b88c64cbd9da7f84676d8c4c9db3686235ef49e9ee7ff1871ec99884e7ba79b8c173e472b039b0c9a8fb61b4049ab036f68e1f5e0857c4bd4131f0c3b7478b98687d0b9c0538352871ec9',
}
data = {
    'OPtype': 'GetListNew',
    'pageNo': 1,
    'pageSize': 10,
    'proArea': -1,
    'category': 'GCJS',
    'announcementType': -1,
    'ProType': -1,
    'xmlx': -1,
    'projectName': '',
    'TopTime': '2019-07-10 00:00:00',
    'EndTime': '2019-10-08 23:59:59',
    'rrr': 0.8853761868569314,
}
params = {
    'OPtype': 'GetGGInfoPC',
    'ID': 132458,
    'GGTYPE': 4,
    'url': 'AjaxHandler/BuilderHandler.ashx',
}
count = 0
for i in range(1,6):
    data['pageNo'] = i    
    # 第i页内容的爬取
    response = requests.post(url=url,data=data,headers=headers)
    post_data = response.json()
    for row in post_data['data']:
        ID = int(row['M_ID'])
        params['ID'] = ID
        company_respose = requests.get(url=url, params=params, headers=headers)
        company_detail = company_respose.json()['data']
#         print(company_detail)
        count += 1
print(count)    
```



## 爬取图片

如何做？
- 基于requests
- 基于urllib 
- 区别：urllib中的 urlretrieve 不可以进行UA伪装
requests在urllib基础上产生，更加pythonic！



### 基于requests的图片爬取

```python
import requests
headers = {
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
}
# 基于requests的图片爬取
url = r'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1570593174006&di=5ade9e1cb9e63a708c69095283f8e40a&imgtype=0&src=http%3A%2F%2Fdingyue.nosdn.127.net%2F92Ot1vmaeOklEbu2G7ABakMeGiYWpYi8R3urPnggBDJSs1535663928397.jpeg'
img_data = requests.get(url=url, headers=headers).content   # content 返回的是bytes类型的响应数据
with open('./123.jpg','wb') as fp:
    fp.write(img_data)
```

- request更具通用性，数据可以展示为：text（字符串），json（列表/字典），content（字节）。



### 基于urllib的图片爬取

```python
# 基于urllib
from urllib import request
url = 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1570593174006&di=5ade9e1cb9e63a708c69095283f8e40a&imgtype=0&src=http%3A%2F%2Fdingyue.nosdn.127.net%2F92Ot1vmaeOklEbu2G7ABakMeGiYWpYi8R3urPnggBDJSs1535663928397.jpeg'
request.urlretrieve(url,'./456.jpg')
```

- 由于urlretrieve不能做UA伪装，所以存在图片缺失的可能。



# 聚焦爬虫

较通用爬虫相比，增加了**数据解析**。



## 数据解析
概念：将一整张页面的局部数据进行提取/解析

作用：用来实现聚焦爬虫

实现方式：
- 正则：可以匹配任意，下面方式拿不到 js 代码中的数据
- bs4
- xpath
- pyquery

数据解析的通用原理是什么？
- 标签的定位
- 数据的提取

页面中的相关的字符串的数据都存储在哪里？
- 标签中间
- 标签的属性中



基于聚焦爬虫的编码流程

- 指定url
- 发起请求
- 获取响应数据
- **数据解析**
- 持久化存储



## 正则解析
### 爬取煎蛋网中的图片

- 地址为：`http://jandan.net/pic/MjAxOTEwMDktNjk=#comments`

实现过程：

- 指定url
- 获取响应数据
- 数据解析
  - 写正则表达式
  - 正则匹配
- 持久化存储

```python
import re
import os
url = 'http://jandan.net/pic/MjAxOTEwMDktNjk=#comments'
page_text = requests.get(url=url,headers=headers).text
# 解析数据：img标签的src的属性值

# 写正则表达式
# print(page_text) # 参考page_text来定正则，网页源码可能有些小问题
# ex = r'<div class="text">.*?<img src="(.*?)" referrerpolicy'   # 坑！！！
ex = r'<div class="text">.*?<img src="(.*?)" referrerPolicy'   # 在源码中那里的p是小写，可爬下来的p是大写，坑~~~

dirName = './JDimg/'
if not os.path.exists(dirName):
    os.mkdir(dirName)
img_url_list = re.findall(ex,page_text,re.S)   # re.S处理回车
for img_url in img_url_list:
    ex2 = r'org_src="(.*?)"'
    gif_url = re.findall(ex2,img_url)
    if gif_url:
        new_url = 'http:' + gif_url[0]
    else:
        new_url = 'http:' + img_url
    name = new_url.split('/')[-1]
    img = requests.get(new_url,headers=headers).content
    img_path = dirName + name 
    with open(img_path,'wb') as fp:
        fp.write(img)
    print(name,'下载完成!!!')
```

note：内容依据响应数据page_text，而不是根据浏览器中网页上的代码，上面就出现一个字母的大小写不同而导致正则失效的例子。



## bs4解析
环境的安装：

- pip install bs4
- pip install lxml

bs4的解析原理：
- 实例化一个BeatifulSoup的一个对象，把即将被解析的页面源码数据加载到该对象中
- 需要调用BeatifulSoup对象中的相关的<span style="color:red">方法</span>和<span style="color:red">属性</span>进行标签定位和数据的提取

BeatifulSoup的实例化
- BeatifulSoup(fp, 'lxml') 将本地存储的html文档中的页面源码数据加载到该对象中
- BeatifulSoup(page_text, 'lxml') 将从互联网中请求到的页面源码数据加载到该对象中

标签的定位
- soup.tagName: 只可以定位到第一个tagName标签
- 属性定位：
    - soup.find('div','attrName='value')  只能定位到符合要求的第一个
    - soup.findAll：返回列表，可以定位到符合要求的所有标签
    note：只有class需要加下划线，其它直接用原名就可以。
- 选择器定位：
    - select('选择器')
    - 选择器：id，class，tag，层级选择器（大于号表示一个层级，空格表示多个层级）

- 取文本
    - text：将标签中所有文本取出
    - string：将标签中直系的文本取出
- 取属性
    - tag['attrName']
    

### 熟悉

此为练手的html。

```html
<html lang="en">
<head>
	<meta charset="UTF-8" />
	<title>测试bs4</title>
</head>
<body>
	<div>
		<p>百里守约</p>
	</div>
	<div class="song">
		<p>李清照</p>
		<p>王安石</p>
		<p>苏轼</p>
		<p>柳宗元</p>
		<a href="http://www.song.com/" title="赵匡胤" target="_self">
			<span>this is span</span>
		宋朝是最强大的王朝，不是军队的强大，而是经济很强大，国民都很有钱</a>
		<a href="" class="du">总为浮云能蔽日,长安不见使人愁</a>
		<img src="http://www.baidu.com/meinv.jpg" alt="" />
	</div>
	<div class="tang">
		<ul>
			<li><a href="http://www.baidu.com" title="qing">清明时节雨纷纷,路上行人欲断魂,借问酒家何处有,牧童遥指杏花村</a></li>
			<li><a href="http://www.163.com" title="qin">秦时明月汉时关,万里长征人未还,但使龙城飞将在,不教胡马度阴山</a></li>
			<li><a href="http://www.126.com" alt="qi">岐王宅里寻常见,崔九堂前几度闻,正是江南好风景,落花时节又逢君</a></li>
			<li><a href="http://www.sina.com" class="du">杜甫</a></li>
			<li><a href="http://www.dudu.com" class="du">杜牧</a></li>
			<li><b>杜小月</b></li>
			<li><i>度蜜月</i></li>
			<li><a href="http://www.haha.com" id="feng">凤凰台上凤凰游,凤去台空江自流,吴宫花草埋幽径,晋代衣冠成古丘</a></li>
		</ul>
	</div>
</body>
</html>
```



熟悉 BeautifulSoup 的选择器以及如何取文本和属性

```python
fp = open('./test.html',encoding='utf-8') 
soup = BeautifulSoup(fp ,'lxml')
soup.div				
type(soup.div)                   # bs4.element.Tag
soup.find('div')
soup.find('div',class_="song")   # 由于class 是关键字，所以需要加下划线

#下面的 findAll 与 select 都将返回列表
soup.findAll('div')              
soup.select('div')     
soup.select('div[class="song"]') 
soup.select('.song')
soup.select('div > ul > li')
soup.select('div li')

# 取文本
soup.select('div li')[0].text    
soup.select('.song')[0].text
soup.select('.song')[0].string    # 只能取直系,所以这个结果为空
soup.select('b')[0].string      

# 取属性
soup.select('div a')[0]['href']
```



### 爬取三国演义小说的标题和内容

- 地址为：`http://www.shicimingju.com/book/sanguoyanyi.html`

数据解析流程：

- 首先定位标签
- 然后取出文本和内容

```python
main_url = 'http://www.shicimingju.com/book/sanguoyanyi.html'
page_text = requests.get(url=main_url,headers=headers).text
# 数据解析: 章节的标题和详情页的url
soup = BeautifulSoup(page_text,'lxml')
li = soup.select('.book-mulu a')
fp = open('./sanguo.txt','w',encoding='utf-8')
for i in li:
    title = i.string
    detail_url = 'http://www.shicimingju.com' + i['href']
    detail_page_text = requests.get(url=detail_url,headers=headers).text
    # 数据解析：章节内容
    detail_soup = BeautifulSoup(detail_page_text,'lxml')
    detail = detail_soup.find('div',class_='chapter_content').text
    fp.write(title + '\n' + detail + '\n\n')
fp.close()
```



## xpath 解析
- 环境的安装
    - pip install lxml
- 解析原理
    - 实例化一个etree的对象，且把即将被解析的页面源码数据加载到该对象中
    - 调用etree对象中的xpath方法结合着<span class="mark">不同形式的xpath表达式</span>进行标签定位和数据提取
- etree对象的实例化
    - etree.parse('fileName')
    - etree.HTML(page_text)
- 标签定位
    - 最左侧的/：一定要从根标签开始进行标签定位
    - 非最左侧的/：表示一个层级
    - 最左侧的//：可以从任意位置进行指定标签的定位
    - 非最左侧的//：表示多个层级
    - 属性定位：
        - //tagName[@attrName="value"]
    - 索引定位：
        - //tagName[@attrName="value"]/li[2]，索引是从1开始的
    - 逻辑运算：
          - 找到href属性值为空且class属性值为du的a标签
      - //a[@href="" and @class="du"]
    - 模糊匹配：
        - //div[contains(@class, "ng")]
        - //div[starts-with(@class, "ta")]
    
- 取文本
    - /text():取直系的文本内容
    - //text()：取所有文本内容

- 取属性
    - /@attrName
    

note：
- 返回的都是列表
- 在google中的Element可以直接copy xpath
- 在xpath表达式中不可以出现tbody标签



### 熟悉

依旧使用上面的html练手

```python
from lxml import etree
tree = etree.parse('./test.html')
tree        # <lxml.etree._ElementTree at 0x231b25371c8>
tree.xpath('/html')
tree.xpath('/html//title')
tree.xpath('//div')
# 属性定位
tree.xpath('//*[@class="tang"]')
tree.xpath('//div[@class="song"]')
tree.xpath('//div[@class="tang"]/ul/li')
# 索引定位
tree.xpath('//div[@class="tang"]/ul/li[2]')   

# 取文本
tree.xpath('//b/text()')   # 取直系
tree.xpath('//div[@class="tang"]/ul/li//text()')   # 取所有

# 取属性
tree.xpath('//a/@href')   
```



### 爬取虎牙主播名称，热度和标题

- 地址为：https://www.huya.com/g/xingxiu

```python
url = 'https://www.huya.com/g/xingxiu'
page_text = requests.get(url,headers=headers).text
tree = etree.HTML(page_text)
li_list = tree.xpath('//div[@class="box-bd"]/ul/li')
# print(page_text)
for li in li_list:
    title = li.xpath('./a[2]/@title')[0] 
    name = li.xpath('./span/span[1]/i/@title')[0] 
    hot = li.xpath('./span/span[2]/i[2]/text()')[0] 
    print(name,'的直播间: ',title,'热度为:',hot)
```



### 爬取前5页的妹子

地址为：`http://sc.chinaz.com/tag_tupian/yazhoumeinv.html`

- 涉及中文乱码
  - 以前对response对象设置 encoding 这样针对一整张页面代价大。
  - 我们只需要对想要的内容进行转码。
  - 通常由 iso-8859-1  --> utf-8   先编码成iso-8859-1 在解码成 utf-8 或gbk
- 多页码数据的爬取
  - 制定一个通用的url模板



```python
# 通用模板
url = 'http://sc.chinaz.com/tag_tupian/yazhoumeinv_%s.html'

for i in range(1,6):
    # 获取页面
    if i == 1:
        new_url = 'http://sc.chinaz.com/tag_tupian/yazhoumeinv.html'
    else:
        new_url = format(url%i)

    page_text = requests.get(new_url,headers=headers).text

    # 数据解析
    tree = etree.HTML(page_text)
    img_list = tree.xpath('//*[@id="container"]/div/div/a')  

    dirName = ('./MZimg')
    if not os.path.exists(dirName):
        os.makedirs(dirName)

    with open('./MZ.html','w',encoding='utf-8') as f:
        f.write(page_text)
    for li in img_list:        
        title = li.xpath('./img/@alt')[0].encode(' iso-8859-1').decode('utf-8') + '.jpg'		
        # print(li.xpath('./img/@src2'))     
        # 由于是惰性加载，所以这里没有值，这该怎么办呢？ 发现这里的惰性加载只是用src2替换src
        # 疑惑: 为什么./@src2 得不到，而必须用 ./img/@src2 呢？  ~~~
        
        src = li.xpath('./img/@src2')[0]
        img = requests.get(src,headers=headers).content
        # 数据持久化存储
        img_path = dirName + '/' + title    
        with open(img_path,'wb') as fp:
            fp.write(img)
 
    print(f'第{i}页妹纸完成抓取')
```



### 爬取全国所有城市的名称，包含热门城市和全部城市

待补充！！！







### 梨视频短视频的爬取

- 需求：爬取 `https://www.pearvideo.com/category_8` 这一页的一组视频

- 视频的url是藏在script中，所以只能配合正则去解析。

```python
url = 'https://www.pearvideo.com/category_8'
page_text = requests.get(url,headers=headers).text
# 数据解析:得到视频的名字与视频详情页的url
tree = etree.HTML(page_text)
li_list = tree.xpath('//*[@id="listvideoListUl"]/li')
for li in li_list:
    name = li.xpath('./div/a/div[2]/text()')[0] + '.mp4'
    detail_url = 'https://www.pearvideo.com/' + li.xpath('./div/a/@href')[0]
    detail_page_text = requests.get(detail_url,headers=headers).text
    # 数据解析：得到视频的url
    detail_tree = etree.HTML(detail_page_text)
    video = detail_tree.xpath('//script/text()')
    st = ''.join(video)
    ex = r'srcUrl="(.*?.mp4)"'
    # print(video)
    video_url = re.findall(ex,st)[0]
    mp4 = requests.get(video_url,headers=headers).content
    # 得到视频的bytes流。
    with open(name,'wb') as fp:
        fp.write(mp4)
    print('下载完成！')    
```



# requests高级

- 下面介绍的本质上也是针对反爬机制做出的策略。

## 代理

- 概念：代理服务器
- 代理的作用：
    - 请求和响应的转发（拦截请求和响应）
- 代理和爬虫之间的关联是什么？
    - 可以基于代理实现更换爬虫程序请求的ip地址
- 代理ip的网站
    - 西祠代理  `https://www.xicidaili.com/nn`
    - 快代理
    - www.goubanjia.com
    - 代理精灵
- 代理的匿名度
    - 高匿名：不知道是否使用代理服务器，也无法知道最终的ip
    - 匿名：使用了代理服务器，但不知道最终ip
    - 透明：
- 类型
    - http：只能转发http协议的请求
    - https：可以转发https的请求
- chrome添加代理
    - 设置搜索 代理
    - 在连接下，点击局域网设置，点击代理服务器并进行配置。
    
- 目标：在requests使用代理
    - proxies参数: `{ 'https' : 'ip:port' }`



### 使用代理ip

- 我是在[代理精灵](http://www.jinglingdaili.com/)买的，6块300个，每个可以用5-25分钟。
- 先尝试一个，然后爬取 `百度搜索ip页面` 保存到本地，查看ip是否发生变化。

```python
# 在http://www.jinglingdaili.com/ 
url = 'https://www.baidu.com/s?wd=ip'
page_text = requests.get(url,headers=headers,proxies={'https':'140.250.89.43:31799'}).text
with open('./ip.html','w',encoding='utf-8') as fp:
    fp.write(page_text)

# note: 这个代理会查看当前用户ip，如果用户ip不在白名单则无法使用，引起ProxyError
```



### 搭建付费的代理池

- 需求：还是前面的买的那些ip，给代理池中放50个ip
- 首先在代理精灵中生成API链接，有了这个链接，我们就可以直接爬取了

```python
url = 'http://ip.11jsq.com/index.php/api/entry?method=proxyServer.generate_api_url&packid=2&fa=0&fetch_key=&groupid=0&qty=50&time=1&pro=&city=&port=1&format=txt&ss=1&css=&dt=1&specialTxt=3&specialJson=&usertype=2'
page_text = requests.get(url,headers=headers).text
tree = etree.HTML(page_text)
ip_pools = tree.xpath('//body//text()')[0].split('\r\n')  
# ip_pools = tree.xpath('//pre/text()')    # 一个疑惑：为什么 //pre/text() 没有结果呢？ 因为你的page_text 和你看到的网页不同
print(len(ip_pools))
```

note：如果提取不到说句，说明你的xpath表达式不正确，我们参考page_text的输出进行编写。



### 搭建一个免费的代理池

- 需求：将 [西祠代理](https://www.xicidaili.com/nn) 上面展示的 ip，端口以及类型进行爬取。
- 当然，这些数据其实还需要进行测试，待补充！！！



不使用代理，本机IP直接尝试，但是不到50页就会被封掉IP

```python
url = 'https://www.xicidaili.com/nn/%s'    # 通用的url模板(不可变)
all_ips = []
for page in range(1,30):
    new_url = format(url%page)
    page_text = requests.get(new_url,headers=headers).text
    tree = etree.HTML(page_text)
    # 在xpath表达式中不可以出现tbody标签
#     tr_list = tree.xpath('//*[@id="ip_list"]/tbody/tr')[1:]   # 过滤掉第1个无效的
    tr_list = tree.xpath('//*[@id="ip_list"]//tr')[1:]   # 过滤掉第1个无效的
    for tr in tr_list:
        ip = tr.xpath('./td[2]/text()')[0]
        port = tr.xpath('./td[3]/text()')[0]
        ip_type = tr.xpath('./td[6]/text()')[0]
        all_ips.append({
            'ip':ip,
            'port':port,
            'type':ip_type,
        })
print(len(all_ips))    
fin_ips = []

# 接下来对放在列表中的元素进行测试，如果不行就排除
test_url = 'https://www.baidu.com/'
for ip_dic in all_ips:  
    r = requests.get(test_url,headers=headers,proxies={ip_dic['type']:ip_dic['ip'] + ':' + ip_dic['port']})
    if r.status_code == 200:
        fin_ips.append(ip_dic)
print(len(all_ips))
print(len(fin_ips))
```



为了爬取大量数据，我们借助上面搭建的代理池再次尝试！

```python
# 构建付费的代理池
url = 'http://ip.11jsq.com/index.php/api/entry?method=proxyServer.generate_api_url&packid=2&fa=0&fetch_key=&groupid=0&qty=50&time=1&pro=&city=&port=1&format=txt&ss=1&css=&dt=1&specialTxt=3&specialJson=&usertype=2'
page_text = requests.get(url,headers=headers).text
tree = etree.HTML(page_text)
ip_pools = tree.xpath('//body//text()')[0].split('\r\n')  
# ip_pools = tree.xpath('//pre/text()')    # 一个疑惑：为什么 //pre/text() 没有结果呢？ 因为你的page_text 和你看到的网页不同
print(len(ip_pools))

# 使用代理池中的代理，来解决ip限制

# 通用url
xici_url = 'https://www.xicidaili.com/nn/%s'

# 从西祠代理爬取到的IP池，包含ip，port，type
all_ips = []
for page in range(1,50):
    new_url = format(xici_url%page)
    page_text = requests.get(new_url,headers=headers,proxies={'https':random.choice(ip_pools)}).text
    tree = etree.HTML(page_text)
    # 在xpath表达式中不可以出现tbody标签
#     tr_list = tree.xpath('//*[@id="ip_list"]/tbody/tr')[1:]   # 过滤掉第1个无效的
    tr_list = tree.xpath('//*[@id="ip_list"]//tr')[1:]   # 过滤掉第1个无效的
    for tr in tr_list:
        ip = tr.xpath('./td[2]/text()')[0]
        port = tr.xpath('./td[3]/text()')[0]
        ip_type = tr.xpath('./td[6]/text()')[0]
        all_ips.append({
            'ip':ip,
            'port':port,
            'type':ip_type,
        })
print(len(all_ips)) 
# 接下来对放在列表中的元素进行测试，如果不行就排除
test_url = 'https://www.baidu.com/'
for ip_dic in all_ips:  
    r = requests.get(test_url,headers=headers,proxies={ip_dic['type']:ip_dic['ip'] + ':' + ip_dic['port']})
    if r.status_code == 200:
        fin_ips.append(ip_dic)
print(len(all_ips))
print(len(fin_ips))
```



## cookie

爬虫中怎样处理cookie？
- 手动处理：
  - 将cookie写在headers中，（不涉及有效时长以及动态变化）

- 自动处理：
    - 使用session对象：requests.Session()，它也被称为 [会话对象](https://requests.kennethreitz.org/zh_CN/latest/user/advanced.html#session-objects) 
        - 会话对象让你能够跨请求保持某些参数。它也会在同一个 Session 实例发出的所有请求之间保持 cookie
    - 作用：
        - session对象和requests对象都可以对指定的url进行请求发送。只不过使用session进行请求发送的过程中，如果产生了cookie则cookie会被自动存储到session对象中。



### 爬取雪球网的新闻和内容

- 地址：`https://xueqiu.com` 

```python
# 错误尝试
# 首先我们发现它是一个动态加载的，找到url，尝试拿到这条新闻
url = 'https://xueqiu.com/v4/statuses/public_timeline_by_category.json?since_id=-1&max_id=20352368&count=15&category=-1'
dic = requests.get(url,headers=headers).json()
print(dic)
# 输出如下：
# {'error_description': '遇到错误，请刷新页面或者重新登录帐号后再试', 'error_uri': '/v4/statuses/public_timeline_by_category.json', 'error_data': None, 'error_code': '400016'}
```

​	有了这种提示，说明我们需要使用cookie了，为什么呢？因为你访问的这个地址并不是首页，而是在首页的基础上给后端发送 ajax 请求，所以有了基于cookie的反爬。



- 那我们该怎么做呢？是需要实例化 requests.Session() 对象，同requests的使用方式，进行使用。

```python
# 创建会话对象
s = requests.Session()
s.get('https://xueqiu.com',headers=headers)

url = 'https://xueqiu.com/v4/statuses/public_timeline_by_category.json?since_id=-1&max_id=20352368&count=15&category=-1'
# 保证该次请求携带的cookie 才可以请求成功
dic = s.get(url,headers=headers).json()
print(dic)	
```

这回就可以拿到数据了。但是如果由 cookie 检测的时候才会选择使用会话对象，毕竟存在效率问题。

## 验证码的识别

对于验证码我们大多使用在线打码平台，给大家推荐几个：

- 超级鹰（正在用）
- 云打码

打码平台（超级鹰）的使用：

- 注册
- 登录
  - 创建一个软件，复制软件ID
  - 下载示例代码《开发文档》

所以我们需要做的就是将验证码爬取下来，使用打码平台的API的到结果。



下面这个是超级鹰的内部实现：

```python
import requests
from hashlib import md5

class Chaojiying_Client(object):

    def __init__(self, username, password, soft_id):
        self.username = username
        password =  password.encode('utf8')
        self.password = md5(password).hexdigest()
        self.soft_id = soft_id
        self.base_params = {
            'user': self.username,
            'pass2': self.password,
            'softid': self.soft_id,
        }
        self.headers = {
            'Connection': 'Keep-Alive',
            'User-Agent': 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0)',
        }

    def PostPic(self, im, codetype):
        """
        im: 图片字节
        codetype: 题目类型 参考 http://www.chaojiying.com/price.html
        """
        params = {
            'codetype': codetype,
        }
        params.update(self.base_params)
        files = {'userfile': ('ccc.jpg', im)}
        r = requests.post('http://upload.chaojiying.net/Upload/Processing.php', data=params, files=files, headers=self.headers)
        return r.json()

    def ReportError(self, im_id):
        """
        im_id:报错题目的图片ID
        """
        params = {
            'id': im_id,
        }
        params.update(self.base_params)
        r = requests.post('http://upload.chaojiying.net/Upload/ReportError.php', data=params, headers=self.headers)
        return r.json()
```

将打码工具封装：

```python
def get_code(img_path,ctype):
    chaojiying = Chaojiying_Client('用户名', '密码', '901824')        #用户中心>>软件ID 生成一个替换 96001
    im = open(img_path, 'rb').read()
    return chaojiying.PostPic(im, ctype)['pic_str']  #1902 验证码类型  官方网站>>价格体系 3.4+版 print 后要加()  
```



## 模拟登录

攻克了验证码来尝试一下模拟登录哈！

- 地址为：`https://so.gushiwen.org/user/login.aspx?from=http://so.gushiwen.org/user/collect.aspx`

```python
# 得到验证码的图片，并存储到本地
main_url = 'https://so.gushiwen.org/user/login.aspx?from=http://so.gushiwen.org/user/collect.aspx'

# 实例化会话对象
s = requests.Session()
page_text = s.get(main_url,headers=headers).text
tree = etree.HTML(page_text)
img_url = 'https://so.gushiwen.org' + tree.xpath('//*[@id="imgCode"]/@src')[0] 
# 当然如果我们直接拿验证码的图片会发现，这个地址是直接可以随机生成验证码的 

# 使用超级鹰解决验证码
img_data = s.get(img_url).content     # 这里是坑，原本以为访问首页就能拿到cookie，这里不用会话对象，可实际上cookie是在这里产生的。
with open('./code.jpg','wb') as fp:
    fp.write(img_data)
code = get_code('./code.jpg',1004)
print(code)
__VIEWSTATE = tree.xpath('//*[@id="__VIEWSTATE"]/@value')[0]
__VIEWSTATEGENERATOR = tree.xpath('//*[@id="__VIEWSTATEGENERATOR"]/@value')[0]
print(__VIEWSTATE)
print(__VIEWSTATEGENERATOR)

# 只需要给这个地址发post请求
login_url = 'https://so.gushiwen.org/user/login.aspx?from=http%3a%2f%2fso.gushiwen.org%2fuser%2fcollect.aspx'
data = {
    '__VIEWSTATE': __VIEWSTATE,    # 动态数据，隐藏在前面标签内
    '__VIEWSTATEGENERATOR': __VIEWSTATEGENERATOR,
    'from': 'http://so.gushiwen.org/user/collect.aspx',
    'email': '用户名',
    'pwd': '密码',
    'code': code,
    'denglu': '登录',
}
ret = s.post(login_url,data=data,headers=headers).text
with open('./gushi.html','w',encoding='utf-8') as fp:
    # 存储到本地并以此判断我们是否成功登录
    fp.write(ret)
```

这里设计的坑：

1. 验证码
2. 动态参数 __VIEWSTATE 等是隐藏在前端页面源码中的
3. 需要携带cookie才能成功，而设置cookie的地方却在请求验证码。

所以如果涉及cookie，觉得不确定就都用会话对象处理。





# 遇到的错误以及解决方式

## 超时 

- headers中加 Connection:'close'



## 代理错误

**ProxyError**: HTTPSConnectionPool(host='www.baidu.com', port=443): Max retries exceeded with url: /s?tn=80035161_2_dg&wd=ip (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 503 Service Unavailable')))

- 我的代理并没有生效，这个代理是绑定本机ip的，但是我的ip不再白名单中。



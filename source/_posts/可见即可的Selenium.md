---
title: 可见即可的Selenium
copyright: true
date: 2019-09-26 21:04:36
tags: [网络爬虫,python,学习笔记]
categories: 网络爬虫
comments: true
urlname:  Web_Spider_6
---



{% cq %}本篇介绍爬虫的一把利器Selenium。 {% endcq %}

<!--more-->



## 概念

概念：基于浏览器自动化的一个模块。

​			广泛用于自动化测试

selenium和爬虫之间的关联

- **便捷**的爬取到动态加载的数据
  - **可见即可得**
- 便捷的实现模拟登录

基本使用

- 环境安装   pip install selenium
- 下载浏览器得驱动程序
  - 地址： `https://npm.taobao.org/mirrors/chromedriver`
  - 浏览器版本和驱动程序得映射关系：按照浏览器的大版本号下载最新即可。
    - 如我的浏览器是 76.0.3809.132 下载 [76.0.3809.68/](https://npm.taobao.org/mirrors/chromedriver/76.0.3809.68/)     



原则：

- 迫不得已之后是使用 selenium

- selenium 不支持异步

- pyppeteer 支持异步，基于asyncio

扩充：

- Appnium：基于手机的自动化的模块

  



## 演示程序

```python
from selenium import webdriver
from time import sleep

# 后面是你的浏览器驱动位置，记得前面加r'','r'是防止字符转义的
driver = webdriver.Chrome(r'chromedriver.exe')
# 用get打开百度页面
driver.get("http://www.baidu.com")
# 查找页面的“设置”选项，并进行点击
driver.find_elements_by_link_text('设置')[0].click()
sleep(2)
# # 打开设置后找到“搜索设置”选项，设置为每页显示50条
driver.find_elements_by_link_text('搜索设置')[0].click()
sleep(2)

# 选中每页显示50条
m = driver.find_element_by_id('nr')
sleep(2)
m.find_element_by_xpath('//*[@id="nr"]/option[3]').click()
m.find_element_by_xpath('.//option[3]').click()
sleep(2)

# 点击保存设置
driver.find_elements_by_class_name("prefpanelgo")[0].click()
sleep(2)

# 处理弹出的警告页面   确定accept() 和 取消dismiss()
driver.switch_to_alert().accept()
sleep(2)
# 找到百度的输入框，并输入 美女
driver.find_element_by_id('kw').send_keys('美女')
sleep(2)
# 点击搜索按钮
driver.find_element_by_id('su').click()
sleep(2)
# 在打开的页面中找到“Selenium - 开源中国社区”，并打开这个页面
driver.find_elements_by_link_text('美女_百度图片')[0].click()
sleep(3)

# 关闭浏览器
driver.quit()
```





## 基本操作

```python
from selenium import webdriver
import time
# 实例化某一款浏览器对象
bro = webdriver.Chrome(executable_path='chromedriver.exe')

# 基于浏览器发起请求
bro.get('https://www.jd.com/')

# 商品搜索
# 标签定位
search_input = bro.find_element_by_id('key')

# 往定位到的标签录入数据
search_input.send_keys('袜子')

# 点击搜索按钮
btn = bro.find_element_by_xpath('//*[@id="search"]/div/div[2]/button')
time.sleep(2)
btn.click()

# 滚轮滑动（js注入）

bro.execute_script('window.scrollTo(0, document.body.scrollHeight)')

time.sleep(3)

# 关闭浏览器
bro.quit()
```



## 爬取动态数据

- 在爬取页面的时候我们要先判断数据是不是动态加载的，如果是动态加载的话就需要找它的url
- 对于selenium无须如此，可见即可得



需求：爬取 `https://www.fjggfw.gov.cn/Website/JYXXNew.aspx` 所展示得公告标题。

```python
from selenium import webdriver
import time
from lxml import etree

# 实例化某一款浏览器对象
bro = webdriver.Chrome(executable_path='chromedriver.exe')

bro.get('https://www.fjggfw.gov.cn/Website/JYXXNew.aspx')
time.sleep(1)

# page_source：当前页面所有得页面源码数据
page_text = bro.page_source

# 存储前3页对应得页面源码数据
all_page_text = [page_text]
for i in range(2):
    next_page_btn = bro.find_element_by_xpath('//*[@id="kkpager"]/div[1]/span[1]/a[7]')
    next_page_btn.click()
    time.sleep(1)
    all_page_text.append(bro.page_source)

for page_text in all_page_text:
    tree = etree.HTML(page_text)
    titles = tree.xpath('//*[@id="list"]/div/div/h4//text()')
    for title in titles:
        print(title)
```



## 动作链

需求：打开 `https://www.runoob.com/try/try.php?filename=jqueryui-api-droppable` 并拖动方块

动作链：

- 实例化 `ActionChains(bro)` 后就可以使用动作了
- 在使用find系列得函数进行标签定位得时候如果出现了**NoSuchElementException**的时候：可能是iframe做html嵌套
- 如果定位的标签是存在于 iframe 标签之下的，则在进行指定标签定位的时候，必须使用 switch_to.frame() 操作即可

```python
from selenium import webdriver
from selenium.webdriver import ActionChains  # 动作链得类
from time import sleep

bro = webdriver.Chrome(executable_path='chromedriver.exe')
bro.get('https://www.runoob.com/try/try.php?filename=jqueryui-api-droppable')
sleep(1)

bro.switch_to.frame('iframeResult')  # 给frame传入iframe标签的id，一个iframe表示一个页面
# NoSuchElementException
div_tag = bro.find_element_by_id('draggable')

# 基于动作链实现滑动/拖动
# 动作制定好后，可以在任意的浏览器中，它们并没有强约束
action = ActionChains(bro)
# 点击且长按
action.click_and_hold(div_tag)

for i in range(5):
    # perform() 表示让动作链立即执行
    action.move_by_offset(20, 0).perform()  # 右移动20像素
    sleep(0.5)

sleep(2)
bro.quit()

```



## 谷歌无头浏览器

😨第一次听这么恐怖得名称，所谓无头（headless）浏览器指的是没有可视化界面得浏览器。这样打包好给用户，不至于用户在使用得时候发现自己得浏览器开始骚操作了~

- 当然还有一个无头浏览器，称为phantomjs（停止更新了）。

只需要在原来代码得基础上加入如下内容：

```python
from selenium.webdriver.chrome.options import Options
# 创建一个参数对象，用来控制chrome以无界面模式打开
chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--disable-gpu')
```



例子：打开淘宝并截图

```python
from selenium import webdriver


from selenium.webdriver.chrome.options import Options
# 创建一个参数对象，用来控制chrome以无界面模式打开
chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--disable-gpu')


bro = webdriver.Chrome(executable_path='chromedriver.exe',chrome_options=chrome_options)
bro.get('https://www.taobao.com/')
bro.save_screenshot('./taobao.jpg')

print(bro.page_source)
```



## 如果规避监测

既然selenium这么利，防守方该怎么做呢？

- 服务器会对 selenium 暴露出的一些变量进行监测，如果监测到用户使用了 selenium 则不让其访问。

首先执行如下：

```python
from selenium import webdriver

bro = webdriver.Chrome('chromedriver.exe')
bro.get('https://www.taobao.com')
```

打开淘宝页面，然后我们打开开发者工具，点击 console 执行 js 注入，输入这一句：

`window.navigator.webdriver`

- undefined：正常
- true：使用了selenium



那我们该如何规避监测呢？ 同样是一段代码，随用随粘

```python
from selenium.webdriver import ChromeOptions

option = ChromeOptions()
option.add_experimental_option('excludeSwitches', ['enable-automation'])
bro = webdriver.Chrome('chromedriver.exe', options=option)
```

补充上例：

```python
from selenium import webdriver

from selenium.webdriver import ChromeOptions

option = ChromeOptions()
option.add_experimental_option('excludeSwitches', ['enable-automation'])
bro = webdriver.Chrome('chromedriver.exe', options=option)

bro.get('https://www.taobao.com')
```



## 12306的模拟登录

地址为：`https://kyfw.12306.cn/otn/login/init`

- 核心： 验证码图片的截取、使用动作链



流程：

1. 获取登录页面，并截图
2. 定位img标签的位置和大小，用于对前面截到的图片进行裁剪得到验证码。
3. 通过打码平台确定需要点击的坐标，然后定义动作链，完成验证码校验
   - 对于验证码我使用打码平台 （超级鹰）
4. 填写用户名，密码，点击按钮即可

```python
from selenium import webdriver
from time import sleep
from PIL import Image  # 下载pil或者是pillow，完成对图片的裁剪

# 超级鹰部分
from ChaoJiYing import Chaojiying_Client


def get_code(img_path, ctype):
    chaojiying = Chaojiying_Client('用户名', '密码', '901824')  # 用户中心>>软件ID 生成一个替换 96001
    im = open(img_path, 'rb').read()
    return chaojiying.PostPic(im, ctype)['pic_str']  # 1902 验证码类型  官方网站>>价格体系 3.4+版 print 后要加()


bro = webdriver.Chrome('chromedriver.exe')
bro.get('https://kyfw.12306.cn/otn/login/init')
sleep(2)  # 这里需要睡眠，因为加载图片是需要时间的，不加后面的坐标就是0*0了。

# 截取登陆页面
bro.save_screenshot('./login.png')
# 定位img坐标
img_tag = bro.find_element_by_xpath('//*[@id="loginForm"]/div/ul[2]/li[4]/div/div/div[3]/img')
# 通过img坐标使用 Image 进行裁剪
location = img_tag.location  # 左下角坐标
# print(location)
size = img_tag.size  # img标签对应的图片的尺寸
# print(size)

# 得到的坐标转为列表  --->  [[x,y],[x,y]]
rangle = (location['x'], location['y'], location['x'] + size['width'], location['y'] + size['height'])
print(rangle)

# 从登录图片中截取出验证码图片
img = Image.open('./login.png')
code_img = img.crop(rangle)  # 接受左下角和右上角两个坐标  (x1,y1,x2,y2)    # 要么屏幕分辨率1280*720 要么显示设为100%
code_img.save('./code.png')

xy_str = get_code('./code.png', 9004)
print(xy_str)

xy_list = []
for xy in xy_str.split('|'):
    x, y = xy.split(',')
    xy_list.append((int(x), int(y)))

print(xy_list)

# 点击操作，需要动作链，偏移然后点击
action = webdriver.ActionChains(bro)
for xy in xy_list:
    print(xy)
    action.move_to_element_with_offset(img_tag, *xy).click().perform()

user = bro.find_element_by_xpath('//*[@id="username"]')
pw = bro.find_element_by_xpath('//*[@id="password"]')

user.send_keys('用户名')
pw.send_keys('密码')

btn = bro.find_element_by_xpath('//*[@id="loginSub"]')
btn.click()
```





## 总结

用到的方法

- webdriver.Chrome() 实例一个浏览器对象（驱动程序）
- get()：发送get请求
- find的系列的函数：用作标签定位
- send_keys(): 进行向标签中录入数据
- click()
- excute_script('j'): js注入
- page_sourse: 返回的是页面源码数据
- switch_to.frame(): 如何定位的标签是存在于嵌套页面中，需要定位前先切换到这个子页面中
- save_screenshot()：截图


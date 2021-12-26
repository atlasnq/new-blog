---
title: Python并发编程
date: 2019-05-21 15:07:07
tags: [python,并发编程,学习笔记]
categories: python学习
comments: true
urlname: python-concurrent-programming
copyright: true
---



{% cq %}本篇是对前两篇进程和线程的一个补充，加上协程也是对整个并发的一个补充。 {% endcq %}

<!--more-->



# 简单方便的“池”

## 进程池

```python
from concurrent.futures import ProcessPoolExecutor
import time
import random
import os
def task():
    print(f'{os.getpid()}准备接客')
    time.sleep(random.randint(1,3))

if __name__ == '__main__':
    p = ProcessPoolExecutor(max_workers=5) # 设置进程数量，默认为cpu的个数
    # 5个进程池接23个任务
    for i in range(23):
        p.submit(task)  # 给进程池放置任务，传参。
    p.shutdown(wait=True)
```

## 线程池

```python
from concurrent.futures import ThreadPoolExecutor
import time
import random
import os
def task():
    print(f'{os.getpid()}准备接客')
    time.sleep(random.randint(1,3))

if __name__ == '__main__':
    p = ThreadPoolExecutor(max_workers=5) # 设置线程程数量，默认为 = cpu的个数 乘以 5
    # 5个线程池接23个任务
    for i in range(23):
        p.submit(task)  # 给线程池放置任务，传参。
    p.shutdown(wait=True)
```

- 进程池与线程池属于鸭子类型，我们在使用的时候，只是类名不同（`ThreadPoolExecutor`与`ProcessPoolExecutor`）

1. 实例化对象，设置进程池和线程池的上限 `max_workers=`
2. 使用`submit`向池中投递任务。
3. 可以使用`shutdown`，它可以阻止在向进程池投放新的任务，设置wait = True，如果投放了23个任务，则总数为23.如果一个任务完成，总数减一，直至为0才执行下一行。（和join很像）



# 异步，同步、阻塞、非阻塞

## 阻塞、非阻塞

角度：**程序运行**中表现得状态： 阻塞，运行，就绪

阻塞：程序遇到I/O阻塞，程序遇到I/O立马会挂起，cpu马上切换，等到I/O结束之后，进入就绪状态。

非阻塞：程序没有I/O或者 遇到I/O通过某种手段，让cpu去执行其它的任务，尽可能的占用cpu。



## 异步，同步

站在**任务发布**的角度（start，submit）

同步（串行）：任务发出去之后，如果程序遇到I/O继续等待，直到这个任务最终结束之后，我在发布下一个任务。

异步：所有的任务同时发出，我就继续下一个

换句话说就是：同步就是**我强依赖你**(对方)，我必须等到你的回复，才能做出下一步响应。即我的操作(行程)是顺序执行的，中间少了哪一步都不可以，或者说中间哪一步出错都不可以，类似于编程中程序被解释器顺序执行一样；同时如果我没有收到你的回复，我就一直处于等待、也就是**阻塞的状态**。 异步则相反，我并不强依赖你，我对你响应的时间也不敏感，无论你返回还是不返回，我都能继续运行；你响应并返回了，我就继续做之前的事情，你没有响应，我就做其他的事情。也就是说我不存在等待对方的概念，我就是**非阻塞的**。

例子：

- 同步发布任务：我要发布10个任务，先把第一个任务给第一个进程，等到第一个进程完成，再将第二个任务给了下一个进程。。。

```python
# 同步：
from concurrent.futures import ProcessPoolExecutor
import time
import random
import os
def task():
    print(f'{os.getpid()}is running')
    time.sleep(random.randint(0,2))
    return f'{os.getpid()} finish'

if __name__ == '__main__':
    p = ProcessPoolExecutor(max_workers=4)
    obj_l1 = []
    for i in range(10):
        obj = p.submit(task,)   # 同步发布
        print(obj.result())     # 发一个就等结果。 
        # result是有阻塞的。
```



- 异步发布任务：我直接将10个任务抛给4个进程，我就继续执行下一行代码了，等结果。

```python
# 异步：
from concurrent.futures import ProcessPoolExecutor
import time
import random
import os
def task():
    print(f'{os.getpid()}is running')
    time.sleep(random.randint(0,2))
    return f'{os.getpid()} finish'

if __name__ == '__main__':
    p = ProcessPoolExecutor(max_workers=4)
    obj_l1 = []
    for i in range(10):
        obj = p.submit(task,)  # 异步发出。
        obj_l1.append(obj)

    # time.sleep(3)
    p.shutdown(wait=True)     # 和join很像
    # 1.阻止在向进程池投放新的任务，
    # 2. wait = True 10个任务是10，一个任务完成减一，直至为0才执行下一行。
    print(666)
    for i in obj_l1:
        # print(i)
        print(i.result())  # 阻塞到拿到返回值才停下
```

`shutdown（）`：

- 阻止在向进程池投放新的任务
- wait = True 10个任务是10，一个任务完成减一，直至为0才执行下一行。

上面异步，我们使用列表来统一回收结果，是异步回收结果的一种方式。



## 异步 + 调用机制

以爬虫为例：

浏览器做的事情很简单：

​	浏览器封装头部，发一个请求--->  www.taobao.com() --->  服务器获取到请求信息，分析正确  ----> 给你返回一个文件   ----->   浏览器将这个文件的代码渲染，就成了你看的样子。

爬虫：利用requests模块，模拟浏览器封装头，给服务器发送请求，骗过服务器之后，服务器也给你返回一个文件，爬虫拿到文件，进行数据清洗，获取到你想要的信息。

爬虫：两步，

​	第一步：爬取服务端的文件（I/O阻塞）

​	第二步：拿到文件，进行数据分析（非I/O，I/O极少）

理想状态：每个爬取的任务，耗费时间长；分析任务，耗时时间短。

本次例子中：

​	第一步：爬取服务端的文件

​	第二部：对第一步得到的字符串使用`len`简单统计字符个数来模拟数据分析的逻辑。



版本一：

```python
from concurrent.futures import ProcessPoolExecutor
import time
import random
import os

import requests
def get(url):
    response = requests.get(url)
    print(f'{os.getpid()} 正在爬取{url}')
    time.sleep(random.randint(1,3))
    if response.status_code == 200:
        return response.text

def parse(text):
    '''
    对爬取回来的字符串的分析
    简单用len模拟一下
    '''
    print(f'{os.getpid()}分析结果：{len(text)}')

if __name__ == '__main__':
    start_time =time.time()
    url_list = [
        'http://www.taobao.com','http://www.baidu.com','http://www.JD.com','https://atlasnq.github.io/','http://www.baidu.com',
        'http://www.sohu.com', 'http://www.youku.com', 'https://www.cnblogs.com/chennaqin/', 'https://atlasnq.github.io/',
        'http://www.sina.com'
    ]
    pool = ProcessPoolExecutor(4)
    # 方法一：  耗时：6.932577848434448
    obj_list = []
    for url in url_list:
        obj = pool.submit(get, url)
        obj_list.append(obj)
    pool.shutdown(wait=True)
    for obj in obj_list:     # 主程序是串行，分析结果的过程是串行
        parse(obj.result())
    print(f'耗时：{time.time() - start_time}')
```

版本一缺陷出现在哪里：

1. 分析结果是串行。
2. 结果有先有后，我们要做到，爬一个分析一个。 所有的结果全部都爬取成功之后，放在列表中，分析。



版本二：我们想把分析结果也做成并行

如何再开进程池，再开进程，耗费资源

这个版本，让4个进程，异步发出10个爬取网页 + 分析的任务，然后4个进程并发（并行）的先去完成4个爬取网页 + 分析的任务，谁先结束，谁进行下一个爬取 + 分析任务，直至10个任务爬取 + 分析的任务全部爬取成功。

```python
from concurrent.futures import ProcessPoolExecutor
import time
import random
import os

import requests
def get(url):
    response = requests.get(url)
    print(f'{os.getpid()} 正在爬取{url}')
    time.sleep(random.randint(1,3))
    if response.status_code == 200:
        parse(response.text)  # 增加耦合

def parse(text):
    '''
    对爬取回来的字符串的分析
    简单用len模拟一下
    '''
    print(f'{os.getpid()}分析结果：{len(text)}')

if __name__ == '__main__':
    start_time =time.time()
    url_list = [
        'http://www.taobao.com','http://www.baidu.com','http://www.JD.com','https://atlasnq.github.io/','http://www.baidu.com',
        'http://www.sohu.com', 'http://www.youku.com', 'https://www.cnblogs.com/chennaqin/', 'https://atlasnq.github.io/',
        'http://www.sina.com'
    ]
    pool = ProcessPoolExecutor(4)

    obj_list = []
    for url in url_list:
        obj = pool.submit(get, url)
        obj_list.append(obj)
    pool.shutdown(wait=True)
    print(f'耗时：{time.time() - start_time}')     # 耗时：6.248297452926636
```

缺陷：这个版本虽然效率提高了，但是两个任务有了耦合，我们增加了两个函数的耦合性。



版本三：对第二个版本进行解耦 （使用回调函数）

```python
from concurrent.futures import ProcessPoolExecutor
import time
import random
import os

import requests
def get(url):
    response = requests.get(url)
    print(f'{os.getpid()} 正在爬取{url}')
    time.sleep(random.randint(1,3))
    if response.status_code == 200:
        return response.text

def parse(obj):
    '''
    对爬取回来的字符串的分析
    简单用len模拟一下
    '''

    print(f'{os.getpid()}分析结果：{len(obj.result())}')

if __name__ == '__main__':
    start_time =time.time()
    url_list = [
        'http://www.taobao.com','http://www.baidu.com','http://www.JD.com','https://atlasnq.github.io/','http://www.baidu.com',
        'http://www.sohu.com', 'http://www.youku.com', 'https://www.cnblogs.com/chennaqin/', 'https://atlasnq.github.io/',
        'http://www.sina.com'
    ]
    pool = ProcessPoolExecutor(4)

    obj_list = []
    for url in url_list:
        obj = pool.submit(get, url)
        obj.add_done_callback(parse)  # 增加一个回调函数（方法），隐藏传参。
        # 现在的进程还是完成的网络爬取的任务，拿到了返回值之后，丢给回调函数，add_done_callback，
        # 进程继续完成下一个任务。
    pool.shutdown(wait=True)
    print(f'耗时：{time.time() - start_time}')     # 耗时：5.954453945159912
```

上述代码中：

- 使用回调函数帮助你分析结果，而且是由主进程帮助你实现的，回调函数帮你分析任务，明确了进程的任务：只有一个网络爬取。

- 分析任务：回调函数执行了，对函数之间解耦。
- 回调函数是串行的。

- 考虑极致情况：如果回调函数是I/O任务，那么由于你的回调函数是主进程做的，有可能影响效率。它是串行。

- 异步 + 回调机制不是万能的，如果你的回调的任务是I/O，那么异步 + 回调机制 不好，此时你要效率，只能牺牲开销，再开进程池和线程池。



有人说异步就是回调？ 其实它两不是一个概念，回调是基于异步的。 它两是两个概念。



# 事件

并发的执行某个任务，多个线程（进程），一个线程执行到中间时暂停通知另一个线程开始执行。

以前再没学习事件之前我们是用 `flag` 来解决的。

```python
import time
import os
from threading import Thread
from threading import current_thread
flag = False

def task():
    print(f'{current_thread().name}:检测服务器是否开启')
    time.sleep(3)
    global flag
    flag = True

def task1():
    while 1:
        print(f'{current_thread().name} 正在尝试连接')
        time.sleep(1)
        if flag:
           print('连接成功')
           return
if __name__ == '__main__':
    t1 = Thread(target=task1)
    t2 = Thread(target=task1)
    t3 = Thread(target=task1)

    t = Thread(target=task)

    t.start()
    t1.start()
    t2.start()
    t3.start()
```

使用Event类

```python
from threading import Event
import time
import os
from threading import Thread
from threading import current_thread
event = Event()    # 默认False

def task():
    print(f'{current_thread().name}:检测服务器是否开启')
    time.sleep(3)
    event.set()   # 改成了True

def task1():
    print(f'{current_thread().name} 正在尝试连接')
    event.wait()   # 轮询检测event是否为True，当其为True，继续下一行代码。
    event.wait(timeout=1)   # 设置超时事件，阻塞1s，改没改都会进行下一行。
    print(f'{current_thread().name} 连接成功！')

if __name__ == '__main__':
    t1 = Thread(target=task1)
    t2 = Thread(target=task1)
    t3 = Thread(target=task1)
    t = Thread(target=task)

    t.start()
    t1.start()
    t2.start()
    t3.start()
```







# 协程

是操作系统不可见的。
协程本质就是一条线程，多个任务在一条线程上来回切换
利用协程这个概念实现的内容 : 来规避IO操作,就达到了我们将一条线程中的io操作降到最低的目的。

设置非阻塞 sk.setblocking(Flase)



## `gevent`

利用了`greenlet`底层模块完成的切换 + 自动规避`io`的功能。

它是遇到IO后就报错，这样捕获到错误后，立马切换到下一个任务

```python
from gevent import monkey
monkey.patch_all()
import time
import gevent

def func():
    print('start func')
    time.sleep(1)
    print('end func')
g1 = gevent.spawn(func)
g2 = gevent.spawn(func)
g3 = gevent.spawn(func)
gevent.joinall([g1, g2, g3])
```



## `asyncio`

利用了`yield`底层语法完成的切换 + 自动规避`io`的功能

```python
import asyncio

async def func(name):
    print('start',name)
    # await 可能会发生阻塞的方法
    # await 关键字必须写在一个async函数里
    await asyncio.sleep(1)
    print('end')

loop = asyncio.get_event_loop()
loop.run_until_complete(asyncio.wait([func('小白'),func('小黑')]))
```

更多详见：





同步：

后一个任务的运行需要前一个任务的结果



同步非阻塞：

前一个任务正在执行的时候，这个任务也在执行

主任务在等待（进程），子任务在执行（线程）



非阻塞指的是下一个任务



异步阻塞



异步非阻塞



# io多路复用   ***

IO有两部分

- 网络传输（）
- 内核拷贝数据（无法省略的）



select的缺点：是轮询模式，会把所有对象挨个问一遍。

而不是采用回调，所以epoll更合适

epoll是绑定一个回调函数。



asyncio 牛批的地方在于IO的两个部分都可以省略



所以nginx采用epoll机制，这样才能高并发。





selector会根据操作系统，来选择最佳的IO多路复用机制。





# 小结

进程：数据隔离，数据不安全，操作系统级别，开销非常大，能利用多核。
线程：数据共享，数据不安全，操作系统级别，开销小，不能利用多核 ，一些和文件操作相关的io只有操作系统能感知到
协程：数据共享，数据安全，用户级别，开销更小，不能利用多核，协程的所有的切换都基于用户，只有在用户级别能够感知到的io才会用协程模块做切换来规避（socket，请求网页的）

用户级别的协程还有什么好处：

- 减轻了操作系统的负担。
- 一条线程如果开了多个协程，那么给操作系统的印象是线程很忙，这样能多争取一些时间片时间来被CPU执行,程序的效率就提高了。









-----


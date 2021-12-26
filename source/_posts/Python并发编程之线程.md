---
title: Python并发编程之线程
date: 2019-05-19 16:01:52
tags: [python,并发编程,学习笔记]
categories: python学习
comments: true
urlname: python-programming-with-threads
copyright: true
---



{% cq %}本节介绍Python并发编程下的线程，先介绍线程的相关知识，然后对python中threading模块进行介绍。 {% endcq %}

<!--more-->



## 线程的理论知识

### 动机

​	在多线程（multithreaded，MT）编程出现之前，计算机程序的执行是由单个步骤序列组成的，该序列在主机的 CPU 中按照同步顺序执行。无论是任务本身需要按照步骤顺序执行，还是整个程序实际上包含多个子任务，都需要按照这种顺序方式执行。那么，假如这些**子任务相互独立，没有因果关系**（也就是说，各个子任务的结果并不影响其他子任务的结果），这种做法是不是不符合逻辑呢？要是让这些**独立的任务同时运行**，会怎么样呢？很明显，这种并行处理方式可以显著地提高整个任务的性能。这就是多线程编程。 

​	多线程编程对于具有如下特点的编程任务而言是非常理想的：本质上是异步的；需要多个并发活动；每个活动的处理顺序可能是不确定的，或者说是随机的、不可预测的。这种编程任务可以被组织或划分成多个执行流，其中每个执行流都有一个指定要完成的任务。根据应用的不同，这些子任务可能需要计算出中间结果，然后合并为最终的输出结果。



### 什么是线程

线程（有时候称为轻量级进程）（线程就是一条流水线）是在同一个进程下执行的，并共享相同的上下文。

线程包括开始、执行顺序和结束三部分。它有一个指令指针，用于记录当前运行的上下文。当其他线程运行时，它可以被抢占（中断）和临时挂起（也称为睡眠）——这种做法叫做让步（yielding）。



### 什么是进程？进程开启经历了什么？

- 进程（有时称为重量级进程）是一个执行中的程序。

- 开启进程：内存中开空间，加载资源与数据，调用cpu执行，可能还会使用这个空间的资源。
  - 进程：划分空间，加载资源。  （进程是没有执行力的）（静态的）
  - 线程：执行代码。（动态地）
  - 例如：开启qq：开启一个进程（在内存中开辟空间，加载数据），启动一个线程执行代码。

​	线程是依赖于进程的，一个进程中的各个线程与主线程共享同一片数据空间。线程一般是以并发方式执行的，正是由于这种并行和数据共享机制，使得多任务间的协作成为可能。

​	当然，这种共享并不是没有风险的。如果两个或多个线程访问同一片数据，由于数据访问顺序不同，可能导致结果不一致。这种情况通常称为**竞态条件**（race condition）。幸运的是，大多数线程库都有一些**同步原语**，以允许线程管理器控制执行和访问。



### 线程vs进程（理论）

1. 开启多进程，开销非常大；10-100倍，开启线程开销非常小。

2. 开启多进程的速度慢，开启多线程的速度快

3. 进程之间的数据不能直接共享，通信通过队列；同一个进程下的线程之间的数据可以共享。

   

### 多线程的应用场景介绍

并发：一个cpu来回切换（在线程上切换的），包括多进程的并发和多线程的并发。

多进程并发：开启多个进程，每个进程里面的主线程执行任务。

多线程并发：开启1个进程，此进程里面多个线程执行任务。

多进程多线程：（ 待补充！！！）



### 什么时候用多进程，什么时候用多线程？

一个程序：三个不同的任务。word中写文章

键盘输入，显示在屏幕上，自动保存。   ——多线程！！！ 

**I/O 密集型**的 Python 程序要比计算密集型的代码能够更好地利用多线程环境。



## 在Python中使用线程



### 开启线程的两种方式

```python
# 第一种方式
from threading import Thread
def task(name):
    print(f'{name}is running')

if __name__ == '__main__':
    t = Thread(target=task,args=('小白',))
    t.start()
    print('主线程')  # 主线程与非主线程本来没有主子线程的说法，它们是平等的

# 第二种方式
from threading import Thread

class MyThread(Thread):
    def run(self):
        print(f'{self.name}is running')

if __name__ == '__main__':
    t = MyThread(name='小白')
    t.start()
    print('主线程')
```



### 线程与进程之间的对比（验证理论）



#### 速度的对比

不像进程那样，它的速度很快

#### pid：

```python
from threading import Thread
import os
def task():
    print(f'子线程：{os.getpid()}')

if __name__ == '__main__':
    t = Thread(target=task,args=())
    t.start()
    print(f'主线程：{os.getpid()}') 
```

结论：它们在同一个进程。



#### 线程之间共享资源

```python
from threading import  Thread
x = 1000

def task():
    global x
    x = 0
if __name__ == '__main__':
    t = Thread(target=task)
    t.start()
    t.join()
    print(f'主进程: {x}')
# 有I/O才能提高效率，否则都不如以前的串行
```



### 线程的其他方法

```python
from threading import Thread
import threading
import time
def task(name):
    print(f'{name} is running ')
    print(threading.current_thread().name)

if __name__ == '__main__':
    t = Thread(target=task, args=('小白',),name = '线程1')
    t.start()
    # 编程对象的方法
    # print(t.is_alive())     # 判断子线程是否存活
    # print(t.getName())      # 获取线程名
    # t.setName('线程1111')
    # print(t.getName())  # 获取线程名
    
    # threading模块的方法
    # print(threading.current_thread().name)  # 获取当前线程名
    print(threading.enumerate())        # 返回一个列表，放置所有的线程对象
    print(threading.active_count())     # len()上面就可以得到下面这个。 获取活跃的线程数量，包括主线程。
    print("主线程")
```



### threading模块的对象与函数

| threading模块的对象与函数 | 描述                                                         |
| ------------------------- | :----------------------------------------------------------- |
| **对象**                  |                                                              |
| Thread                    | 表示一个执行线程的对象                                       |
| Lock                      | 锁原语对象（和 thread 模块中的锁一样）                       |
| RLock                     | 可重入锁对象，使单一线程可以（再次）获得已持有的锁（递归锁） |
| Condition                 | 条件变量对象，使得一个线程等待另一个线程满足特定的“条件”，比如改变状态或某个数据值 |
| Event                     | 条件变量的通用版本，任意数量的线程等待某个事件的发生，在该事件发生后所有线程将被激活 |
| Semaphore                 | 为线程间共享的有限资源提供了一个“计数器”，如果没有可用资源时会被阻塞 |
| BoundedSemaphore          | 与 Semaphore 相似，不过它不允许超过初始值                    |
| Timer                     | 与 Thread 相似，不过它要在运行前等待一段时间                 |
| barrier                   | 创建一个“障碍”，必须达到指定数量的线程后才可以继续           |
| **函数**                  |                                                              |
| `active_count()`          | 当前活动的 Thread 对象个数                                   |
| `current_thread`          | 返回当前的 Thread 对象                                       |
| `enumerate()`             | 返回当前活动的 Thread 对象列表                               |
| `settrace (*func*)`       | 为所有线程设置一个 trace 函数                                |
| `setprofile *(func*)`     | 为所有线程设置一个 profile 函数                              |
| stack_size (*size*=0)     | 返回新创建线程的栈大小；或为后续创建的线程设定栈的大小为size |

### Thread类

| 属性与方法                                                   | 描 述                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Thread对象数据属性**                                       |                                                              |
| name                                                         | 线程名                                                       |
| ident                                                        | 线程的标识符                                                 |
| daemon                                                       | 布尔标志，表示这个线程是否是守护线程                         |
| **Thread 对象方法**                                          |                                                              |
| `_init_(group=None, *tatget*=None, *name*=None, *args*=(),  kwargs* ={}, *verbose*=None, *daemon*=None)` | 实例化一个线程对象，需要有一个可调用的 *target*，以及其参数 *args*或 *kwargs*。还可以传递 *name* 或 *group* 参数，不过后者还未实现。此外 ， *verbose* 标志也是可接受的。而 *daemon* 的值将会设定 *thread.daemon* 属性/标志 |
| `start()`                                                    | 开始执行该线程                                               |
| `run()`                                                      | 定义线程功能的方法（通常在子类中被应用开发者重写）           |
| `join(timeout=None)`                                         | 直至启动的线程终止之前一直挂起；除非给出了 *timeout*（秒），否则会一直阻塞 |
| `getName()`                                                  | 返回线程名                                                   |
| `setName()`                                                  | 设定线程名                                                   |
| `is_alive()`                                                 | 布尔标志，表示这个线程是否还存活                             |
| `isDaemon()`                                                 | 如果是守护线程，则返回 True；否则，返回 False                |





### 守护线程

注意和守护线程区分：主进程/主线程 什么时候结束

```python
# 回顾守护进程
from multiprocessing import Process
import time
def foo():
    print(123)  # 进程启动慢，还没来得及打印123，主进程就已经执行完了。
    time.sleep(1)
    print('end123')

def bar():
    print(456)
    time.sleep(3)
    print("end456")

if __name__ == '__main__':
    f = Process(target=foo)
    b = Process(target=bar)
    f.daemon = True
    f.start()
    b.start()
    print('main-------')  # 进程启动慢
```



守护线程：

```python
from threading import Thread
import time
def foo():
    print(123)
    time.sleep(1)

if __name__ == '__main__':
    f = Thread(target=foo)
    f.daemon = True
    f.start()
    print("主线程")

from threading import Thread
import time
def foo():
    print(123)
    time.sleep(1)
    print('end123')

def bar():
    print(456)
    time.sleep(3)
    print("end456")

if __name__ == '__main__':
    f = Thread(target=foo)
    b = Thread(target=bar)
    f.daemon = True
    f.start()
    b.start()
    print("主线程---") # 主进程的主流水线，主进程中，相当于主流水线over，主进程结束，所以守护它的子进程也要结束。
```

- 守护：子守护主，只要主结束，子马上结束。

- **如果把一个线程设置为守护线程，就表示这个线程是不重要的，进程退出时不需要等待这个线程执行完成。**

- 主线程什么时候结束？？？（进程和线程的守护的根本上的一个差别）

  - 主线程是进程存活在内存中的一个必要条件。
  - 主线程将在所有非守护线程退出之后才退出，换句话说，就是没有剩下存活的非守护线程时就退出。

- 结论：守护线程，必须等待所有的非守护线程以及主线程结束之后才能结束。

  

```python
# 验证
from threading import Thread
import time
def foo():
    print(123)
    time.sleep(3)
    print('end123')

def bar():
    print(456)
    time.sleep(1)
    print("end456")

if __name__ == '__main__':
    f = Thread(target=foo)
    b = Thread(target=bar)
    f.daemon = True
    f.start()
    b.start()
    print("主线程---")  # 主进程的主流水线，主进程中，相当于主流水线over，主进程结束，所以守护它的子进程也要结束。
```

- 当把守护进程的时间增加时，它得等主线程结束和其它非守护进程结束。
- 主线程又在等其它非守护进程的结束。所以，守护进程没有打印end123就被终止了。



## 线程同步（同步原语）

​	一般在多线程代码中，总会有一些特定的函数或代码块不希望（或不应该）被多个线程同时执行，通常包括修改数据库、更新文件或其他会产生**竞态条件**的类似情况。

​	当任意数量的线程可以访问临界区的代码）但在给定的时刻只有一个线程可以通过时，就是使用同步的时候了。程序员选择适合的同步原语，或者线程控制机制来执行同步。

​	两个重要的**同步原语** ：**互斥锁**与**信号量**。

​	锁是所有机制中最简单、最低级的机制，而信号量用于多线程竞争有限资源的情况。锁比较容易理解，因此先从锁开始，然后再讨论信号量。

> 什么是竞态条件？
>
> 当两个线程竞争同一资源时，如果对资源的访问顺序敏感，就称存在竞态条件。  
>
> 导致竞态条件发生的代码区称作**临界区**。  
>
> 在临界区中使用适当的同步就可以避免竞态条件。  



### 互斥锁

互斥锁，锁，同步锁都是一把锁。

如果没有锁会出现：

```python
from threading import Thread
from threading import Lock
import time

x = 100
def task():
    global x
    # print(x)
    temp = x
    time.sleep(1)
    temp -= 1
    x = temp

if __name__ == '__main__':
    t_l = []
    for i in range(100):
        t = Thread(target=task)
        t.start()
        t_l.append(t)
    for i in t_l:           # 主线程等待所有线程都结束。
        i.join()
    print(f'主线程程{x}')    # 主线程程99
```

使用锁的话，才能达到要求。

​	当多线程争夺锁时，允许第一个获得锁的线程进入**临界区**，并执行代码。所有之后到达的线程将被**阻塞**，直到第一个线程执行结束，退出临界区，并释放锁。此时，其他等待的线程可以获得锁并进入临界区。不过请记住，<u>那些被阻塞的线程是没有顺序的（即不是先到先执行），胜出线程的选择是不确定的，而且还会根据 Python 实现的不同而有所区别。</u>

```python
from threading import Thread
from threading import Lock
import time

x = 100
def task(lock):
    global x
    # print(x)   # print放在上面就会出现进程当时演示的效果。cpu会切换过来
    lock.acquire()
    # lock.acquire()   # 非递归锁，多一次就阻塞了,即使release也一样
    # global x    # global只是声明，放前放后都一样，真正动态可变的是x
    print(x)
    temp = x
    # time.sleep(0.1)
    temp -= 1
    x = temp
    lock.release()
    # lock.release()
'''
第一个线程：x = 100， 剩下的线程拿到的都是x
第一个线程执行完毕： x = 99
第二个线程：x = 99，剩下的
'''
if __name__ == '__main__':
    lock = Lock()
    t_l = []
    for i in range(100):
        t = Thread(target=task, args=(lock,))
        t.start()
        t_l.append(t)
    for i in t_l:
        i.join()
    print(f'主线程:{x}') 		# 主线程:0
```

互斥锁与join区别？

- 异：互斥锁 随机抢锁，公平；join 提前排好顺序，不公平
- 同：它们都是串行。



#### 使用上下文管理

如果你使用 Python 2.5 或更新版本，还有一种方案可以不再调用锁的 acquire()和 release() 

方法，从而更进一步简化代码。这就是使用 with 语句，此时每个对象的上下文管理器负责在 

进入该套件之前调用 acquire()并在完成执行之后调用 release()。

threading 模块的对象 Lock、RLock、Condition、Semaphore 和 BoundedSemaphore 都包含 

上下文管理器。

```python
# 使用上下文管理 方法1
from threading import Thread
from threading import Lock
import time

x = 100
def task(lock):
    with lock:
        global x
        print(x)
        temp = x
        temp -= 1
        x = temp

if __name__ == '__main__':
    lock = Lock()
    t_l = []
    for i in range(100):
        t = Thread(target=task, args=(lock,))
        t.start()
        t_l.append(t)
    for i in t_l:
        i.join()
    print(f'主线程:{x}') 		# 主线程:0
```

再次精简一下：

```python
from threading import Thread
from threading import Lock

x = 100
def task():
    global x
    print(x)
    temp = x
    temp -= 1
    x = temp

if __name__ == '__main__':
    lock = Lock()
    t_l = []
    for i in range(100):
        t = Thread(target=task,)
        with lock:
            t.start()
            t_l.append(t)
    print(f'主线程:{x}') 		
```



### 死锁现象，递归锁

```python
from threading import Thread
from threading import RLock
import time

lock_A = lock_B = RLock()  # 获得一把递归锁

class MyThread(Thread):
    def run(self):
        self.f1()
        self.f2()

    def f1(self):
        lock_A.acquire()
        print(f'{self.name}拿到A锁')

        lock_B.acquire()
        print(f'{self.name}拿到B锁')
        lock_B.release()

        lock_A.release()

    def f2(self):
        lock_B.acquire()
        print(f'{self.name}拿到A锁')
        time.sleep(1)
        lock_A.acquire()
        print(f'{self.name}拿到B锁')
        lock_A.release()
        lock_B.release()
        
if __name__ == '__main__':
    t1 = MyThread()
    t1.start()
    t2 = MyThread()
    t2.start()
    t3 = MyThread()
    t3.start()
    print('主线程')
```

- 使用递归锁去解决死锁问题。
- 递归锁是一把锁。锁上有记录，只要acquire一次，锁上计数一次，acquire两次，计数两次。 release一次，计数减一。只要递归锁计数不为0，其它线程不能抢。
- 从两把锁变成一把锁，根本上是为了执行这个程序，要给它所有可用的资源。



### 信号量

​	信号量是最古老的同步原语之一。它是一个**计数器**，当资源消耗时递减，当资源释放时递增。你可以认为信号量代表它们的资源可用或不可用。**消耗资源使计数器递减的操作习惯上称为 P()**（来源于荷兰单词 probeer/proberen），也称为 wait、try、acquire、pend 或 procure。 

​	相对地，当一个线程对一个资源完成操作时，**该资源需要返回资源池中。这个操作一般称为 V()**（来源于荷兰单词 verhogen/verhoog），也称为 signal、increment、release、post、vacate。

​	Python 简化了所有的命名，使用和锁的函数/方法一样的名字：acquire 和 release。信号量比锁更加灵活，因为可以有多个线程，每个线程拥有有限资源的一个实例。

```python
from threading import Thread,Semaphore,current_thread
import time
import random
sm = Semaphore(4)
# 同一时刻允许4个进入

def go_public_wc():
    sm.acquire()
    time.sleep(random.randint(1,3))
    print(f'{current_thread().name}正在厕所')
    # print(f'{current_thread().name}over')
    sm.release()

if __name__ == '__main__':
    for i in range(20):
        t = Thread(target=go_public_wc)
        t.start()
```



## threading.local

- 会先检查是哪个线程，为每一个线程开辟独立得空间，进行存取！

```python
'''
import threading
import time

class Foo(object):
    def __init__(self):
        self.val = -1

obj = Foo()

def task(arg):
    obj.val = arg
    time.sleep(0.5)
    # 线程之间用的同一块内存
    print(obj.val)  


for i in range(10):
    t = threading.Thread(target=task, args=(i,))
    t.start()

'''
import threading
import time

obj = threading.local()

def task(arg):
    obj.val = arg
    # 为每一个线程开辟空间，存放数据，实现了线程之间的数据隔离
    time.sleep(0.5)    
    # 去当前线程自己的内存中获取数据
    print(obj.val)


for i in range(10):
    t = threading.Thread(target=task, args=(i,))
    t.start()
```



# 线程Queue

在线程中我们使用queue模块，这里面我们使用到栈、队列和优先级队列

## 队列 FIFO

```python
import queue

q = queue.Queue(3)
q.put(1)
q.put(2)
q.put(3)
q.put(666)  # 超过上限默认进入阻塞
print(q.get())
print(q.get())
print(q.get())
```



## 栈 LIFO

```python
import queue
q = queue.LifoQueue()
q.put(1)
q.put(2)
q.put(3)
print(q.get())
print(q.get())
print(q.get())
```



## 优先级队列

```python
import queue
q = queue.PriorityQueue(3)
q.put((10,'垃圾消息'))     # 需要元组的形式（priority number, data)， 数字越小，优先级越高。
q.put((-10,'紧急消息'))
q.put((3,'一般消息'))
print(q.get())
print(q.get())
print(q.get())    # 越小的，越重要
```





----


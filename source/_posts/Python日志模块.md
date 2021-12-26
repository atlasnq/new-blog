---
title: Python日志模块
date: 2019-04-5 22:45:40
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-logging-module
copyright: true
---



{% cq %}首先介绍日志，接着介绍三个版本的logging日志，推荐旗舰版本，直接套用就可以。 {% endcq %}

<!--more-->

-----------



## logging日志

- 工作日志分四个大类
  1. 系统日志：记录服务器的一些重要信息（监控系统，cpu温度，网卡流量，重要硬件的一些指标。运维人员经常使用的，记录操作的一些指令）
  2. 网站日志：访问异常，卡顿，网站的一些板块的受欢迎程度，访问量，点击率等等。蜘蛛爬取的次数。
  3. 辅助开发日志：开发人员在开发项目中，利用日志进行排错，排除一些避免不了的错误（记录），辅助开发。
  4. 记录用户信息日志：用户的消费习惯，新闻偏好，等等（数据库解决）。
- 日志：是谁使用的？一般都是开发者使用的。



## low版（简易版）

1. 缺点：文件和屏幕只能选择一个输出。

2. 优点：比print，open，write快的多。

   ```
   import logging
   
   # logging.basicConfig(level=logging.DEBUG)
   logging.basicConfig(
       level=10,
   format = '%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
   filename=r'test.log',
   filemode='a'
   )
   
   logging.debug('debug message')            # 10
   logging.info('info message')  # 正常信息  # 20
   logging.warning('warning message')        # 30
   logging.error('error message')            # 40
   logging.critical('critical message')      # 50
   ```

   

## 标配版（标准版）

1. 增加了屏幕和文件同时输出。

   ```
   import logging
   
   # 创建一个logging对象
   logger = logging.getLogger()
   # 创建一个文件对象
   fh = logging.FileHandler('标配版.log',encoding='utf-8')
   # 创建一个屏幕对象
   sh = logging.StreamHandler()
   
   # 配置显示格式
   formatter = logging.Formatter('%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s')
   formatter2 = logging.Formatter('[line:%(lineno)d] %(message)s')
   # 绑定
   fh.setFormatter(formatter)
   sh.setFormatter(formatter2)
   
   logger.addHandler(fh)
   logger.addHandler(sh)
   
   # 先设置总开关
   logger.setLevel(30) # 默认设置为10
   # 如果默认设置为30 则，下面分别设置的如果低于30则仍然不会输出。
   
   # 分别设置
   fh.setLevel(10)
   sh.setLevel(40)
   
   logging.debug('debug message')            # 10
   logging.info('info message')  # 正常信息   # 20
   logging.warning('warning message')        # 30
   logging.error('error message')            # 40
   logging.critical('critical message')      # 50
   ```

   

### 旗舰版（项目中使用的，Django项目） 

1. 优点：自定制日志(通过字典的方式)（前两个是系统固定的）
2. 轮转日志：按内存，按时间
3. 可以同时输出多个文件。

```
"""
logging配置
"""

import logging.config
# 注意 这里的logging.config 与 直接用logging.config.xxx 不同

# 定义三种日志输出格式 开始

standard_format = '[%(asctime)s][%(threadName)s:%(thread)d][task_id:%(name)s][%(filename)s:%(lineno)d]' \
                  '[%(levelname)s][%(message)s]' #其中name为getlogger指定的名字
simple_format = '[%(levelname)s][%(asctime)s][%(filename)s:%(lineno)d]%(message)s'

# 定义日志输出格式 结束

logfile_path = r'C:\Users\ATLAS\PycharmProjects\oldboy23期\day19\日志模块\旗舰版日志文件夹\log1.log'  # log文件的目录
logfile_name = 'log1.log'  # log文件名


# log配置字典 （6个键值对）
# LOGGING_DIC 第一层所有的键不能改变
LOGGING_DIC = {
    'version': 1,  # 版本号
    'disable_existing_loggers': False,   # 固定写法
    'formatters': {
        'standard': {
            'format': standard_format
        },
        'simple': {
            'format': simple_format
        },
    },
    'filters': {},  # 后面补充
    'handlers': {
        #打印到终端的日志
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',  # 打印到屏幕
            'formatter': 'simple'
        },
        #打印到文件的日志,收集info及以上的日志
        'default': {
            'level': 'DEBUG',
            'class': 'logging.handlers.RotatingFileHandler',  # 保存到文件
            'formatter': 'standard',
            'filename': logfile_path,  # 日志文件
            'maxBytes': 1024*1024*5,  # 日志大小 5M
            'backupCount': 5,
            'encoding': 'utf-8',  # 日志文件的编码，再也不用担心中文log乱码了
        },
    },
    'loggers': {
        #logging.getLogger(__name__)拿到的logger配置
        '': {
            'handlers': ['default', 'console'],  # 这里把上面定义的两个handler都加上，即log数据既写入文件又打印到屏幕
            'level': 'DEBUG',
            'propagate': True,  # 向上（更高level的logger）传递
        },
    },
}



def md_logger(a):
	# 1.从字典加载配置
    logging.config.dictConfig(LOGGING_DIC)  # 导入上面定义的logging配置
    # 2.拿到logger对象来产生日志
    logger = logging.getLogger(a)  # 生成一个log实例    #task_id:%(name)s
    # return logger
    logger.debug('xxx登录了')  # 记录该文件的运行状态

def login():
    print('登陆成功')
    md_logger('登录日志')   # task_id


login()
```


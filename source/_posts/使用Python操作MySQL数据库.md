---
title: 使用Python操作MySQL数据库
date: 2019-05-28 14:09:15
tags: [MySQL,数据库,python,学习笔记]
categories: [MySQL学习]
comments: true
urlname:  Python_MySQL
copyright: true
---



{% cq %}本篇为使用python连接并操作MySQL数据库，涉及PyMySql模块。 {% endcq %}

<!--more-->

# 安装`PyMySql`模块

## 方法一：

`pip3 install pymsql`

## 方法二：

点击`pycharm/settings/Project Iterpreter`右侧的加号，搜索`pymysql`然后点击 `Install Package`



# `PyMySql`模块

## 简介

[PyMySQL](https://github.com/PyMySQL/PyMySQL) 是一个纯 Python 实现的 MySQL 客户端操作库，支持事务、存储过程、批量执行等。

## 基本使用

### 连接MySQL

```python
conn = pymysql.Connection(host='127.0.0.1', user='root',password='2296',database ='test',charset='utf8')
```

### 获取游标

```python
cursor = connection.cursor()
```



### 执行SQL

```python
cursor.execute(sql, args) 执行单条 SQL
cursor.executemany(sql, args) 批量执行 SQL
```



补充：

1. INSERT、UPDATE、DELETE 等修改数据的语句需手动执行`connection.commit()`完成对数据修改的提交。
2. 对于大段文字（包含单引号、双引号等特殊符号），我们将它放在`args` 中，而不是直接手动拼接在SQL语句中。



简单的一个例子：

```python
import pymysql

conn = pymysql.Connection(host='127.0.0.1', user='root',password='2296',database ='test',charset='utf8')
cur = conn.cursor()   # 游标  数据库操作符
# sql = 'select %s,%s from employee'      # 只有值能拼接,不能拼字段名
sql = 'select emp_name,salary from employee'      # 只有值能拼接,不能拼字段名
# cur.execute(sql,('emp_name','salary'))
cur.execute(sql)
ret1 = cur.fetchone()
ret2 = cur.fetchmany(2)
ret3 = cur.fetchall()
print(ret1)
print(ret2)
print(ret3)
# 插入

sql = 'insert into employee(id, emp_name, sex, age, hire_date) values(%s,%s,%s,%s,%s )'
cur.execute(sql,(20,'小小','male',88,20181218))   # 传可迭代对象
conn.commit()    # 只要修改就得用它，不然保存不到硬盘上
cur.close()
conn.close()
```



## 创建表

```python
import pymysql
 
# 打开数据库连接
db = pymysql.connect(host="localhost",user="testuser",password="pw",database ='test',charset='utf8')
 
# 使用 cursor() 方法创建一个游标对象 cursor
cursor = db.cursor()
 
# 使用 execute() 方法执行 SQL，如果表存在则删除
cursor.execute("DROP TABLE IF EXISTS EMPLOYEE")
 
# 使用预处理语句创建表
sql = """CREATE TABLE EMPLOYEE (
         FIRST_NAME  CHAR(20) NOT NULL,
         LAST_NAME  CHAR(20),
         AGE INT,  
         SEX CHAR(1),
         INCOME FLOAT )"""
 
cursor.execute(sql)
 
# 关闭数据库连接
db.close()
```



## 操作数据

### 插入

```python
import pymysql
 
# 打开数据库连接
db = pymysql.connect(host="localhost",user="testuser",password="pw",database ='test',charset='utf8')
 
 
# 使用cursor()方法获取操作游标 
cursor = db.cursor()
 
# SQL 插入语句
sql = """INSERT INTO EMPLOYEE(FIRST_NAME,
         LAST_NAME, AGE, SEX, INCOME)
         VALUES (%s, %s, %s, %s, %s)"""
try:
   # 执行sql语句
   cursor.execute(sql,('Mac', 'Mohan', 20, 'M', 2000))
   # 提交到数据库执行
   db.commit()
except:
   # 如果发生错误则回滚
   db.rollback()
 
# 关闭数据库连接
db.close()
```

建议：将变量传给 `args` ，而不是手动拼接！

### 查询

```python
# 执行查询 SQL
cursor.execute('SELECT * FROM tables')

# 获取单条数据
cursor.fetchone()

# 获取前N条数据
cursor.fetchmany(3)

# 获取所有数据
cursor.fetchall()

# 这是一个只读属性，并返回执行execute()方法后影响的行数。
rowcount
```



### 更新

```python
import pymysql
 
# 打开数据库连接
db = pymysql.connect(host="localhost",user="testuser",password="pw",database ='test',charset='utf8')
 
# 使用cursor()方法获取操作游标 
cursor = db.cursor()
 
# SQL 更新语句
sql = "UPDATE EMPLOYEE SET AGE = AGE + 1 WHERE SEX = '%c'" % ('M')
try:
   # 执行SQL语句
   cursor.execute(sql)
   # 提交到数据库执行
   db.commit()
except:
   # 发生错误时回滚
   db.rollback()
 
# 关闭数据库连接
db.close()
```



### 删除

```python
import pymysql
 
# 打开数据库连接
db = pymysql.connect(host="localhost",user="testuser",password="pw",database ='test',charset='utf8')
 
# 使用cursor()方法获取操作游标 
cursor = db.cursor()
 
# SQL 删除语句
sql = "DELETE FROM EMPLOYEE WHERE AGE > %s" % (20)
try:
   # 执行SQL语句
   cursor.execute(sql)
   # 提交修改
   db.commit()
except:
   # 发生错误时回滚
   db.rollback()
 
# 关闭连接
db.close()
```



## 执行事务

事务具有4个属性：原子性、一致性、隔离性、持久性。这四个属性通常称为ACID特性。

- 原子性（atomicity）。一个事务是一个不可分割的工作单位，事务中包括的诸操作要么都做，要么都不做。
- 一致性（consistency）。事务必须是使数据库从一个一致性状态变到另一个一致性状态。一致性与原子性是密切相关的。
- 隔离性（isolation）。一个事务的执行不能被其他事务干扰。即一个事务内部的操作及使用的数据对并发的其他事务是隔离的，并发执行的各个事务之间不能互相干扰。
- 持久性（durability）。持续性也称永久性（permanence），指一个事务一旦提交，它对数据库中数据的改变就应该是永久性的。接下来的其他操作或故障不应该对其有任何影响。



```python
# 删除年龄大于20的人
sql = "DELETE FROM EMPLOYEE WHERE AGE > %s" % (20)
try:
   # 执行SQL语句
   cursor.execute(sql)
   # 向数据库提交
   db.commit()
except:
   # 发生错误时回滚
   db.rollback()
```



## SQLhelper

- 将原生sql封装起来

```python
import pymysql

from DBUtils.PooledDB import PooledDB

class SQLHelper(object):
    def __init__(self):
        # 创建数据库连接池
        self.pool = PooledDB(
            creator=pymysql,
            maxconnections=5,
            mincached=2,
            blocking=True,
            host='127.0.0.1',
            port=3306,
            user='root',
            password='123',
            database='s23day02',
            charset='utf8'
        )


    def connect(self):
        conn = self.pool.connection()
        cursor = conn.cursor()
        return conn,cursor


    def disconnect(self,conn,cursor):
        cursor.close()
        conn.close()


    def fetchone(self,sql,params=None):
        """
        获取单条
        :param sql:
        :param params:
        :return:
        """
        if not params:
            params = []
        conn,cursor = self.connect()
        cursor.execute(sql, params)
        result = cursor.fetchone()
        self.disconnect(conn,cursor)
        return result


    def fetchall(self,sql,params=None):
        """
        获取所有
        :param sql:
        :param params:
        :return:
        """
        import pymysql
        if not params:
            params = []
        conn, cursor = self.connect()
        cursor.execute(sql,params)
        result = cursor.fetchall()
        self.disconnect(conn, cursor)
        return result


    def commit(self,sql,params):
        """
        增删改
        :param sql:
        :param params:
        :return:
        """
        import pymysql
        if not params:
            params = []

        conn, cursor = self.connect()
        cursor.execute(sql, params)
        conn.commit()
        self.disconnect(conn, cursor)


db = SQLHelper()
```


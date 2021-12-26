---
title: MySQL-索引
date: 2019-05-28 20:57:42
tags: [MySQL,数据库,学习笔记]
categories: MySQL学习
comments: true
urlname:  MySQL_index
copyright: true
---



{% cq %}本篇介绍MySQL数据库的索引以及对前文进行补充，深化。 {% endcq %}

<!--more-->



- 索引是帮助MySQL高效获得数据的**数据结构**

- 可以用来快速查询数据库表中的特定记录。索引是提高数据库性能的重要方式。MySQL中，所有的数据类型都可以被索引。MySQL的索引包括普通索引、惟一性索引、全文索引、单列索引、多列索引和空间索引等。



# 索引概述

## 什么是索引

- 索引是模式(schema)中的一个**数据库对象**，在数据库中用来加速对表的**查询**，它是帮助MySQL高效获得数据的**数据结构**。

- 数据本身之外，数据库还维护着一个满足特定查找算法的数据结构，这些数据结构以某种方式指向数据，这样就可以在数据结构的基础上实现**高级查找算法**，这种数据结构就是索引。

- 通过使用快速路径访问方法快速定位数据,减少了磁盘的I/O 

- 与表独立存放，但不能独立存在，必须属于某个表 

- 由数据库自动维护，表被删除时，该表上的索引自动被删除。 

- 索引的作用类似于书的目录，几乎没有一本书没有目录，因 此几乎没有一张表没有索引。

  

## 索引优缺点 

- 索引的优点是可以**提高检索数据的速度**，这是创建索引的最主要的原因；对于有依赖关系的**子表**和**父表**之间的联合查询时，可以提高查询速度；使用分组和排序子句进行数据查询时，同样可以显著节省查询中**分组**和**排序**的时间。 

- 索引的缺点是**创建和维护索引需要耗费时间**，耗费时间的数量随着数据量的增加而增加；索引需要占用物理空间，每一个索引要占一定的物理空间；增加、删除和修改数据时，要动态的维护索引，造成数据的维护速度降低了。





## 索引分类 

- MySQL的索引包括普通索引、惟一性索引、全文索引、单列索引、多列索引和空间索引等。



## 索引的设计原则

1．选择惟一性索引 

2．为经常需要排序、分组和联合操作的字段建立索引 

3．为常作为查询条件的字段建立索引 

4．限制索引的数目 

5．尽量使用数据量少的索引 

6．尽量使用前缀来索引 

7．删除不再使用或者很少使用的索引



# 创建索引 

创建索引是指在某个表的一列或多列上建立一个索引，以便提高对表的访问速度。创建索引有三种方式，这三种方式分别是创建表的时候创建索引、在已经存在的表上创建索引和使用`ALTER TABLE`语句来创建索引。



## 创建表的时候创建索引 

```mysql
CREATE TABLE 表名 ( 属性名 数据类型 [完整性约束 条件],  
                 属性名 数据类型 [完整性约束条件],  
                 …  
                 属性名 数据类型  
                 [UNIQUE | FULLTEXT | SPATIAL] INDEX | KEY  
                 [别名](属性名1 [(长度)] [ASC | DESC]) );
```



### 普通索引

```mysql
CREATE TABLE t1( 
	ID int,
    Name varchar(20),
    Sex enum('男','女'),
    Index(ID)
);
show create table t1;
explain select * from t1 where id = 1;
```

结果如下：

| id   | select_type | table | type | possible_keys | key  | key_len | ref   | rows | Extra |
| ---- | ----------- | ----- | ---- | ------------- | ---- | ------- | ----- | ---- | ----- |
| 1    | SIMPLE      | t1    | ref  | ID            | ID   | 5       | const | 1    | NULL  |

### 唯一性索引

```mysql
create table t2(
	ID int ,
    Name varchar(20),
    Unique index t2_id(ID asc)
);
```

疑问：为什么使用explain后发现没有命中索引呢？

```mysql
explain select * from t2 where id = 1;
```

结果如下：

| id   | select_type | table | type | p_k  | key  | key_len | ref  | rows | Extra                                                   |
| ---- | ----------- | ----- | ---- | ---- | ---- | ------- | ---- | ---- | ------------------------------------------------------- |
| 1    | SIMPLE      | NULL  | NULL | NULL | NULL | NULL    | NULL | NULL | Impossible WHERE noticed after reading const tablesNULL |



### 全文索引

```mysql
CREATE TABLE t3(
	ID int,
    Info varchar(20),
    Fulltext index t3_info(Info)
);
```



### 单列索引

- 给单个字段创建索引

```mysql
CREATE TABLE t4(
	ID int,
    subject varchar(30),
    Index t4_st(subject(10))
);
```



### 多列/联合/复合索引

- 给多个字段同时创建索引

- 在多个条件相连的 i 情况下，使用联合索引效率高于使用但单字段索引
- where a=xxx and b = xxx; 
- a和b分别创建了索引，正常情况下只能命中一个，所以需要对a和b都创建索引  —— 联合索引。

```mysql
CREATE TABLE t5(
	ID int,
    Name varchar(20),
    Sex char(4),
    Index t5_ns(name,sex)    
);
或
create index ind_mix on 表(字段1，字段2)
```

- 规则：

  - 使用联合/多列索引时一定要特别注意，只有使用了索引中的第一个字段时才会触发索引。 如果没有使用索引中的第一个字段，那么这个多列索引就不会起作用。
  - 创建索引的顺序 id, email 条件中从哪一个开始出现了范围，索引就失效了。 例如 a,b,c,d      where b=3 and c=4 and d= 5 and a>10  从a开始就命不中索引了。
  - 联合索引在使用的时候遵循**最左前缀原则**

  ​       例如key index(a,n,c) 支持 a | a,b | a,b,c 3种组合进行查询，但不支持 b,c 进行查找，所以常常希望最左侧字段是常量引用时，索引就十分有效。

  3. 联合索引中只有使用 and 能生效，使用or失效。

  

## 在已经存在的表上创建索引 

1．创建普通索引 

CREATE INDEX index_name ON table(column(length)) 

2．创建惟一性索引 

CREATE UNIQUE INDEX indexName ON table(column(length)) 

3．创建全文索引 

CREATE FULLTEXT INDEX index_content ON article(content) 

4．创建单列索引 

CREATE INDEX index3_name on index3 (name(10)); 

5．创建多列索引 

CREATE INDEX index3_ns on index3 (name(10),sex);



## 用ALTER TABLE语句来创建索引

在已经存在的表上，可以通过ALTER TABLE语句直接为表上的一个或几个字段创建索引。基本形式如下： 

```mysql
ALTER TABLE 表名 ADD [ UNIQUE | FULLTEXT | SPATIAL ] INDEX 
索引名（属性名 [ (长度) ] [ ASC | DESC]）; 
```

 其中的参数与上面的两种方式的参数是一样的。 



## 删除索引

```mysql
DROP INDEX 索引名 ON 表名 ;
```



# EXPLAIN 

| id   | select_type | table | type | possible_keys | key  | key_len | ref   | rows | Extra |
| ---- | ----------- | ----- | ---- | ------------- | ---- | ------- | ----- | ---- | ----- |
| 1    | SIMPLE      | t1    | ref  | ID            | ID   | 5       | const | 1    | NULL  |

将上面得到的结果拿下来分析：

## id

查询的序列号

## select_type

查询的类型，主要是区别普通查询和联合查询、子查询之类的复杂查询

- SIMPLE：查询中不包含子查询或者UNION
- 查询中若包含任何复杂的子部分，最外层查询则被标记为：PRIMARY
- 在SELECT或WHERE列表中包含了子查询，该子查询被标记为：SUBQUERY

## table

这是表的名字。 

## type

连接操作的类型 

- ALL: 扫描全表

- index: 扫描全部索引树

- range: 扫描部分索引，索引范围扫描，对索引的扫描开始于某一点，返回匹配值域的行，常见于between、<、>等的查询

- ref: 使用非唯一索引或非唯一索引前缀进行的查找

（eq_ref和const的区别：）

- eq_ref：唯一性索引扫描，对于每个索引键，表中只有一条记录与之匹配。常见于主键或唯一索引扫描

- const, system: 单表中最多有一个匹配行，查询起来非常迅速，例如根据主键或唯一索引查询。system是const类型的特例，当查询- 的表只有一行的情况下， 使用system。

- NULL: 不用访问表或者索引，直接就能得到结果，如select 1 from test where 1

## possible_keys

可能可以利用的索引的名字 

## Key

它显示了MySQL实际使用的索引的名字。如果它为空（或NULL），则MySQL不使用索引。 

## key_len

key_len显示的值为索引字段的最大可能长度，并非实际使用长度，即key_len是根据表定义计算而得，不是通过表内检索出的。

## ref

它显示的是列的名字（或单词“const”），MySQL将根据这些列来选择行 （显示哪个字段或常数与key一起被使用）

## rows

MySQL所认为的它在找到正确的结果之前必须扫描的记录数。显然，这里最理想的数字就是1 

## Extra

这里可能出现许多不同的选项，其中大多数将对查询产生负面影响

- Using index：表示使用索引，如果只有 Using index，说明他没有查询到数据表，只用索引表就完成了这个查询，这个叫覆盖索引。
- Using where：表示条件查询，如果不读取表的所有数据，或不是仅仅通过索引就可以获取所有需要的数据，则会出现 Using where。



# 覆盖索引

explain中 Extra：Using index 

覆盖索引（covering index）指一个查询语句的执行只需要从辅助索引中就可以得到查询记录，而不需要查询聚集索引中的记录。也可以称之为实现了**索引覆盖。**

通俗来说就是：查一个索引不需要回表，就是覆盖索引

例如 ： select count(id) from 表;

当我们为 id 建立索引后就达到了覆盖所有的效果，只需要统计索引的数量，不需要回表，大大的提高了速度。

# 索引合并

创建的时候是分开创建的，用的时候临时合在一起。

Using union(ind_id, ind_email)

explain   select * from s1 where id = 1000000  or email = '1121559571@qq'; 



# 慢日志

直到MySQL有慢日志，通过配置文件开启，如果数据库在你手里，自己开。如果不在你手里，你也可以要求dba帮你开。



# 7表联查速度慢怎么办？

1. 表结构
   1. 尽量用固定长度的数据类型代替可变长数据类型
   2. 把固定长度的字段放在前面
2. 数据的角度上来说
   1. 如果表中的数据越多 查询效率越慢
      1. 列多  也慢 ： 垂直分表
      2. 行多：水平分表
3. 从sql的角度上
   1. 尽量把条件显得细致点儿， where条件多做筛选
   2. 多表的时候连表代替子查询
   3. 创建有效的索引，而规避无效的索引
4. 从配置角度上
   1. 开启慢日志查询，确认具体的有问题的sql语句
5. 数据库
   1. 读写分离（专门做写的服务器，专门做读的服务器，然后做同步。）
   2. 主库用来写，从库用来读
   3. 解决数据库读的瓶颈



# 哪些SQL语句会真正利用索引

- B-Tree可被用于sql中对列做比较的表达式，如=, >, >=, <, <=及between操作 

- 若like语句的条件是不以通配符开头的常量串，MySQL也会使用索引。 

  比如：

  ```mysql
  SELECT * FROM tbl_name WHERE key_col LIKE 'Patrick%'
  或 
  SELECT * FROM tbl_name WHERE key_col LIKE 'Pat%_ck%'
  ```

  可以利用索引，而

  ```mysql
  SELECT * FROM tbl_name WHERE key_col LIKE '%Patrick%'（以通配符开头）
  和
  SELECT * FROM tbl_name WHERE key_col LIKE other_col（like条件不是常量串）
  ```

  无法利用索引。 

  对于形如LIKE '%string%'的sql语句，若通配符后面的string长度大于3，则MySQL会利用Turbo Boyer-Moore algorithm算法进行查找. 

- 若已对名为col_name的列建了索引，则形如"col_name is null"的SQL会用到索引。 

- 对于联合索引，sql条件中的最左前缀匹配字段会用到索引。 

- 若sql语句中的where条件不只1个条件，则MySQL会进行Index Merge优化来缩小候选集 





# 影响性能的因素

应用程序、查询、事务管理、数据库设计、数据分布、网络、操作系统、硬件



# 系统优化

## 硬件优化

  cpu 64位 一台机器8-16颗CPU

  内存 96-128G 3-4个实例

  硬盘：数量越多越好 性能：ssd（高并发业务） > sas （普通业务）>sata（线下业务）

  raid 4块盘，性能 raid0 > raid10 > raid5 > raid1

  网卡：多块网卡bond  

## 软件优化

  操作系统：使用64位系统

  软件：MySQL 编译优化



# 服务优化

MySQL配置原则

- 配置合理的MySQL服务器，尽量在应用本身达到一个MySQL最合理的使用

- 针对 MyISAM 或 InnoDB 不同引擎进行不同定制性配置

- 针对不同的应用情况进行合理配置

- 针对 my.cnf 进行配置



# 应用优化

- 设计合理的数据表结构：适当的数据冗余
- 对数据表建立合适有效的数据库索引
- 数据查询：编写简洁高效的SQL语句

## 表结构设计原则

- 选择合适的数据类型：如果能够定长尽量定长

- 使用 ENUM 而不是 VARCHAR,ENUM类型是非常快和紧凑的，在实际上，其保存的是 TINYINT，但其外表上显示为字符串。这样一来，用这个字段来做一些选项列表变得相当的完美 。

- 不要使用无法加索引的类型作为关键字段，比如 text类型

- 为了避免联表查询，有时候可以适当的数据冗余，比如邮箱、姓名这些不容易更改的数据

- 选择合适的表引擎，有时候 MyISAM 适合，有时候InnoDB适合

- 为保证查询性能，最好每个表都建立有 auto_increment 字段， 建立合适的数据库索引

- 最好给每个字段都设定 default 值



## 索引建立原则

- 一般针对数据分散的关键字进行建立索引，比如ID、QQ，
     像性别、状态值等等建立索引没有意义字段唯一，最少，不可为null

- 对大数据量表建立聚集索引，避免更新操作带来的碎片。

- 尽量使用短索引，一般对int、char/varchar、date/time 等类型的字段建立索引

- 需要的时候建立联合索引，但是要注意查询SQL语句的编写

- 谨慎建立 unique 类型的索引（唯一索引）

- 大文本字段不建立为索引，如果要对大文本字段进行检索，可以考虑全文索引

- 频繁更新的列不适合建立索引

- order by 字句中的字段，where 子句中字段，最常用的sql语句中字段，应建立索引。                            

- 唯一性约束，系统将默认为该字段建立索引。

- 对于只是做查询用的数据库索引越多越好，但对于在线实时系统建议控制在5个以内。

- 索引不仅能提高查询SQL性能，同时也可以提高带where字句的update，Delete SQL性能。

- Decimal 类型字段不要单独建立为索引，但覆盖索引可以包含这些字段。

- 只有建立索引以后，表内的行才按照特地的顺序存储，按照需要可以是asc或desc方式。

- 如果索引由多个字段组成将最用来查询过滤的字段放在前面可能会有更好的性能。



## 编写高效的SQL

- 能够快速缩小结果集的 WHERE 条件写在前面，如果有恒量条件，也尽量放在前面

- 尽量避免使用 GROUP BY、DISTINCT 、OR、IN 等语句的使用，避免使用联表查询和子查询，因为将使执行效率大大下降

- 能够使用索引的字段尽量进行有效的合理排列，如果使用了联合索引，请注意提取字段的前后顺序

- 针对索引字段使用 >, >=, =, <, <=, IF NULL和BETWEEN 将会使用索引，如果对某个索引字段进行 LIKE 查询，使用 LIKE  ‘%abc%’不能使用索引，使用 LIKE ‘abc%’ 将能够使用索引

- 如果在SQL里使用了MySQL部分自带函数，索引将失效，同时将无法使用 MySQL 的 Query Cache，比如 LEFT(), SUBSTR(), TO_DAYS()，DATE_FORMAT(), 等，如果使用了 OR 或 IN，索引也将失效

- 使用 Explain 语句来帮助改进我们的SQL语句

- 不要在where 子句中的“=”左边进行算术或表达式运算，否则系统将可能无法正确使用索引

- 尽量不要在where条件中使用函数，否则将不能使用索引

- 避免使用 select *, 只取需要的字段

- 对于大数据量的查询，尽量避免在SQL语句中使用order by 字句，避免额外的开销，替代为使用ADO.NET 来实现。

- 如果插入的数据量很大，用select into 替代 insert into 能带来更好的性能

- 采用连接操作，避免过多的子查询，产生的CPU和IO开销

- 只关心需要的表和满足条件的数据

- 适当使用临时表或表变量

- 对于连续的数值，使用between代替in

- where 字句中尽量不要使用CASE条件

- 尽量不用触发器，特别是在大数据表上
- 更新触发器如果不是所有情况下都需要触发，应根据业务需要加上必要判断条件   
- 使用union all 操作代替OR操作，注意此时需要注意一点查询条件可以使用聚集索引，如果是非聚集索引将起到相反的结果
- 当只要一行数据时使用 LIMIT 1
- 尽可能的使用 NOT NULL填充数据库
- 拆分大的 DELETE 或 INSERT 语句
- 批量提交SQL语句



# 架构优化

- 业务拆分：搜索功能，like ，前后都有%，一般不用MySQL数据库

- 业务拆分：某些应用使用nosql持久化存储，例如memcahcedb、redis、ttserver 比如粉丝关注、好友关系等；

- 数据库前端必须要加cache，例如memcached，用户登录，商品查询

- 动态数据静态化。整个文件静态化，页面片段静态化

- 数据库集群与读写分离；

- 单表超过2000万，拆库拆表，人工或自动拆分（登录、商品、订单等）



# 流程、制度、安全优化

任何一次人为数据库记录的更新，都要走一个流程

- 人的流程：开发-->核心开发-->运维或DBA

- 测试流程：内网测试-->IDC测试-->线上执行

- 客户端管理：phpmyadmin等
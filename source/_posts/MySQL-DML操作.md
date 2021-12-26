---
title: MySQL-DML操作
date: 2019-05-27 17:53:55
tags: [MySQL,数据库,学习笔记]
categories: MySQL学习
comments: true
urlname:  MySQL_DML
copyright: true
---



{% cq %}本篇为数据表的DML操作。 {% endcq %}

<!--more-->





# 增（INSERT与REPLACE）

## INSERT INTO

## 一次插入一行

`INSERT INTO table [(column [, column...])]  VALUES(value [, value...]);`

## 一次插入多行

`INSERT INTO table [(column [, column...])]  VALUES(value [, value...])，(value [, value...]);`



## 结合SELECT查询语句：

`Insert into 表名[(字段列表1)]  select (字段列表2) from 源表 where 条件表达式；`

note: 如果不想在表名后列出列名，可以为那些无法指定的值插入null，

如果需要插入其他特殊字符，应该采用\转义字符做前缀。



## REPLACE

## 语法格式1

`replace into 表名 [（字段列表）]  values （值列表）`

## 语法格式2

`replace [into] 表名 set 字段1=值1, 字段2=值2;`

## 语法格式3

`replace [into] 目标表名[(字段列表1)]  select (字段列表2) from 源表 where 条件表达式;`



replace语句的功能与insert语句的功能基本相同，不同之处在于：使用replace语句向表插入新记录时，如果新纪录的主键值或者唯一性约束的字段值与已有记录相同，则已有记录先被删除（注意：已有记录删除时也不能违背外键约束条件），然后再插入新记录。

使用replace的最大好处就是可以将**delete和insert合二为一**，形成一个原子操作，这样就无需将delete操作与insert操作置于事务中了。



# 删（DELETE）

`DELETE FROM TABLE table_name WHERE condition`

从表中删除选出记录。



# 改（UPDATE）

`UPDATE table	SET column = value [, column = value] …	[WHERE condition];`

修改可以一次修改多行数据，修改的数据可用where子句限定，where子句里是一个条件表达式，只有**符合该条件的行才会被修改**。没有where子句意味着where字句的表达式值为true。

也可以同时修改多列，多列的修改中间采用逗号(,)隔开。



# 查（SELECT）

```mysql
SELECT	selection_list				想要的列	                
FROM	table_list					表（从何处选择行）	               		  	
WHERE	primary_constraint			筛选行（行必须满足什么条件）					 
GROUP BY	grouping_columns 		分组（怎样对结果分组）						   
HAVING	secondary_constraint		对组进行过滤（行必须满足的第二条件）             
ORDER BY	sorting_columns			排序（怎样对结果排序）	                   
LIMIT	offset_start, row_count		结果限定                   
```

select 语句做了什么？

循环记录找到想要的列



## AS

定义字段的**别名**

- 改变列的标题头

- 用于表示计算结果的含义

- 作为列的别名

- 如果别名中使用特殊字符,或者是强制大小写敏感,或有空格时,都可以通过为别名添加加双引号实现。

`SELECT emp_name "姓名", salary "薪水"   FROM employee;`

`SELECT emp_name as "姓名", salary as "薪水"  FROM employee;`



## 查看所有用户

  `SELECT User,Host,Password FROM mysql.user;`



## 四则运算

`SELECT last_name, salary, salary*12+100  FROM employees;`

`SELECT last_name, salary, salary*(12+100)	FROM employees;`

计算薪水



## 去重（DISTINCT）

`SELECT DISTINCT 字段1,字段2,字段3 FROM 表名;`

- 使用DISTINCT关键字可从查询结果中清除重复行

- DISTINCT的作用范围是后面**所有字段的组合**

  例如：上面这个组合：字段1,字段2,字段3 



## WHERE

- **限制**所选择的记录

- 使用WHERE子句限定返回的记录

- WHERE子句在FROM 子句后 

  `SELECT [DISTINCT] {*, column [alias], ...}  FROM table–[WHEREcondition(s)];`



## 筛选条件

行必须满足什么条件

### 范围查询

- =	<	<= 	>	>=  !=    <>

- BETWEEN 1000 AND 1500;        闭区间（包含），左边小右边大（反过来不行）。
- in (list)   匹配所有列出的值



### 模糊查询

#### `字段名 like xxx` 

##### "%" (百分号) 

代表任意长度（可为0）的字符串。

- a%: 开头
- %ing：结尾
- %a%：中间含有

例如：

`select * from employee where emp_name like 'e%';`

匹配emplyee表中，员工姓名以e开头的所有信息。

##### "_" (下划线)

代表任意单个字符。

- a_    可以匹配以a开头，长度为2的任意字符串。如ab。

#### REGEXP运算符  

（UNIX正则表达式）

- '^a'
- '\d+'

例如：

`select * from employee where emp_name regexp '^e';`

匹配emplyee表中，员工姓名以e开头的所有信息。



### 身份查询（is、is not）

- is null
- is not null

#### NULL值的使用

- 空值是指**不可用、未分配**的值

- 空值**不等于零或空格**

- 任意类型都可以支持空值

- 包括**空值**的任何**算术表达式都等于空**

- 字符串和null进行连接运算，得到也是null



### 逻辑运算

- and
- or
- not

### 运算优先级

所有的比较运算	>	NOT	>	AND	>	OR



# 单表查询

```mysql
SELECT	selection_list				想要的列	                
FROM	table_list					得到表（从何处选择行）	            		  	
WHERE	primary_constraint			筛选行（行必须满足什么条件）					 
GROUP BY	grouping_columns 		分组（怎样对结果分组）						   
HAVING	secondary_constraint		对组进行过滤（行必须满足的第二条件）             
ORDER BY	sorting_columns			排序（怎样对结果排序）	                   
LIMIT	offset_start, row_count		结果限定                   
```



## 常用函数

常用函数

- 字符串函数：`concat`,
- 数值函数
- 日期和时间函数
- 流程函数
- 其他常用函数
- 聚合函数/组和函数
- 数据类型转换 cast

### 字符串函数



| 函数                           | 功能                                                 |
| ------------------------------ | ---------------------------------------------------- |
| **CONCAT(str1,str2,...)**      | 连接字符串                                           |
| CONCAT_WS(str,str1,str2,...)   | 使用str来连接str1，str2，...                         |
| INSERT(str, pos, len, newstr)  | 字符串str从第pos位置开始的len个字符替换为新串newstr  |
| LOWER(str)                     | 转成小写                                             |
| UPPER(str)                     | 转成大写                                             |
| CHAR_LENGTH(str)               | 返回字符串str的长度                                  |
| LENGTH(str)                    | 返回字符串str的长度                                  |
| LPAD(str, len, padstr)         | 返回字符串str，其左边由字符串padstr填补到len字符长度 |
| RPAD(str, len, padstr)         | 返回字符串str，其右边由字符串padstr填补到len字符长度 |
| TRIM(str)                      | 去掉字符串str前缀和后缀的空格                        |
| REPEAT(str, count)             | 返回str重复count次的结果                             |
| REPLACE(str, from_str, to_str) | 用字符串to_str替换字符串中所有的字符串from_str       |
| SUBSTRING(str, pos, len)       | 返回从字符串str的pos位置起len个字符长度的字串        |



### 数值函数

| 函数          | 功能                                     |
| ------------- | ---------------------------------------- |
| ABS(X)        | 返回X的绝对值                            |
| CEIL(X)       | 返回不小于X的最小整数值（向上取整）      |
| FLOOR(X)      | 返回不大于X的最大整数值（向下取整）      |
| MOD(X,Y)      | 返回x/y的模                              |
| RAND()        | 返回0~1之间的随机浮点数 v(0 <= v <= 1.0) |
| ROUND(X,Y)    | 返回参数X的四舍五入的有Y位小数的值       |
| TRUNCATE(X,Y) | 返回数字x截断为y位小数的结果             |



### 日期和时间函数

| 函数                              | 功能                                         |
| --------------------------------- | -------------------------------------------- |
| CURDATE()                         | 返回当前日期                                 |
| CURTIME()                         | 返回当前时间                                 |
| **NOW()**                         | **返回当前的日期和时间**                     |
| WEEK(date)                        | 返回指定日期为一年中的第几周                 |
| YEAR(date)                        | 返回日期的年份                               |
| HOUR(time)                        | 返回time的小时值                             |
| MINUT(time)                       | 返回time的分钟值                             |
| MONTHNAME(date)                   | 返回date的月份名                             |
| **DATE_FORMAT(date, fmt)**        | **返回字符串fmt格式化日期date值（%Y...）**   |
| DATE_ADD(date, INTERVAL exp type) | 返回一个日期或时间值加上一个时间间隔的时间值 |
| DATEDIFF(expr, expr2)             | 返回起始时间expr和结果时间expr2之间的天数    |



### 流程函数

| 函数                                                         | 功能                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| IF(*expr1*, *expr2*, *expr3*)                                | 如果*expr1* 是TRUE(expr1 <> 0 and expr1 is not null ), 则IF()的返回值为*expr2*；否则返回值则为*expr3*. （类似三元运算符） |
| IFNULL(*expr1*, *expr2*)                                     | 假如*expr1*不为NULL，则IFNULL()的返回值为*expr1*；否则其返回值为*expr2*. |
| CASE<br />     WHEN [*value*] THEN *result* <br />     ELSE default<br />END | 如果*value*是真，返回*result*；否则返回*default*。           |
| CASE  [expr]<br />     WHEN [*value1*] THEN *result1* <br />     [ WHEN [*value2*] THEN *result2* ] <br />     [ ELSE default ]<br />END | 如果*expr*等于*value1*，返回*result1*，如果等于*value2*，返回*result2*，否则返回*default*。 |

#### CASE WHEN剖析

##### 式一

```mysql
CASE 
WHEN <判断表达式> THEN <表达式>
     WHEN <判断表达式> THEN <表达式> 
     WHEN <判断表达式> THEN <表达式>
     ...
     ELSE <表达式>
END
```

CASE表达式会对最初的WHEN字句中的<判断表达式>进行判断开始执行。

如果该表达式的真值为真（TRUE），那么就返回THEN字句中的表达式，CASE表达式到此为止。

如果结果不为真，那么就跳转到下一句WHEN字句的判断之中。

如果直到最后的WHEN字句为止返回结果都不为真，那么就会返回ELSE中的表达式，执行终止。

```mysql
SELECT 
CASE id
WHEN id > 2  THEN '>2'
WHEN id <= 2  THEN '<=2'
ELSE
	id
END 
AS '显示'
FROM tt1;

# 为什么上面这样查询结果有问题
SELECT 
CASE 
WHEN id > 2  THEN '>2'
WHEN id <= 2  THEN '<=2'
ELSE
	id
END 
AS '显示'
FROM tt1;
```

##### 式二

```mysql
CASE  case_expression
   WHEN when_expression_1 THEN commands
   WHEN when_expression_2 THEN commands
   ...
   ELSE commands
END 
```

`case_expression`可以是任何有效的表达式。

将`case_expression`的值与每个`WHEN`子句中的`when_expression`进行比较，

例如`when_expression_1`，`when_expression_2`等。

**如果`case_expression`和`when_expression_n`的值相等**，则**执行**相应的`WHEN`分支中的命令(`commands`)。



这也就解释了为什么前面的查询会产生问题，原因在于 when_expression是布尔运算 它的结果是0 或 1，所以只有case_expression也就是id为0，1的时候才会执行相应的分支。

```
+--------+
| 显示   |
+--------+
| >2     |   # id = 0
| <=2    |   # id = 1
| 2      |
| 3      |
| 4      |
| 5      |
+--------+
```







### 其他常用函数

| 函数          | 功能                                                         |
| ------------- | ------------------------------------------------------------ |
| DATABASE()    | 返回当前数据库名                                             |
| VERSION()     | 返回当前数据库版本                                           |
| USER()        | 返回当前登录用户名                                           |
| INET_ATON(ip) | 返回IP地址的数字表示                                         |
| INET_NTOA(ip) | 返回数字代表的IP地址                                         |
| PASSWORD(str) | 返回字符串str的加密版本，加密是单向的（不可逆），适用于MySQL数据库的用户密码加密 |
| MD5(str)      | 返回字符串str的MD5值，该值以32位十六进制数字形式返回         |



### 聚合函数/组和函数

聚合函数对一组值进行运算，并返回单个值。也叫组合函数。

| 函数               | 功能     |
| ------------------ | -------- |
| COUNT(*\|列名)     | 统计行数 |
| AVG(数值类型列名)  | 平均值   |
| SUM (数值类型列名) | 求和     |
| MAX(列名)          | 最大值   |
| MIN(列名)          | 最小值   |

note：除了COUNT()以外，聚合函数都会**忽略NULL值**。

聚合函数不能在where中使用，不是所有函数都是聚合函数 例如year()可以放在where中。

### 数据类型转换 cast

CAST (expression AS data_type)
参数说明：

- **expression**：任何有效的SQServer表达式。
- **AS**：用于分隔两个参数，在AS之前的是要处理的数据，在AS之后是要转换的数据类型。
- **data_type**：目标系统所提供的数据类型，包括bigint和sql_variant，不能使用用户定义的数据类型。

例如：

小数点后保留两位小数：

```sql
cast(avg(score) as decimal(5,2)) as '平均分'
```

计算及格率（部分）：

思路：将及格的部分标为1

```sql
concat(cast(sum(pass)/count(score)*100 as decimal(5,2)),'%') as '及格率'
```



## GROUP BY

GROUP BY子句的真正作用在于与各种聚合函数配合使用。它用来对查询出来的数据进行分组。

分组的含义是：把**该列具有相同值的多条记录当成一组记录处理**，最后**只输出一条记录**。

一旦分组了，就不能对具体某一条数据进行操作了，永远都是考虑这个组怎么怎么样。

分组函数忽略空值。

结果集隐式按升序排列,如果需要改变排序方式可以使用Order by 子句。

`SELECT column, group_function  FROM table  [WHERE condition]  [GROUP BY group_by_expression]  [ORDER BY column];`

例1：

`select * from employee group by sex;`

根据性别分组：男的一组，女的一组。

- 显示找到的组的第一个人信息，不能显示每一个人的信息。

- 根据某个重复率比较高的字段进行的，这个字段有多少种可能就分成多少个组

例2:

如果没有使用分组，默认**一整张表为一组**

`select min(hire_date) from employee;`

查所有人中最早入职的日期



### **分组函数**重要规则

如果使用了分组函数，或者使用GROUP BY 的查询：出现在SELECT列表中的字段，要么出现在组合函数里，要么出现在GROUP BY 子句中。

GROUP BY 子句的字段可以不出现在SELECT列表当中。

使用**集合函数**可以不使用GROUP BY子句，此时所有的查询结果作为一组。



### `group_concat`

只用来做最终的显示，不能作为中间结果操作其他数据。

别胡乱使用。



## HAVING子句

限定组的结果

HAVING子句用来对分组后的结果再进行条件过滤。

```mysql
SELECT column, group_function  FROM table  [WHERE condition]
[GROUP BY group_by_expression]   
[HAVING group_condition] 
[ORDER BYcolumn];
```



不建议用在不分组的地方。

```mysql
select id,emp_name  from employee having age>20;  # 报错
# ERROR 1054 (42S22): Unknown column 'age' in 'having clause'
select id,emp_name,age from employee having age>20;
```



### HAVING与WHERE的区别

WHERE是在分组前进行条件过滤， HAVING子句是在分组后进行条件过滤，WHERE子句中不能使用聚合函数，HAVING子句可以使用聚合函数。



## ORDER BY

order by  字段  [asc/desc]

默认升序 asc,desc降序

根据年龄进行排序后， 根据薪资进行排序。



## LIMIT

MySQL中独有的。用来对结果进行限定。

### 显示分页

#### 写法一

`limit m,n` 

从m+1开始，取n条

limit 0，6 表示从1开始取6条

limit 6，6 表示从1开始取6条

limit 12，6 表示从1开始取6条

#### 写法二

limit n offset m :

从m+1开始，取n条

和 `limit m,n` 一样。

### 取前n名

`limit n`    

m默认为0

- 跟order by 一起用

`select * from employee order by salary desc limit 3;`



### LIMIT存在的问题

它会把所有的数据都读出来

limit 1000000，6

它会把所有数据都读出来，这样才能从这个序号继续往后读。



## 执行顺序

```mysql
select	想要的列	                 5
from	表	               		  	1
where	查询的行					  2
group by 分组						    3
having 对组进行过滤	                4  
order by	排序	                    6
limit	去一个区间;                    7

5 1 2 3 4 6 7
```

例如：重命名结果和顺序有关

select name as n from  table where n = 1;

错误，因为 在where的时候 n 还没有重命名





# 多表查询

使用单个SELECT语句从多个表中取出相关的数据，通过多表之间的关系，构建相关数据的查询。

多表连接通常是建立在有相互关系的父子表上。

```mysql
SELECT	...	FROM	
join_table	JOIN_TYPE	join_table	ON	join_condition	 # 这一行可看作一张新表
WHERE	where_condition
```

- join_table 参与连接的表

- JOIN_TYPE 连接类型：内连接、外连接、交叉连接、自连接
- join_condition 连接条件
- where_condition where过滤条件



## 交叉连接 CROSS JOIN

使用交叉连接来得到笛卡尔积（两张表记录的乘积）

示例：

下面是查询员工表与部门表的笛卡尔积：

`SELECT * FROM employee, department;`

`SELECT * FROM employee CROSS JOIN department;`

note: 结果按照表的左右顺序显示。



## 内连接 INNER JOIN

### 语法

```mysql
SELECT ... FROM 
join_table [INNER] JOIN join_table2	[ON join_condition]
WHERE where_definition
# 习惯上我们的 INNER是不省略的。
```

**只列出这些连接表中与连接条件相匹配的数据行。**

### 内连接分类

等值连接：在连接条件中使用等号（=）运算符来比较被连接列的列值。

非等值连接：在连接条件中使用等号运算符以外的其它比较运算符来比较被连接的列的列值。（<	<=	>	>=	<>）

自然连接：在连接条件中使用（=）运算符来比较被连接列的列值，但它使用选择列表指出查询结果集合中所包括的列，并删除连接表中的**重复列**。

例子：

`select * from employee inner join department on dep_id = department.id;`

没有人的部门以及不再任何部门的人是不会查出来的。



## 外连接

（MySQL中没有全外连接FULL JOIN）

```mysql
SELECT ... FROM 
join_table (LEFT|RIGHT) [OUTER] JOIN join_table2  [ON join_condition]
WHERE where_definition
# 习惯上 OUTER是省略的。
```

在外连接中，某些不满足条件的列也会显示出来，也就是说，只限制其中一个表的行，而不限制另一个表的行。

### 左外连接

左连接，左边的表为主表，左边的表记录全部显示，如果没找到记录则补NULL。



### 右外连接

右连接，右边的表为主表，右边的表记录全部显示，如果没找到记录则补NULL。



### 全外连接

```mysql
SELECT ... FROM 
join_table LEFT JOIN join_table2  [ON join_condition] 
WHERE where_definition
union
SELECT ... FROM 
join_table RIGHT JOIN join_table2  [ON join_condition] 
WHERE where_definition
```

note: 注意 join_table与join_table2的顺序不能变。



### 练习

1.查询所有员工以及部门信息。

```mysql
select * from employee left join department on dep_id = department.id 
union 
select * from employee right join department on dep_id = department.id;
```

结果如下

```
+------+------------+--------+------+--------+------+--------------+
| id   | name       | sex    | age  | dep_id | id   | name         |
+------+------------+--------+------+--------+------+--------------+
|    1 | 悟空       | male   |   18 |    200 |  200 | 技术         |
|    5 | 沙僧       | male   |   18 |    200 |  200 | 技术         |
|    2 | 猪八戒     | male   |   48 |    201 |  201 | 人力资源     |
|    3 | 至尊宝     | male   |   38 |    201 |  201 | 人力资源     |
|    4 | 安其拉     | female |   28 |    202 |  202 | 销售         |
|    6 | 貂蝉       | female |   18 |    204 | NULL | NULL         |
| NULL | NULL       | NULL   | NULL |   NULL |  203 | 运营         |
+------+------------+--------+------+--------+------+--------------+
```

2.年龄大于25的员工的姓名以及员工所在的部门

```mysql
SELECT e.name, d.name FROM employee AS e LEFT JOIN department AS d ON dep_id = d.id WHERE age > 25;
```

结果如下：

```
+---------+--------------+
| name    | name         |
+---------+--------------+
| 猪八戒  | 人力资源      |
| 至尊宝  | 人力资源      |
| 安其拉  | 销售          |
+---------+--------------+
```



## 子查询

某些情况下，当进行查询的时候，需要的条件是另外一个SELECT语句的结果，这个时候就要用到子查询，换句话说他们是可以拆分的。

为了给主查询（外部查询）提供数据而首先执行的查询（内部查询）被叫做子查询。

用于子查询的关键字主要包括 in、not in 、 = 、<>等。

一边来说。子查询的效率低于连接查询。表连接都可以用子查询替换，但反过来却不一定。



### 特殊的子查询

例子：

`select name as n,(select age from employee where name = n) from employee;`

子查询可以放在条件中，还可以放在连表中，还可以放在select字段（要求查询的结果必须是一个单行单列的值）中。



### 练习

查询平均年龄在25岁以上的部门名

方法一：

1. 找到平均年龄>=25的员工所在部门的dep_id

```mysql
SELECT dep_id,AVG(age) a  FROM employee GROUP BY dep_id HAVING AVG(age) >= 25;
```

2. 将得到的新表与部门表进行连接

```mysql
SELECT name,avg_name FROM department AS d INNER JOIN (SELECT dep_id,AVG(age) avg_name  FROM employee GROUP BY dep_id HAVING AVG(age) >= 25) AS e ON  d.id = e.dep_id;
```

以上，先子查询得出的表连接新的表。



方法二：

1. 得到部门中员工的平均年龄以及部门dep_id

```mysql
SELECT dep_id,AVG(age) AS avg_name  FROM employee GROUP BY dep_id;
```

2. 将得到的新表与部门表连接，并选出平均年龄在25岁以上的部门名

```mysql
SELECT name,avg_name FROM department AS d INNER JOIN (SELECT dep_id,AVG(age) AS avg_name  FROM employee GROUP BY dep_id ) AS e ON  d.id = e.dep_id WHERE avg_name >= 25;
```

结果如下:

```
+--------------+----------+
| name         | avg_name |
+--------------+----------+
| 人力资源     |  43.0000 |
| 销售         |  28.0000 |
+--------------+----------+
```







# 总结

本篇介绍了有关数据表的DML操作：

增：INSERT INTO 、删：DELETE、改：UPDATE



单表查询：

```mysql
SELECT	selection_list				想要的列	                
FROM	table_list					得到表（从何处选择行）	            		  	
WHERE	primary_constraint			筛选行（行必须满足什么条件）		
# 以上为条件查询
GROUP BY	grouping_columns 		分组（怎样对结果分组）						   
HAVING	secondary_constraint		对组进行过滤（行必须满足的第二条件）   
# 以上为分组查询，在这里使用聚合函数来配合(count,sum,avg,max,min)
ORDER BY	sorting_columns			排序（怎样对结果排序）	                   
LIMIT	offset_start, row_count		结果限定          
# 以上为查询排序
```



多表查询：

CROSS JOIN（交叉连接） 

INNER JOIN（内连接）

OUTER JOIN（外连接）



子查询：

一句话中有两个select，当我们可以使用多表查询就可以得出结果的时候使用表连接，因为子查询的效率不如多表查询的效率高。



小技巧：在cmd中，有时候无法从子句退出时语句输入 `\c`

----------



```mysql
select book_id,a.name pname from app01_book_author inner join (select id,name from app01_Author) a on a.id =author_id;
select b.pname,count(*) from app01_Book c inner join(select book_id,a.name pname from app01_book_author inner join (select id,name from app01_Author) a on a.id =author_id)b on b.book_id =id group by pname;


select author_id from app01_book_author inner join (select id from app01_Book where title='跟金老板学开车') a on a.id=book_id;
select name,id from app01_Author where id in (select author_id from app01_book_author inner join (select id from app01_Book where title='跟金老板学开车') a on a.id=book_id);


select author_id, book_id from app01_book_author inner join (select id from app01_Book where title='跟金老板学开车') a on a.id=book_id;

select b.author_id aid,title,price from app01_Book inner join (select author_id, book_id from app01_book_author inner join (select id from app01_Book where title='跟金老板学开车') a on a.id=book_id) b on b.book_id = id;

select name,c.title,c.price from app01_Author inner join(select b.author_id aid,title,price from app01_Book inner join (select author_id, book_id from app01_book_author inner join (select id from app01_Book where title='跟金老板学开车') a on a.id=book_id) b on b.book_id = id) c on c.aid=id;
```




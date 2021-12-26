---
title: Mybatis笔记
copyright: true
date: 2020-10-11 00:23:54
tags: [MyBatis学习,数据库,学习笔记]
categories: MyBatis学习
comments: true
urlname:  MyBatis_01
---



{% cq %} 学习Mybatis的一些记录 {% endcq %}

<!--more-->



## 1、简介

### 1.2 持久化

- 将程序的数据在持久状态和瞬时状态转化的过程。

### 1.3 持久层

Dao层、Service层、Controller层

- 完成持久化工作的代码块
- 层界限十分明显。



## 2、第一个Mybatis程序

思想：搭建环境——>导入Mybatis——>编写代码——>测试

### 2.1 搭建环境

搭建数据库

```

```

新建项目

```
1. 普通maven项目
2. 删除src
3. 导入依赖
```

创建一个模块

- 编写mybatis核心配置文件

- 编写mybatis工具类

  ```java
  // sqlSessionFactory -> sqlSession
  public class MybatisUtils {
  
      private static SqlSessionFactory sqlSessionFactory;
  
      static {
          try {
              // 使用mybatis第一步：获取sqlSessionFactory对象
              String resource = "mybatis-config.xml";
              InputStream inputStream = Resources.getResourceAsStream(resource);
              SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
          } catch (IOException e) {
              e.printStackTrace();
          }
      }
  
      // 既然有了SqlSessionFactory，我们就可以获得SqlSession的实例。该实例包含了执行sql的所有方法。
      public static SqlSession getSqlSession(){
          return sqlSessionFactory.openSession();
      }
  
  }
  ```



### 2.3、编写代码

- 实体类

  - ```java
    package com.chennq.pojo;
    
    // 实体类
    public class User {
        private int id;
        private String name;
        private String pwd;
    
        public void setId(int id) {
            this.id = id;
        }
    
        public void setName(String name) {
            this.name = name;
        }
    
        public void setPwd(String pwd) {
            this.pwd = pwd;
        }
    
        public int getId() {
            return id;
        }
    
        public String getName() {
            return name;
        }
    
        public String getPwd() {
            return pwd;
        }
    
        @Override
        public String toString() {
            return "User{" +
                    "id=" + id +
                    ", name='" + name + '\'' +
                    ", pwd='" + pwd + '\'' +
                    '}';
        }
    }
    ```

    

- Dao接口

  ```java
  public interface UserDao {
      List<User> getUserList();
  }
  ```

  

- 接口实现类（由原来的UserDaoImpl转换成一个Mapper.xml）

  ```xml
  <?xml version="1.0" encoding="UTF-8" ?>
  <!DOCTYPE mapper
          PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
          "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
  
  <mapper namespace="com.chennq.UserDao">
      <!-- select查询语句-->
      <select id="getUserList" resultType="com.chennq.pojo.User">
          select * from mybatis.user;
      </select>
  </mapper>
  ```



### 2.4 测试

```java
public class UserDaoTest {
    @Test
    public void test(){
        // 获取sqlsession对象
        SqlSession sqlSession = MybatisUtils.getSqlSession();
        // 执行sql
        UserDao mapper = sqlSession.getMapper(UserDao.class);
        List<User> userList = mapper.getUserList();
        for (User user : userList) {
            System.out.println(user);
        }
        // 关闭sqlsession
        sqlSession.close();
    }
}
```



## 3、CRUD

### 1. namespace

namespace中的包名要和Dao/mapper接口的包名相同



### 2 select

选择，查询语句

- id：就是对应namespace中的方法名；
- resultType：Sql语句执行的返回值！ Class
- parameterType：参数类型

1. 编写接口

   ```java
   // 根据id查询
   User getUserById(int id);
   ```

   

2. 编写对应的mapper中的sql语句

   ```xml
   <select id="getUserById" parameterType="int" resultType="com.chennq.pojo.User">
           select * from mybatis.user where id=#{id}
   </select>
   
   ```

   

3. 测试

   ```java
   	@Test
       public void getUserById(){
           // 获取sqlsession对象
           SqlSession sqlSession = MybatisUtils.getSqlSession();
   
           UserMapper mapper = sqlSession.getMapper(UserMapper.class);
           User user = mapper.getUserById(1);
           System.out.println(user);
   
           // 关闭sqlsession
           sqlSession.close();
       }
   
   ```

   

### 3 insert

1. 编写接口

   ```java
   // insert一个用户
   int addUser(User user);
   
   ```

   

2. 编写mapper中涉及的sql

   ```xml
   	<!--对象中的属性可以直接取出来-->
       <insert id="addUser" parameterType="com.chennq.pojo.User">
           insert into mybatis.user (id, name, pwd) values (#{id},#{name},#{pwd});
       </insert>
   
   ```

   

3. 测试

   ```java
   // 增删改需要提交事务
       @Test
       public void addUser(){
           // 获取sqlsession对象
           SqlSession sqlSession = MybatisUtils.getSqlSession();
   
           UserMapper mapper = sqlSession.getMapper(UserMapper.class);
           int res = mapper.addUser(new User(4, "花花", "666"));
           System.out.println(res);
   
           // 提交事务(必须的，不然写不进去)
           sqlSession.commit();
           // 关闭sqlsession
           sqlSession.close();
       }
   
   ```

   

### 4 update

### 5 delete



### 7 万能的Map

非正规的方式！

假设，我们的实体类，或数据库中的表，字段或参数过多，我们应当考虑Map！

```java
 // insert一个用户，方式二
int addUser2(Map<String,Object> map);

```



```xml
<insert id="addUser2" parameterType="map">
        insert into mybatis.user (id, name, pwd) values (#{id},#{name},#{pwd});
</insert>

```

Map传递参数，直接在sql中取出key即可！ 【parameterType="map"】

对象传递参数，直接在sql中去对象的属性即可！ 【parameterType="Object"】

只有一个基本类型的情况下，可以直接在sql中取到！ 【无需指定parameterType】

多个参数用map，或者注解！



### 8 模糊查询

防止sql注入

1. Java代码执行的执行的时候，通过参数传递通配符 % %

   ```java
   List<User> userList = mapper.getUserLike("%李%");
   
   ```

   

2. 在sql拼接中使用通配符！

   ```sql
   select * from mybatis.user where name like "%"#{value}"%"
   
   ```

   

#{} 与${} ：能用# 就用# ，它可以防止sql注入

## 4、配置解析



### 1 核心配置文件

- mybatis-config.xml
- MyBatis的配置文件中包含了会深深影响MyBatis行为的设置和属性信息。      
- configuration（配置）            
  - [properties（属性）](https://mybatis.org/mybatis-3/zh/configuration.html#properties) （掌握）
  - [settings（设置）](https://mybatis.org/mybatis-3/zh/configuration.html#settings)（掌握）
  - [typeAliases（类型别名）](https://mybatis.org/mybatis-3/zh/configuration.html#typeAliases) （掌握）
  - [typeHandlers（类型处理器）](https://mybatis.org/mybatis-3/zh/configuration.html#typeHandlers)
  - [objectFactory（对象工厂）](https://mybatis.org/mybatis-3/zh/configuration.html#objectFactory)
  - [plugins（插件）](https://mybatis.org/mybatis-3/zh/configuration.html#plugins)
  - environments（环境配置）
    - environment（环境变量）                    
      - transactionManager（事务管理器）
      - dataSource（数据源）
  - [databaseIdProvider（数据库厂商标识）](https://mybatis.org/mybatis-3/zh/configuration.html#databaseIdProvider)
  - [mappers（映射器）](

### 2 环境配置（environments）

- MyBatis 可以配置成适应多种环境
- **不过要记住：尽管可以配置多个环境，但每个 SqlSessionFactory实例只能选择一种环境。**
- 事务管理器（transactionManager）  type="[JDBC|MANAGED]"）
- 数据源（dataSource） 连接数据库  dbcp   c3p0  druid
  - 三种内建的数据源类型： type="[UNPOOLED|POOLED|JNDI]"）
  - 池：用完可以回收的

学会使用配置多套运行环境！

Mybatis默认的事务管理器就是JDBC，连接池：POOLED

### 3 属性（properties）

- 可以通过properties属性来实现引用配置文件

- 这些属性可以在外部进行配置，并可以进行动态替换。你既可以在典型的 Java 属性文件中配置这些属性，也可以在 properties 元素的子元素中设置。 【db.properties】

- 将之前的改造成可插入的！

  1. 编写一个配置文件  【db.properties】

     ```properties
     driver=com.mysql.jdbc.Driver
     url=jdbc:mysql://localhost:3306/mybatis?useSSL=true&useUnicode=true&characterEncoding=UTF-8
     username=root
     password=2296
     
     ```

  2. 在核心配置文件中引入

     - 在xml中，所有标签都可以规定其顺序！

     ```xml
     <!-- 引入外部配置文件, 优先使用外部文件的属性-->
         <properties resource="db.properties">
             <property name="username" value="root" />
             <property name="password" value="2296" />
     </properties>
     
     ```

     - 可以直接引入外部文件
     - 可以在其中增加一些属性配置
     - 如果两个文件有同一个字段，优先使用外部配置文件的！



### 4 类型别名（typeAliases）

- 类型别名可为 Java 类型设置一个缩写名字。

- 它仅用于 XML 配置，意在降低冗余的全限定类名书写。

- 方式一：给指定类型起别名

  ```xml
  	<!--可以给实体类起别名-->
      <typeAliases>
          <typeAlias type="com.chennq.pojo.User" alias="User"/>
      </typeAliases>
  
  ```

  ```xml
  resultType="User"        
  
  ```

  

- 方式二：指定包名，MyBatis 会在包名下面搜索需要的 Java Bean。

  ```xml
      <!--可以给实体类起别名-->
      <typeAliases>
          <package name="com.chennq.pojo"/>
      </typeAliases>
  
  ```

  - 扫描实体类的包，它的默认别名就为这个类的类名，首字母小写。

  ```
  resultType="user"     
  
  ```

  - 大写其实也可以，但这样更加规范。

结论：

在实体类比较少的时候，使用第一种方式；

如果实体类十分多，建议使用第二种。

区别：

- 第一种可以DIY别名，第二种则不行，如果非要改，需要在实体类上增加注解（@Alias("author")）



### 5 设置

重要的几个：

- 缓存 cacheEnabled
- 懒加载 lazyLoadingEnabled 
- 自动生成主键 useGeneratedKeys
- 驼峰命名转换 mapUnderscoreToCamelCase
- 日志实现 logImpl  



### 6 其他配置

- typeHandlers（类型处理器）
- objectFactory（对象工厂）
- plugins（插件）
  - mybatis-generator-core
  - mybatis-plus
  - 通用mapper

### 7 映射器（mappers）

> org.apache.ibatis.binding.BindingException: Type interface com.chennq.dao.UserMapper is not known to the MapperRegistry.

MapperRegistry：注册绑定我们的Mapper文件。

方式一：【推荐使用】

```xml
<!--每一个mapper.xml都需要mybatis核心配置文件中注册-->
<mappers>
    <mapper resource="com/chennq/dao/UserMapper.xml"/>
</mappers>

```

方式二：使用class文件绑定注册

```xml
<!--每一个mapper.xml都需要mybatis核心配置文件中注册-->
<mappers>
    <mapper resource="com.chennq.dao.UserMapper"/>
</mappers>

```

注意点：

- 接口和他的Mapper配置文件必须同名！
- 接口和他的Mapper配置文件必须在同一个包下！

方式三：使用扫描包进行注入绑定

```xml
<!--每一个mapper.xml都需要mybatis核心配置文件中注册-->
<mappers>
	<package name="com.chennq.dao"/>
</mappers>

```

注意点：

- 接口和他的Mapper配置文件必须同名！
- 接口和他的Mapper配置文件必须在同一个包下！



### 8 生命周期和作用域

生命周期和作用域是至关重要的，因为错误的使用会导致非常严重的**并发问题**。

![1602410407112](C:\Users\ATLAS\AppData\Roaming\Typora\typora-user-images\1602410407112.png)

**SqlSessionFactoryBuilder**：

- 一旦创建了 SqlSessionFactory，就不再需要它了。
- 作用域：局部变量

**SqlSessionFactory**：

- 可以想象为：数据库连接池
- SqlSessionFactory一旦被创建就应该在应用的运行期间一直存在，**没有任何理由丢弃它或重新创建另一个实例**。
- 作用域：应用作用域。
- 最简单的就是使用**单例模式**或者静态单例模式。

**SqlSession**：

- 理解为：连接到连接池的一个请求！
- SqlSession的实例不是线程安全的，因此是不能被共享的，所以它的最佳的作用域是**请求或方法作用域**。
- 用完之后需要关闭，否则资源被占用！

如果你现在正在使用一种 Web 框架，考虑将 SqlSession 放在一个和 HTTP 请求相似的作用域中。
换句话说，每次收到 HTTP 请求，就可以打开一个 SqlSession，返回一个响应后，就关闭它。

![1602411101660](C:\Users\ATLAS\AppData\Roaming\Typora\typora-user-images\1602411101660.png)

这里面的每一个Mapper，就代表一个具体的业务。



## 5、解决属性名和字段名不一致的问题

数据库中的字段

![1602411247980](C:\Users\ATLAS\AppData\Roaming\Typora\typora-user-images\1602411247980.png)

新建一个项目，拷贝之前的，测试实体类字段不一致的情况。



解决办法：

- 起别名： 【不推荐】

  ```xml
  <select id="getUserById" parameterType="int" resultType="User">
          select id,name,pwd as password from mybatis.user where id=#{id}
  </select>
  
  ```

- resultMap

  ```xml
  <!-- 结果集映射-->
      <resultMap id="UserMap" type="com.chennq.pojo.User3">
          <!--column数据库中的字段，property实体类中的属性-->
          <result column="id" property="id"/>
          <result column="name" property="name"/>
          <result column="pwd" property="password"/>
      </resultMap>
  
  	<select id="getUserById" parameterType="int" resultMap="UserMap">
          select * from mybatis.user where id=#{id}
      </select>
  
  ```

  

- `resultMap` 元素是 MyBatis 中最重要最强大的元素。

- ResultMap的设计思想是，对简单的语句做到零配置，对于复杂一点的语句，只需要描述语句之间的关系就行了。

- `ResultMap`的优秀之处——你完全可以不用显式地配置它们。(只需将不同的名称做映射即可)



## 6、日志

### 1 日志工厂

如果一个数据库操作，出现了异常，我们需要排错，日志是最好的助手！

曾经：sout、debug

现在：日志

- SLF4J 
- LOG4J  【掌握】
- LOG4J2 
- JDK_LOGGING 
- COMMONS_LOGGING 
- STDOUT_LOGGING 【掌握】
- NO_LOGGING

在mybatis中具体使用哪个日志实现，在设置中设定！

STDOUT_LOGGING

```xml
<settings>
        <setting name="logImpl" value="STDOUT_LOGGING"/>
</settings>

```

![1602426160517](C:\Users\ATLAS\AppData\Roaming\Typora\typora-user-images\1602426160517.png)



### 2 Log4j

面向百度编程 学习思路：什么是这个东西？通过学习我们明白了就这些就达到目标了。

什么是Log4j：

- Log4j是[Apache](https://baike.baidu.com/item/Apache/8512995)的一个开源项目，通过使用Log4j，我们可以控制日志信息输送的目的地是[控制台](https://baike.baidu.com/item/控制台/2438626)、文件、[GUI](https://baike.baidu.com/item/GUI)组件
- 我们也可以控制每一条日志的输出格式
- 通过定义每一条日志信息的级别，我们能够更加细致地控制日志的生成过程。
- 通过一个[配置文件](https://baike.baidu.com/item/配置文件/286550)来灵活地进行配置，而不需要修改应用的代码。



1. 先导入log4j的包

2. log4j.properties

   ```properties
   # priority  :debug<info<warn<error
   #you cannot specify every priority with different file for log4j
   
   log4j.rootLogger=debug,stdout,info,debug,warn,error 
   
   #console
   
   log4j.appender.stdout=org.apache.log4j.ConsoleAppender 
   log4j.appender.stdout.layout=org.apache.log4j.PatternLayout 
   log4j.appender.stdout.layout.ConversionPattern= [%d{yyyy-MM-dd HH:mm:ss a}]:%p %l%m%n
   
   #info log
   
   log4j.logger.info=info
   
   log4j.appender.info=org.apache.log4j.DailyRollingFileAppender 
   
   log4j.appender.info.DatePattern='_'yyyy-MM-dd'.log'
   
   log4j.appender.info.File=./log/chennq.log
   
   log4j.appender.info.Append=true
   
   log4j.appender.info.Threshold=INFO
   
   log4j.appender.info.layout=org.apache.log4j.PatternLayout 
   
   log4j.appender.info.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss a} [Thread: %t][ Class:%c >> Method: %l ]%n%p:%m%n
   
   #debug log
   
   log4j.logger.debug=debug
   
   log4j.appender.debug=org.apache.log4j.DailyRollingFileAppender 
   
   log4j.appender.debug.DatePattern='_'yyyy-MM-dd'.log'
   
   log4j.appender.debug.File=./src/com/hp/log/debug.log
   
   log4j.appender.debug.Append=true
   
   log4j.appender.debug.Threshold=DEBUG
   
   log4j.appender.debug.layout=org.apache.log4j.PatternLayout 
   
   log4j.appender.debug.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss a} [Thread: %t][ Class:%c >> Method: %l ]%n%p:%m%n
   
   #warn log
   
   log4j.logger.warn=warn
   
   log4j.appender.warn=org.apache.log4j.DailyRollingFileAppender 
   
   log4j.appender.warn.DatePattern='_'yyyy-MM-dd'.log'
   
   log4j.appender.warn.File=./log/chennq/warn.log
   
   log4j.appender.warn.Append=true
   
   log4j.appender.warn.Threshold=WARN
   
   log4j.appender.warn.layout=org.apache.log4j.PatternLayout 
   
   log4j.appender.warn.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss a} [Thread: %t][ Class:%c >> Method: %l ]%n%p:%m%n
   
   #error
   
   log4j.logger.error=error
   
   log4j.appender.error = org.apache.log4j.DailyRollingFileAppender
   
   log4j.appender.error.DatePattern='_'yyyy-MM-dd'.log'
   
   log4j.appender.error.File = ./log/chennq/error.log 
   
   log4j.appender.error.Append = true
   
   log4j.appender.error.Threshold = ERROR 
   
   log4j.appender.error.layout = org.apache.log4j.PatternLayout
   
   log4j.appender.error.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss a} [Thread: %t][ Class:%c >> Method: %l ]%n%p:%m%n
   
   ```

3. 配置log4j为日志实现

   ```xml
   <settings>
           <setting name="logImpl" value="LOG4J"/>
   </settings>
   
   ```

4. log4j的使用，直接测试刚才的查询

**简单使用**

1. 在要使用Log4j的类中，导入包 import org.apache.log4j.Logger;

2. 日志对象，参数为当前类的class

   ```java
   static Logger logger = Logger.getLogger(UserMapperTest.class);
   
   ```

3. 日志级别

   ```java
   logger.info("info：进入testLog4j");
   logger.debug("debug：进入testLog4j");
   logger.error("error：进入testLog4j");
   
   ```

   

## 7、分页

为什么要分页?

- 减少数据的处理量

使用Limit分页（从第几个开始查，显示几个）  ，如果只有一个参数，就表示显示几个。

```sql
select * from user limit startIndex,pageSize;

```

使用mybatis实现分页，核心SQL

1. 接口
2. Mapper.xml
3. 测试



## 8、使用注解开发

除了mybatis，其它开发大多使用注解开发。

### 1 面向接口编程

- 我们学过面向对象编程，也学过接口，在实际的开发中，很多时候我们选择面向接口编程。
- 根本原因：**解耦**，可拓展，提高服用，分层开发中，上层不用管具体的实现，大家都遵守共同的标准，使开发变得容易，规范性更好。



接口更深层次的理解：定义（规范、约束）与实现（名实分离的原则）的分离。

接口应该有两类：

- 第一类是对一个个体的抽象，它可以对应位一个抽象体（abstract class）
- 第二类是对一个个体某一方面的抽象，即形成一个抽象面（interface）
- 个体可能有多个抽象面，抽象体与抽象面是有区别的。



### 2 使用注解开发







## 9、Lombok

- Java library
- plugs
- build tools
- with one annotation

使用步骤：

1. idea 安装Lombok
2. 导入lombok的包
3. 在实体类上加注解

```
@Getter and @Setter    *****
@FieldNameConstants
@ToString              *****
@EqualsAndHashCode     *****
@AllArgsConstructor    *****
	@RequiredArgsConstructor 
	@NoArgsConstructor *****
@Log, @Log4j, @Log4j2, @Slf4j, @XSlf4j, @CommonsLog, @JBossLog, @Flogger, @CustomLog
@Data                  *****
@Builder
@SuperBuilder
@Singular
@Delegate
@Value
@Accessors
@Wither
@With
@SneakyThrows
@val
@var
experimental @var
@UtilityClass
Lombok config system

```

@Data：无参构造、get、set、hashcode、equals、toString



显示的定义了有参构造后，无参定义也就没了

```
@Data
@AllArgsConstructor
@NoArgsConstructor

```





持续更新中！！！




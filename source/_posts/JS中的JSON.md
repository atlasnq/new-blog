---
title: JS中的JSON
copyright: true
date: 2019-06-20 01:29:18
tags: [Web前端,JavaScript,学习笔记]
categories: JavaScript
comments: true
urlname:  JavaScript_2
---



{% cq %}本篇介绍JS中JSON数据的格式以及转换。 {% endcq %}

<!--more-->



## 概述

- json是 JavaScript Object Notation 的首字母缩写，单词的意思是javascript对象表示法，这里说的json指的是类似于javascript对象的一种数据格式。

- json的作用：在不同的系统平台，或不同编程语言之间传递数据。



## json数据的语法

json数据对象类似于JavaScript中的对象，但是它的键对应的值里面是没有函数方法的，值可以是普通变量，不支持undefined，值还可以是数组或者json对象。

```js
// 原生的js的json对象
var obj = {
  age:10,
  sex: '女',
  work:function(){
    return "好好学习",
  }
}
    
// json数据的数组格式：
["tom",18,"programmer"]
// 复杂的json格式数据可以包含对象和数组的写法。
    
{
  "name":"小明",
  "age":200,
  "is_delete": false,
  "fav":["code","eat","swim","read"],
  "son":{
    "name":"小小明",
    "age":100,
    "lve":["code","eat"]
  }
}
```

总结：

```json
1. json文件的后缀是.json
2. json文件一般保存一个单一的json数据
3. json数据的属性不能是方法或者undefined，属性值只能：数值[整数,小数,布尔值]、字符串、json和数组
4. json数据只使用双引号、每一个属性成员之间使用逗号隔开，并且最后一个成员没有逗号。
   {
      "name":"小明",
      "age":200,
      "fav":["code","eat","swim","read"],
      "son":{
        "name":"小小明",
        "age":100
      }
    }
```



## json数据转换方法

javascript提供了一个JSON对象来操作json数据的数据转换.

| 方法      | 参数     | 返回值   | 描述                             |
| --------- | -------- | -------- | -------------------------------- |
| stringify | json对象 | 字符串   | json对象转成字符串               |
| parse     | 字符串   | json对象 | 字符串格式的json数据转成json对象 |



```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<script>
    // json语法
    let humen = {
        "username":"xiaohui",
        "password":"1234567",
        "age":20
    };

    console.log(humen);
    console.log(typeof humen);
    console.log('-------------');

    // JSON对象提供对json格式数据的转换功能
    // stringify(json对象)  # 用于把json转换成字符串
    let result = JSON.stringify(humen);
    console.log(result);
    console.log(typeof result);
    console.log('-------------');

    // parse(字符串类型的json数据)  # 用于把字符串转成json对象
    let json_str = '{"password":"1123","age":20,"name":"xiaobai"}';
    console.log(json_str);
    console.log(typeof json_str);
    console.log('-------------');

    let json_obj = JSON.parse(json_str);
    console.log(json_obj);
    console.log(typeof json_obj);

    console.log(json_obj.age)
</script>
</body>
</html>
```




---
title: Web前端-bootstrap
date: 2019-06-20 22:49:08
tags: [Web前端,bootstrap,学习笔记]
categories: bootstrap
comments: true
urlname:  bootstrap_1
copyright: true
---



{% cq %}本篇介绍bootstrap。 {% endcq %}

<!--more-->



# 导入

- 对于 `js` 放在 `script` 标签内，但在导入bootstrap的js之前得先导入jQuery，bootstrap是建立在jQuery之上的。

- 对于 `css` 放在 `link` 标签内导入。

```js
<script src="/static/js/jquery.min.js"></script>
<link rel="stylesheet" href="/static/plugins/bootstrap-3.3.7/css/bootstrap.css">
<script src="/static/plugins/bootstrap-3.3.7/js/bootstrap.js"></script>
```





# 使用经验

①

在设置了 form-control 后（如select），虽然有了bootstrap的样式，但它却占满一行，我们需要在父盒子中设置 form-inline 来让这个块级元素变成行内元素。



②

设置 pull-right  就可以是该盒子向右浮动，但是这个浮动后的位置是依赖于父盒子的。


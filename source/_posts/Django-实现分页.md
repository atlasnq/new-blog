---
title: Django-实现分页
copyright: true
date: 2019-07-17 21:38:29
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_13_Paginator
---



{% cq %}在展示数据的时候，分页是一个不可或缺的的功能，本篇在Django中实现分页并封装成类，方便以后使用。 {% endcq %}

<!--more-->

通过这篇文章，你能了解到：

- 自定义分页的流程
- 可重用的分页代码





## 流程

1. 整个流程是从当前页码（page）开始，页码决定了数据的开头结尾，所以有了它我们可以将数据分页展示；

2. 接下来设计页码，对于页码来说，想得到它的开头结尾，这样页码的数量将是固定的（max_show）

3. 将页码在后端生成html

4. 将整个流程定义到类中

5. 实例化将封装当前页码、页码起始、页码结尾、数据起始、数据结尾等。

6. 调用方法get_html将生成的页码html返回给前端。

- 在前面的基础中加上了对搜索的支持

1. 对于查询参数，我们需要将它们保存到链接中，这样才能去下一页。



## 实现代码

```python
from django.utils.safestring import mark_safe
from django.http.request import QueryDict


class Pagenation:
    def __init__(self, page, data_length, querydict=None, max_show=9, max_page=10, ):
        '''
        :param page: 当前页码
        :param data_length: 一共有多少条数据
        :param max_show:  最多显示多少页码
        :param max_page: 每页最多几条数据
        '''
        try:
            page = int(page)
            if page <= 0:
                page = 1
        except Exception:
            page = 1

        if not querydict:
            querydict = QueryDict(mutable=True)
        self.querydict = querydict

        # 页码最大显示个数
        self.max_show = max_show
        # 页码一半
        half_show = max_show // 2

        # 每页最大显示数据条数
        self.max_page = max_page
        # 页面总数
        page_count, more = divmod(data_length, max_page)
        self.page_count = page_count + 1 if more > 0 else page_count

        if page_count >= max_show:
            # 页码的起始
            if page - half_show <= 0:
                # 当左边超过边界
                page_start = 1
                page_end = max_show
                if page <= 0:
                    page = 1
            elif page + half_show >= page_count:
                # 当右边超过边界
                page_end = page_count
                page_start = page_count - max_show + 1
                if page > page_count:
                    # 当页码超过边界时，以当前页设为最后一页
                    page = page_count
            else:
                # 正常情况()
                page_start = page - half_show
                # 页码的结尾
                page_end = page + half_show
        else:
            # 总页码不够，所以不用显示那么多的页码
            page_start = 1
            page_end = self.page_count

        # 封装属性
        self.page = page
        self.page_start = page_start
        self.page_end = page_end
        # 取多少条数据
        self.start = (self.page - 1) * self.max_page
        self.end = self.page * self.max_page

    def get_html(self):
        # 显示的数据的起点/终点
        li_html = []
        if self.page == 1:
            self.querydict['page'] = 1
            li_html.append(
                f'<li class="disabled"><a href="？{self.querydict.urlencode()}"><span aria-hidden="true">&laquo;</span></a></li>')
        else:
            self.querydict['page'] = self.page - 1
            li_html.append(
                f'<li><a href="?{self.querydict.urlencode()}"><span aria-hidden="true">&laquo;</span></a></li>')
        for i in range(self.page_start, self.page_end + 1):
            self.querydict['page'] = i
            if i == self.page:
                li_html.append(f'<li class="active"><a href="?{self.querydict.urlencode()}">{i}</a></li>')
            else:
                li_html.append(f'<li><a href="?{self.querydict.urlencode()}">{i}</a></li>')
        if self.page == self.page_count:
            self.querydict['page'] = self.page_count
            li_html.append(
                f'<li class="disabled"><a href="?{self.querydict.urlencode()}"><span aria-hidden="true">&raquo;</span></a></li>')
        else:
            self.querydict['page'] = self.page + 1
            li_html.append(
                f'<li><a href="?{self.querydict.urlencode()}"><span aria-hidden="true">&raquo;</span></a></li>')
        page_html = ' '.join(li_html)
        return mark_safe(page_html)

```

- 在调用中，只需要使用数据的开始位置，结束位置以及下面分页。

```python
# views.py
data = [("小强", f"{i}号") for i in range(1, 315)]

from utils.pagenation import Pagenation

def show(request):
    page_obj = Pagenation(request.GET.get('page',1),len(data))   
    return render(request, 'pagenation.html', {'data': data[page_obj.start:page_obj.end], 'page_html':page_obj.get_html})
```


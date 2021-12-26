---
title: Django-modelformset
copyright: true
date: 2019-07-24 00:40:43
tags: [Web前端,django,学习笔记]
categories: django
comments: true
urlname:  django_15_modelformset
---



{% cq %} modelformset可以让我们批量操作form/modelform。 {% endcq %}

<!--more-->

通过这篇文章，你能了解到：

- 使用 `modelformset_factory()` 创建表单



##  使用函数modelformset_factory()创建表单

`views.py` 内容如下：

```python
from django.forms.models import modelformset_factory
    FormSet = modelformset_factory(model=models.StudyRecord, form=StudyRecordForm, extra=0)
    # extra=0 表示不会额外增加一条
    queryset = models.StudyRecord.objects.filter(course_record_id=course_id)
    formset_obj = FormSet(queryset=queryset[page_obj.start:page_obj.end])
    # 接下来的用法同modelform
    if request.method == 'POST':
        formset_obj = FormSet(data=request.POST)
        if formset_obj.is_valid():
            formset_obj.save()
             return HttpResponse('ok')
        return HttpResponse('error')
   	return render(request, 'study_record_list.html',{'formset': formset_obj})
```



`study_record_list.html` 内容如下：

```html
<form action="" method="post">
    {% csrf_token %}
    {{ formset.management_form }}

    <div class="panel-body">
        <table class="table">
            <thead>
                <tr>
                    <th>序号</th>
                    <th>课程</th>
                    <th>学员</th>
                    <th>考勤</th>
                    <th>本节成绩</th>
                    <th>作业文件</th>
                </tr>
            </thead>
            <tbody>
                {% for field in formset %}
                <tr>
                    <td>{{ forloop.counter }}</td>
                    <td>{{ field.course_record }}</td>
                    <td>{{ field.student }}</td>
                    <td>{{ field.attendance }}</td>
                    <td>{{ field.score }}</td>
                    <td>{{ field.homework }}</td>
                    <td class="hidden">{{ field.id }}</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        <button class="btn btn-warning center-block">提交</button>           
    </div>
</form>
```

但是在渲染的时候，我们需要加入   `formset.management_form` 值 以及当我们自定义输出 field 的时候我们需要手动加上主键  `field.id`



其它用法：

待补充！！！！
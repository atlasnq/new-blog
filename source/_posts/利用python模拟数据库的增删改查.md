---
title: 利用python模拟数据库的增删改查
date: 2019-04-8 21:26:02
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-simulate-database-operation
copyright: true
---



{% cq %}本篇利用python以及使用re模块来完成数据库中表的增删查改。希望将来可以在进行扩展。以下是要求，以及源码。 {% endcq %}

<!-- more -->

--------



要求：

```
由于只有一个表，所以只能在这个表中进行操作
可以进行对员工信息表的内容进行增、删、查、改
增： INSERT VALUES(值1，值2，...)
查： SELECT * WHERE age > 20
改： SET name = 'sb' WHERE id = 1
删： DELETE WHERE id = 1
```

使用了re正则模块，进行字符串的匹配，增加容错能力。

```
import re
import os
import sys
BASE_PATH = os.path.dirname(__file__)
sys.path.append(os.path.dirname(BASE_PATH))
from core import home_page
from config import settings

exp1 = 'select name, age where age>22  '
exp2 = 'select * where job=IT  '
exp3 = 'select * where phone like 133'

def func_title(li,r1,title):
    '''为查询结果添加列名'''         # 重复率太高了
    l2 = []
    if ',' in r1:  # 多个列
        l1 = r1.strip().split(',')
        for j in l1:
            l2.append(j)
        li.append(l2)
        return li
    elif '*' in r1:  # 所有列
        for j in title:
            l2.append(j.strip())
        li.append(l2)
        return li
    else:   # 一个列
        l2.append(r1)
        li.append(l2)
        return li

def filter_sub(li,r1,dic_f):
    '''对于列名的处理有三种情况：单个列名，多个列名，所有列名'''
    if ',' in r1:
        l1 = r1.strip().split(',')
        for j in l1:
            li.append(dic_f[j.strip()])
        return li
    elif '*' in r1:
        for j in dic_f.values():
            li.append(j.strip())
        return li
    else:
        li.append(dic_f[r1])
        return li

def func_filter(li,dic_f,r1,r2,r3,r4):
    '''where条件后的判断方式 > < , = '''
    if r3 == '>':
        if float(dic_f[r2]) > float(r4):
            return filter_sub(li, r1, dic_f)
        else:
            return li

    elif r3 == '<':
        if float(dic_f[r2]) < float(r4):
            return filter_sub(li, r1, dic_f)
        else:
            return li
    elif r3 == '=':
        #     # 先确定 where条件后的判断方式 > < =  ，接下来确定 该项留不留下,做成函数，返回True or False，   第三步：该项输出的内容
        if dic_f[r2] == r4:
            return filter_sub(li,r1,dic_f)
        else:
            return li

    elif r3 == 'like':
        if r4 in dic_f[r2] :
            return filter_sub(li, r1, dic_f)
        else:
            return li

def func_select(exp):
    '''
    模拟数据库查询select操作，支持：大于小于等于，还要支持模糊查找。
    '''
    exp = exp.strip()
    pa = '[sS][eE][lL][eE][cC][tT]\s+(\w+(?:,\s*\w+)*|[*])\s+(?:from\s+\d+\s+)?[wW][hH][eE][rR][eE]\s+(\w+)(?:\s*([><])\s*|\s*([=])\s*|\s+([lL][iI][kK][eE])\s+)(\w+)\s*$'
    ret = re.match(pa, exp)
    if ret:
        r1 = ret.group(1).strip()        # name, age   # 最终显示的项
        r2 = ret.group(2).strip()        # 比较的条件1
        r3 = list(filter(lambda x:x,[ret.group(3),ret.group(4),ret.group(5)]))[0].strip()   #ret.group(3) ，4，5 分别为 >< , = , like。从中选一个当作r3
        r4 = ret.group(6).strip()        ## 比较的条件2
        with open(settings.USER_INFO_PATH, encoding='utf-8') as f:
            title = f.readline().strip().split(',')
            li = []
            li = func_title(li,r1,title)

            for i in f:
                l1 = []
                dic_f = {k: '' for k in title}
                lis_f = i.strip().split(',')
                for j, k in zip(dic_f, lis_f):
                    dic_f[j] = k
                # print(dic_f)
                l1 = func_filter(l1,dic_f,r1,r2,r3,r4)
                if l1:li.append(l1)
        if li:
            for i in li:
                for j in i:
                    print('\t'+ j+ '\t',end='')
                print()

        else:
            print('信息不存在！')
    else:
        print('查询语句有误')


def insert_sub(l1):
    with open(settings.USER_INFO_PATH, encoding='utf-8', mode='r+') as f:
        title = f.readline().strip().split(',')
        # print(title)
        if len(title)>2:
            for i in f:
                l2 = i.strip()
            l2 = l2.split(',')  # 使用最后一次的id
            if len(l1) + 1 == len(title):
                content = '\n' + str(int(l2[0])+1) + ','
                for i in l1:
                    content = content + i.strip() + ','
                content = content.strip(',')
                f.write(content)
                print('添加成功！')
            else:
                print('输入的值的数量不对应')
        else:
            print('输入的值的数量不对应')

def func_insert(exp):
    '''模拟数据库inset操作'''
    exp = exp.strip()
    pa = '[iI][nN][sS][eE][rR][tT]\s+(?:into\s+\w+\s+)?values\s*[(]\s*(\w+\s*(?:[,，]\s*\w+\s*)*)[)]$'

    # 支持两种方式：INSERT INTO 表名称 VALUES (值1, 值2,....)   INSERT INTO table_name (列1, 列2,...) VALUES (值1, 值2,....)
    ret = re.match(pa, exp)
    if ret:
        print(ret.group(0))
        print(ret.group(1))
        r1 = ret.group(1).strip()
        if ',' in r1:
            l1 = r1.split(',')
            # print(l1)
            # 多个元素
            insert_sub(l1)
        else:
            # 单个元素
            insert_sub(r1)
    else:
        print('增加语句有误')


def func_modify(exp):
    '''模拟数据库的改操作set'''
    exp = exp.strip()
    pa = "[sS][eE][tT]\s+((?:(?:\w+)\s*=\s*'?(?:\w+)\s+'?)+)\s*[wW][hH][eE][rR][eE]\s+(id)\s*(=)\s*(\d+)"
    ret = re.match(pa,exp)
    if ret:
        # print(ret.group(1))
        # print(ret.group(2))
        # print(ret.group(3))
        # print(ret.group(4))
        r1 = ret.group(1)       # name = atlas job = ce phone = 1345        name=atlas job=ce phone=1345
        r2 = ret.group(2)       # id
        r3 = ret.group(3)       # =
        r4 = ret.group(4)       # 4
        pa2 = '\s*(\w+)\s*=\s*(\w+)\s*'
        r5 = re.findall(pa2,r1)
        print(r5)
        with open(settings.USER_INFO_PATH, encoding='utf-8')as f1 ,\
             open(settings.USER_INFO_PATH+'.swap',encoding='utf-8',mode='w') as  f2 :
                title = f1.readline().strip().split(',')
                f2.write(','.join(title)+'\n')
                for i in f1:
                    dic_f = {k: '' for k in title}
                    lis_f = i.strip().split(',')
                    for j, k in zip(dic_f, lis_f):
                        dic_f[j] = k
                    if dic_f['id'] == r4:
                        for j in r5:
                            dic_f[j[0]] = j[1]
                        cont = ''
                        for k in dic_f.values():
                            cont = cont + k + ','
                        cont = cont.strip(',')
                        f2.write(cont+'\n')
                    else:
                        f2.write(i)
                print('修改成功！')
        os.remove(settings.USER_INFO_PATH)
        os.rename(settings.USER_INFO_PATH+'.swap',settings.USER_INFO_PATH)

    else:
        print('SQL语句输入错误！')


def func_del(exp):
    '''模拟数据库的删除操作delete'''
    exp = exp.strip()
    pa = '\s*[dD][eE][lL][eE][tT][eE]\s+[wW][hH][eE][rR][eE]\s+id\s*=\s*(\d+)'
    ret = re.match(pa, exp)
    if ret:
        r1 = ret.group(1)  # id = (6) 因为只有一个表，而id是这个表的主键，所以我们把主键默认为id去进行匹配
        print(r1)
        with open(settings.USER_INFO_PATH, encoding='utf-8')as f1, \
                open(settings.USER_INFO_PATH+'.swap', encoding='utf-8', mode='w') as  f2:
            title = f1.readline().strip().split(',')
            f2.write(','.join(title) + '\n')
            for i in f1:
                dic_f = {k: '' for k in title}
                lis_f = i.strip().split(',')
                for j, k in zip(dic_f, lis_f):
                    dic_f[j] = k
                if dic_f['id'] == r1:
                    pass  # 找到待删除的id，就把这条记录丢下。
                else:
                    f2.write(i)
            print('修改成功！')
        os.remove(settings.USER_INFO_PATH)
        os.rename(settings.USER_INFO_PATH+'.swap', settings.USER_INFO_PATH)
    else:
        print('SQL语句输入错误！')

def run():
    '''程序入口'''
    home_page.home()
    flag = True
    while flag:
        choose = input(' 请输入SQL语句>>> ')
        pat2 = '[iI][nN][sS][eE][rR][tT]'
        if re.findall('[sS][eE][lL][eE][cC][tT]',choose):
            # 执行查询操作
            func_select(choose)
        elif re.findall('[iI][nN][sS][eE][rR][tT]',choose):
            # 执行增加操作
            func_insert(choose)
        elif re.findall('[sS][eE][tT]',choose):
            # 执行修改操作
            func_modify(choose)
        elif re.findall('[dD][eE][lL][eE][tT][eE]',choose):
            # 执行删除操作
            func_del(choose)
        else:
            print('输入的SQL语句有误')
        conti = input('Q/q退出,其他键继续 ')
        print()
        if conti.upper() == 'Q':flag = False



if __name__ == '__main__':
    run()
```
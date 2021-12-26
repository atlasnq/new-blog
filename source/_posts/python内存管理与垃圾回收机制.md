---
title: python内存管理与垃圾回收机制
copyright: true
date: 2019-10-29 22:01:01
tags: [python,学习笔记]
categories: python学习
comments: true
urlname: python-memory-management-garbage-collection
---



{% cq %} 本篇介绍Python内存管理以及垃圾回收机制 {% endcq %}


<!--more-->

文章脉络：

- 底层C的实现 ——> python的内存管理机制 ——> 垃圾回收机制

## 底层

python是由C开发的，在python中我们常常提到的一句话是“**一切皆对象**”，那么这个对象在C中是怎样体现的呢？接下来我们慢慢道来

### 三个重要的结构体

- 打开python源文件目录，在include这个目录中，`Object.h` 中放着具体实现。

- 在include目录下 object.h 找到 PyObject 的定义

  ```C
  /* Define pointers to support a doubly-linked list of all live heap objects. */
  #define _PyObject_HEAD_EXTRA            \
      struct _object *_ob_next;           \
      struct _object *_ob_prev;
  
  #define PyObject_HEAD          PyObject ob_base;
  #define PyObject_VAR_HEAD      PyVarObject ob_base;
  
  typedef struct _object {
      _PyObject_HEAD_EXTRA   /* 用于构造双向链表 */
      Py_ssize_t ob_refcnt;  /* 引用计数器，Py_ssize_t是int、long或long long的别名 */
      struct _typeobject *ob_type;  /* 数据类型，它指向的是一个PyTypeObject，PyTypeObject是用来指定一个对象类型的类型对象。在对象建立之前，对象元信息必须存在。 */
  } PyObject;
  
  
  typedef struct {
      PyObject ob_base;   /* PyObject对象 */
      Py_ssize_t ob_size; /* Number of items in variable part 指定容器中包含的元素数量 */
  } PyVarObject;

  /* ps：
  PyObject ob_base;          这句也相当于宏定义中的 PyObject_HEAD 
  #define PyObject_HEAD      PyObject ob_base;
  */
  
  typedef struct _typeobject {
      PyObject_VAR_HEAD
      const char *tp_name; /* For printing, in format "<module>.<name>" 类型的名称 */
      Py_ssize_t tp_basicsize, tp_itemsize; /* For allocation 创建该类型对象时分配的内存大小信息 */
      
      ......
  	/* Method suites for standard classes */
      // 标准类方法集
      PyNumberMethods *tp_as_number;  // 数值对象操作
      PySequenceMethods *tp_as_sequence;  // 序列对象操作
      PyMappingMethods *tp_as_mapping;  // 字典对象操作
      ......
          
  } PyTypeObject;
  ```
  
- 对于`PyObject`，在Python内部，每一个对象都拥有相同的对象头部，也就使得对对象的引用变得非常统一，**我们只需要用一个`PyObject*` 指针就可以引用任意一个对象，而不论该对象实际上是一个什么对象**。

- 对于 `PyVarObject`，它是`PyObject`的扩展，对于任何一个`PyVarObject`所占用的内存，开始部分的字节的意义和`PyObject`是一样的

- 对于 `PyTypeObject`，它决定对象的类型，这也是python是动态语言的原因，不需要声明，但我的内部已经携带了类型的标识



### 获取这3个成员的值

```c
#define Py_REFCNT(ob)           (((PyObject*)(ob))->ob_refcnt)
#define Py_TYPE(ob)             (((PyObject*)(ob))->ob_type)
#define Py_SIZE(ob)             (((PyVarObject*)(ob))->ob_size)
```

- 通过宏来获取属性，使用 PyObject 来强制转换 ob 后拿到它的引用 ob_refcnt 、 ob_type 、ob_size

### 关于引用计数

```c
#define Py_INCREF(op) (                         \
    _Py_INC_REFTOTAL  _Py_REF_DEBUG_COMMA       \
    ((PyObject *)(op))->ob_refcnt++)

#define Py_DECREF(op)                                   \
    do {                                                \
        PyObject *_py_decref_tmp = (PyObject *)(op);    \
        if (_Py_DEC_REFTOTAL  _Py_REF_DEBUG_COMMA       \
        --(_py_decref_tmp)->ob_refcnt != 0)             \
            _Py_CHECK_REFCNT(_py_decref_tmp)            \
        else                                            \
            _Py_Dealloc(_py_decref_tmp);                \
    } while (0)
```

- 宏 Py_INCREF(op) 和Py_DECREF(op) 用于增加或减少引用计数，当refcount降为0时，py_decf 调用对象的 deallocator 函数;

- 宏 _Py_NewReference(op) 将引用计数器初始化为1
- ps：上面使用宏实现了编译时的多态



### 基础数据类型的分类

- 在python中所有东西创建对象的时候，内部都会存储一个数据。
- 如果由多个元素组成，内部会在多维护一个 ob_size

```
PyObject: float
PyVarObject: list/dict/set/tuple/str(C语言中只有char)/int(py2中是上面，py3后long，不限制长度)/bool（bool本质是int）
```



## 内存管理机制

```
在创建对象时，如：
	v = 0.3
    源码内部：
        a.开辟内存：malloc 
        b.数据的初始化：
            ob_fval = 0.3
            ob_type = float
            ob_refcnt = 1 
        c.将结构体加入到双向链表中  ref_chain
    
    name = v
    源码内部：
    	ob_refcnt ++ 引用计数器加1
    
    del v
    源码内部：
    	ob_refcnt -- 引用计数器减1
    
    def func(arg):
    	print(123)
    func(name)
    源码内部：    	
    	刚进去：ob_refcnt ++ 引用计数器加1
    	执行完：ob_refcnt -- 引用计数器减1
	
	del name
	源码内部：
    	ob_refcnt -- 引用计数器减1
    	每次引用计数器减1时，检查是否以为0，如果是0，则认为是垃圾，对其进行回收

	其它情况：
	v = 0.3
	name = v 
	id(v)
	del v 
	del name
	c = 0.99
	id(c)
	这两个的id是相同的！因为有缓存。只要是同类型的，做了缓存后，再次用的话，都是使用相同的那个结构体。
	按理说应该销毁！！！，但是缓存机制会将做一个缓存！！！
	如对于float类型，它放到一个单向链表 free_list （最长100个） 中，如果以后在创建相同类型的话，就先去找一找，重新做一步初始化，这样不用频繁开辟空间/析构了
```

- 在创建对象时，每个对象至少内部有4个值：双向链表/ob_refcnt/ob_type，之后会对内存中的数据进行初始化，初始化本质：引用计数器=1，赋值。然后将结构体添加到双向链表中refchain。
- 以后再有其它变量指向这个内存，则让引用计数器 + 1，如果销毁某个变量，则找到它指向的内存，将其引用计数器 - 1.
- 引用计数器如果为0，则进行垃圾回收。
- 在内部可能存在缓存机制，例如：float  /list/int(小数据池？-257)，录入float最开始不会真正销毁，而放在free_list的链表中，以后再创建同类型的数据时，会先去链表中取出结构体，然后再对结构体进行初始化（100/80）



## 垃圾回收机制

**引用计数为主，标记清除和分代回收为辅。**

### 引用计数

- 上面我们提到了引用计数，但是对于容器类型（列表、字典、集合、对象等）会出现**循环引用问题** 

  ```python
  a = [1,2]
  b = [5,6]
  a.append(b)   # b 的计数器为2
  # b 发生变化了（多了一个指向） （a指向的内存不变）	
  b.append(a)  
  del a
  del b
  ```

### 标记清除

- 针对容器类的对象，再python中会将它们单独放到一个（总共3个 0 1 2 共3代）双向链表中，做定期的扫描，检查是否有循环引用，如果有，引用计数各自-1，如果-1之后等于0，则直接回收。
- 扫描10次后，如果没有出现的话，将放到下一个列表中



### 分代回收

- 解决扫描的时候，少扫描结构体，将没有问题的结构体放到上一级链表中，默认下一级扫描10次，上一代才扫描1次，总共有3代。
- 3个链表处理容器，一个链表处理非容器（float）



## 小结

1. “一切皆对象”的本质在于 **PyObject**（PyVarObject是对PyObject的扩展），只需要一个`PyObject*` 指针就可以引用任意一个对象，而不论该对象实际上是一个什么对象。
2. 引用计数对于容器类对象存在循环引用问题，通过标记清除来解决，为了提交效率，使用分代回收来降低扫描频率
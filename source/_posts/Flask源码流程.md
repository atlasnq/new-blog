---
title: Flask源码流程
copyright: true
date: 2019-12-15 17:48:04
tags: [Web前端,Flask,学习笔记]
categories: Flask
comments: true
urlname:  flask_6
---



{% cq %} 本篇介绍Flask的启动流程与请求处理流程 {% endcq %}

<!--more-->

# Flask流程

先把结果列出来：

```
参考简化后的web服务器实现思路，socket建立后，监听recv导的请求信息并解析，然后调用响应的app.route对应的view.func整个流程大致分为两部分（项目启动，处理请求）：
1. app -> werkzeug -> http -> socket 启动端口监听，注册各种方法；
2. socket recv到请求 -> 初始化 RequestHandlerClass -> 调用 Flask.__call__，wsgi_app在请求上下文中执行预处理方法（before request）、视图方法、后响应方法（after request）

```



下面是一个很简单的flask例子，通过它我们将理解Flask的处理流程。

## Flask启动流程

我们先编写一个简单的Flask项目，右键运行。

点击查看 `Flask(__name__)`的源码； 点击查看 `app.run() ` 源码

```python
from flask import Flask,globals

# 1.实例化Flask对象，执行Flask类的 __init__ 方法
app = Flask(__name__)


@app.route('/index') # 2.执行app的route方法(将路由与视图函数进行匹配)
def index():
    return 'index'

if __name__ == '__main__':
    # 3.创建服务
    app.run()    
```



路由处理：

1. 在Map中通过url获取endpoint
2. 在self.view_funcs 中使用endpoint为key获取视图函数。



👇在下面这段源码中，

```
__init__

self.config = {默认配置}
self.view_functions = {}
self.before_reqeust_funcs = {}
self.before_first_reqeust_funcs = []
self.after_reqeust_funcs = {}


```



👇在下面这段源码中，通过werkzeug.serving的run_simple函数来进行启动Server ，在这个函数中，将会执行inner函数，接着点击进入inner中的make_server。

```python
    # flask/app.py
    def run(self, host=None, port=None, debug=None, load_dotenv=True, **options):
        """
        使用本地开发服务器来启动应用.
        """
       	......省略

        from werkzeug.serving import run_simple

        try:
            run_simple(host, port, self, **options)
        finally:  
            self._got_first_request = False
```

👇在下面这段源码中，将创建一个服务器实例。接着点击进入BaseWSGIServer(单进程的server)

```python
# werkzeug/serving.py
def make_server(
    host=None,
    port=None,
    app=None,
    threaded=False,
    processes=1,
    request_handler=None,
    passthrough_errors=False,
    ssl_context=None,
    fd=None,
):
    ......
        return BaseWSGIServer(
            host, port, app, request_handler, passthrough_errors, ssl_context, fd=fd
        )

```

👇在下面这段源码中，封装了处理请求类（WSGIRequestHandler），调用了HTTPServer的初始化。点击进入HTTPServer

```python
class BaseWSGIServer(HTTPServer, object):
    """简单的单线程，单进程WSGI服务器
    """

    multithread = False
    multiprocess = False
    request_queue_size = LISTEN_QUEUE

    def __init__(
        self,
        host,
        port,
        app,
        handler=None,
        passthrough_errors=False,
        ssl_context=None,
        fd=None,
    ):
        # 封装了处理请求类
        if handler is None:
            handler = WSGIRequestHandler

        ......省略
        
        # 调用了HTTPServer的初始化，将服务器地址和WSGIRequestHandler传入
        HTTPServer.__init__(self, server_address, handler)

        self.app = app   # 封装了 Flask 对象
        self.passthrough_errors = passthrough_errors
        self.shutdown_signal = False
        self.host = host
        self.port = self.socket.getsockname()[1]

        #socket，ssl相关的
```

👇在下面这段源码中，将调用TCPServer的初始化方法，点击进入TCPServer

```python
# Lib/http/server.py
class HTTPServer(socketserver.TCPServer):

    allow_reuse_address = 1    # Seems to make sense in testing environment

    def server_bind(self):
        """Override server_bind to store the server name."""
        socketserver.TCPServer.server_bind(self)
        host, port = self.server_address[:2]
        self.server_name = socket.getfqdn(host)
        self.server_port = port
```

👇在下面这段源码中，将执行BaseServer的初始化，这样一个服务器实例就创建好了

```python
# Lib/socketserver.py
class TCPServer(BaseServer):

    address_family = socket.AF_INET
    socket_type = socket.SOCK_STREAM
    request_queue_size = 5
    allow_reuse_address = False

    def __init__(self, server_address, RequestHandlerClass, bind_and_activate=True):
        """Constructor.  May be extended, do not override."""
        # 执行BaseServer的初始化，将服务器地址和WSGIRequestHandler传入
        BaseServer.__init__(self, server_address, RequestHandlerClass)
        self.socket = socket.socket(self.address_family,
                                    self.socket_type)
        if bind_and_activate:
            try:
                # 绑定端口
                self.server_bind()
                self.server_activate()
            except:
                self.server_close()
                raise
```

👇 make_server执行结束后，实现了HTTPServer和BaseServer的初始化，回到run_simple，点击进入 srv.serve_forever()

```python
# werkzeug/serving.py
class BaseWSGIServer(HTTPServer, object):
    ......
    def serve_forever(self):
        self.shutdown_signal = False
        try:
            HTTPServer.serve_forever(self)
        except KeyboardInterrupt:
            pass
        finally:
            self.server_close()
```

👇在下面这段源码中，将建立socket服务开始监听，当 ready 也就是有请求到来的时候使用 `_handle_request_noblock` 处理请求。这里涉及到了I/O多路复用，简单的提一下，使用它的目的是，我们发现多线程处理消息，CPU在上下文中切换的消耗是非常大的，所以希望用单线程来处理大量用户同时连接。

```python
# Lib/socketserver.py
class BaseServer:

    def serve_forever(self, poll_interval=0.5):
        """
        一次处理（WSGIRequestHandler）一个请求直到shutdown信号
        """
        self.__is_shut_down.clear()
        try:
            # XXX: Consider using another file descriptor or connecting to the
            # socket to wake this up instead of polling. Polling reduces our
            # responsiveness to a shutdown request and wastes cpu at all other
            # times.
            # 优先使用poll方式，没有则使用select方式 （I/O多路复用）
            with _ServerSelector() as selector:
                selector.register(self, selectors.EVENT_READ)

                while not self.__shutdown_request:
                    ready = selector.select(poll_interval)
                    if ready:
                        # 处理请求（非阻塞）
                        self._handle_request_noblock()

                    self.service_actions()
        finally:
            self.__shutdown_request = False
            self.__is_shut_down.set()
```



### 小结

以上为Flask的启动流程，提炼一下内容：

```
flask.Flask.run -> werkzeug.serving.run_simple ->
	
	werkzeug.serving.run_simple.inner ->werkzeug.serving.make_server -> BaseWSGIServer->HTTPServer.__init__(self, get_sockaddr(host, int(port),self.address_family), handler) -> BaseServer.__init__(self, server_address, RequestHandlerClass) ->
	
	werkzeug.serving.run_simple.inner.srv.serve_forever() -> socketserver.BaseServer.serve_forever 建立socket服务开始监听,当ready为True执行 _handle_request_noblock
```

我们接着继续！



## Flask请求处理流程

接上面结尾处，点击进入 `_handle_request_noblock`，👇在下面这段源码中，get_request 是socket对象的accept方法用来与用户建立连接。然后开始校验请求、处理请求。点击进入process_request

```python
# Lib/socketserver.py
class BaseServer:
    def _handle_request_noblock(self):
        """
        非阻塞的处理请求，假设在调用此函数之前，selector.select（）返回了套接字是可读的，因此应该没有阻塞get_request（）的风险。    
        """
        try:
            request, client_address = self.get_request()
        except OSError:
            return
        if self.verify_request(request, client_address):
            try:
                self.process_request(request, client_address)
            except Exception:
                self.handle_error(request, client_address)
                self.shutdown_request(request)
            except:
                self.shutdown_request(request)
                raise
        else:
            self.shutdown_request(request)
```

👇在下面这段源码中，在ForkingMixIn/ThreadingMixIn中进行重写，点击进入finish_request。

```python
class BaseServer: 
    def process_request(self, request, client_address):
        """Call finish_request.
        Overridden by ForkingMixIn and ThreadingMixIn.
        """
        self.finish_request(request, client_address)
        self.shutdown_request(request)
```

👇在下面这段源码中，实际中是调用 WSGIRequestHandler 来处理请求（见前面初始化BaseServer），对于WSGIRequestHandler 它是一个werkzeug中对WSGI请求的处理类。初始化这个类将执行 `handle` 方法 。在这个方法中执行 `try: self.handle()`

```python
class BaseServer: 
    def finish_request(self, request, client_address):
        """Finish one request by instantiating RequestHandlerClass."""
        self.RequestHandlerClass(request, client_address, self)
```



在前面都还没有涉及到app，都是werkzeug（http -> socket）相关的。

重新寻找：

在 run_simple -> make_server -> BaseWSGIServer的 `__init__` 方法内 `handler = WSGIRequestHandler` 点击进入 `WSGIRequestHandler`

👇在下面这段源码中，`werkzeug.serving.WSGIRequestHandler.handle_one_request` 调用`werkzeug.serving.WSGIRequestHandler.run_wsgi` 开始处理请求。其中 `self.server.app` 保存的是我们的 Flask对象，然后对对象加括号，执行执行Flask的 `__call__`方法

```python
class WSGIRequestHandler(BaseHTTPRequestHandler, object):

    """
    处理WSGI请求
    """
	
    # ......省略

    def run_wsgi(self):
        if self.headers.get("Expect", "").lower().strip() == "100-continue":
            self.wfile.write(b"HTTP/1.1 100 Continue\r\n\r\n")

        self.environ = environ = self.make_environ()
        headers_set = []
        headers_sent = []

        def write(data):
            assert headers_set, "write() before start_response"
            if not headers_sent:
                status, response_headers = headers_sent[:] = headers_set
                try:
                    code, msg = status.split(None, 1)
                except ValueError:
                    code, msg = status, ""
                code = int(code)
                self.send_response(code, msg)
                header_keys = set()
                for key, value in response_headers:
                    self.send_header(key, value)
                    key = key.lower()
                    header_keys.add(key)
                if not (
                    "content-length" in header_keys
                    or environ["REQUEST_METHOD"] == "HEAD"
                    or code < 200
                    or code in (204, 304)
                ):
                    self.close_connection = True
                    self.send_header("Connection", "close")
                if "server" not in header_keys:
                    self.send_header("Server", self.version_string())
                if "date" not in header_keys:
                    self.send_header("Date", self.date_time_string())
                self.end_headers()

            assert isinstance(data, bytes), "applications must write bytes"
            self.wfile.write(data)
            self.wfile.flush()

		# ......省略

        def execute(app):
            # app(environ, start_response) 执行Flask的 __call__方法
            application_iter = app(environ, start_response)
            try:
                for data in application_iter:
                    write(data)
                if not headers_sent:
                    write(b"")
            finally:
                if hasattr(application_iter, "close"):
                    application_iter.close()
                application_iter = None

        try:
            execute(self.server.app)
        except (_ConnectionError, socket.timeout) as e:
            self.connection_dropped(e, environ)
        except Exception:
            if self.server.passthrough_errors:
                raise
            from .debug.tbtools import get_current_traceback

            traceback = get_current_traceback(ignore_system_exceptions=True)
            try:
                # if we haven't yet sent the headers but they are set
                # we roll back to be able to set them again.
                if not headers_sent:
                    del headers_set[:]
                execute(InternalServerError())
            except Exception:
                pass
            self.server.log("error", "Error on request:\n%s", traceback.plaintext)

    def handle(self):
        """Handles a request ignoring dropped connections."""
        rv = None
        try:
            rv = BaseHTTPRequestHandler.handle(self)
        except (_ConnectionError, socket.timeout) as e:
            self.connection_dropped(e)
        except Exception as e:
            if self.server.ssl_context is None or not is_ssl_error(e):
                raise
        if self.server.shutdown_signal:
            self.initiate_shutdown()
        return rv

   
    def handle_one_request(self):
        """Handle a single HTTP request."""
        self.raw_requestline = self.rfile.readline()
        if not self.raw_requestline:
            self.close_connection = 1
        elif self.parse_request():
            return self.run_wsgi()

    # ......省略
```



重新寻找：

从 `app = Flask(__name__)` 点击进入，寻找 `__call__` 方法。

👇在下面这段源码中，wsgi_app在请求上下文中执行我们编写的预处理方法(before request)，视图方法，后响应方法等（after request）。点击进入wsgi_app

```python
# flask/app.py
class Flask(_PackageBoundObject):
   	# ......省略
    def __call__(self, environ, start_response):
        """The WSGI server calls the Flask application object as the
        WSGI application. This calls :meth:`wsgi_app` which can be
        wrapped to applying middleware."""
        # 用户请求到来之后，第一步执行
        return self.wsgi_app(environ, start_response)
```

👇在下面这段源码中，首先创建请求上下文对象，然后执行视图函数，返回response响应，最终删掉请求上下文，应用上下文。点击进入 `ctx.push()` ； 点击进入 `self.full_dispatch_request()`

```python
# flask/app.py
class Flask(_PackageBoundObject):
   	# ......省略
    def wsgi_app(self, environ, start_response):        
        '''
        environ是原始的请求相关的字典
        ctx对象(RequestContext)，内部封装了request/session
        '''
        ctx = self.request_context(environ)
        error = None
        try:
            try:
                '''
                ctx.push() 做的事情
                1. 将封装了request/session的对象，经过LocalStack，放到了Local中
                2. 创建了app_ctx，内部封装了app 和 g ，经过LocalStack，放到了Local中
                3. 执行路由匹配
                '''
                ctx.push()
                response = self.full_dispatch_request()  # 执行视图函数
            except Exception as e:
                error = e
                response = self.handle_exception(e)
            except:  # noqa: B001
                error = sys.exc_info()[1]
                raise
            return response(environ, start_response)
        finally:
            if self.should_ignore_error(error):
                error = None
            # 请求结束后，要删掉请求上下文，应用上下文，使用各自的pop方法
            ctx.auto_pop(error)  
```

👇在下面这段源码中，将应用上下文对象放入LocalStack、将请求上下文对象放入LocalStack。

```python
# flask/ctx.py
class RequestContext(object):
   	# ......省略
    def push(self):   

        top = _request_ctx_stack.top
        if top is not None and top.preserved:
            top.pop(top._preserved_exc)

        # 在放入请求上下文对象前，必须确保_app_ctx_stack中有该应用上下文对象
        app_ctx = _app_ctx_stack.top
        if app_ctx is None or app_ctx.app != self.app:
            # AppContext实例化，封装了，app，g
            app_ctx = self.app.app_context()

            # 将应用上下文对象放入LocalStack
            app_ctx.push()
            self._implicit_app_ctx_stack.append(app_ctx)
        else:
            self._implicit_app_ctx_stack.append(None)

        if hasattr(sys, "exc_clear"):
            sys.exc_clear()

        # 将请求上下文对象，放入LocalStack
        _request_ctx_stack.push(self)

        if self.session is None:
            session_interface = self.app.session_interface
            self.session = session_interface.open_session(self.app, self.request)

            if self.session is None:
                self.session = session_interface.make_null_session(self.app)

        if self.url_adapter is not None:
            # 路由匹配
            # uel_rule中含有成功匹配的 endpoint ： url
            self.match_request()
```



👇在下面这段源码中，将执行请求的预处理、视图、后处理以及异常捕获和错误处理。点击进入 `self.dispatch_request()`

```python
# flask/app.py
class Flask(_PackageBoundObject):
   	# ......省略
    def full_dispatch_request(self):
        """
        Dispatches the request and on top of that performs request pre 
        and postprocessing as well as HTTP exception catching and error handling.
        调度请求，并在此之上执行请求的预处理和后处理以及HTTP异常捕获和错误处理。        
        """        
		
        # 执行before_first_request方法，只有第一次请求才会执行一次（由标志位来决定）。
        self.try_trigger_before_first_request_functions()
        try:
            request_started.send(self)
            # 执行所有的before request
            rv = self.preprocess_request()
            if rv is None: # before request没有返回值，才会执行视图
                # 找到视图函数并执行
                rv = self.dispatch_request()
        except Exception as e:
            rv = self.handle_user_exception(e)
        # 执行所有的 after request
        return self.finalize_request(rv)
```

👇在下面这段源码中，将执行视图。

```python
# /flask/ctx.py
    def dispatch_request(self):
        """
        执行请求调度。匹配URL，并返回视图的结果或错误处理句柄。不必是响应对象。        
        为了将返回值转换为适当的响应对象，请调用：func：`make_response`。
        """
        req = _request_ctx_stack.top.request
        if req.routing_exception is not None:
            self.raise_routing_exception(req)
        rule = req.url_rule
        # if we provide automatic options for this URL and the
        # request came with the OPTIONS method, reply automatically
        if (
            getattr(rule, "provide_automatic_options", False)
            and req.method == "OPTIONS"
        ):
            return self.make_default_options_response()
        # otherwise dispatch to the handler for that endpoint
        return self.view_functions[rule.endpoint](**req.view_args)
```



### 小结

首尾：werkzeug相关

```
curl发出请求->socket接受到请求 ->
（werkzeug相关）
SocketServer.BaseServer.serve_forever._handle_request_noblock ->
SocketServer.BaseServer.process_request -> 
SocketServer.BaseServer.finish_request ->
socketserver.BaseServer.__init__:self.RequestHandlerClass(request, client_address, self)  ->
    这里要找出RequestHandlerClass是如何初始化的,它的真身是什么 ->
    socketserver.TCPServer.__init__:BaseServer.__init__(self, server_address, RequestHandlerClass) ->
    http.server.HTTPServer(未重写__init__) ->
    werkzeug.serving.BaseWSGIServer:HTTPServer.__init__(self, get_sockaddr(host, int(port),self.address_family), handler) (此处handler就是WSGIRequestHandler) ->
    RequestHandlerClass的真身已经找到,就是WSGIRequestHandler 也就是说每次请求来了都初始化一个WSGIRequestHandler去处理 ->
处理的入口应该是werkzeug.serving.WSGIRequestHandler.handle可是简单一看并没找到是如何开始处理请求的->
    往它的父类BaseHTTPRequestHandler中找也没有 ->
    再往上socketserver.StreamRequestHandler ->
    找到了SocketServer.BaseRequestHandler.__init__:try:self.handle() 关键点 ->
（App相关）
开始调用子类WSGIRequestHandler中的handle方法 ->
    werkzeug.serving.WSGIRequestHandler (注意handler和handle_one_request，WSGIRequestHandler重载了BaseHTTPServer.BaseHTTPRequestHandler中的方法，BaseHTTPRequestHandler又重载了 SocketServer.BaseRequestHandler )->
werkzeug.serving.WSGIRequestHandler.handle_one_request调用werkzeug.serving.WSGIRequestHandler.run_wsgi 开始处理请求 ->
run_wsgi.execute(self.server.app)将请求交予app来处理 ->
flask.Flask.__call__ -> 
flask.Flask.wsgi_app 开始app内的流程，交由wsgi_app在请求上下文中执行预处理方法,视图方法,后响应方法等。
```

中间：app相关

```
当用户请求到来之后,flask内部会创建两个对象:
	ctx = ReqeustContext(),内部封装request/sesion
	app_ctx = AppContext(),内部封装app/g
然后会将此对象通过各自的LocalStack对象:
	_request_ctx_stack = LocalStack()
	_app_ctx_stack = LocalStack()
	将各自的对象添加到Local中.

Local是一个特殊结构,他可以为每个线程(协程)维护一个空间进行存取数据. 
LocalStack的作用是将Local中维护成一个栈.
内部更细节的结构为:
	storage = {
        1212:{stack:[ctx,]}
	}
	
	storage = {
        1212:{stack:[app_ctx,]}
	}
	
	
视图函数如果想要获取:request/session/app/g,只需要导入即可,导入的本质是去各自storage中获取各自的对象,并调用封装其内部:request/session/app/g. (获取栈顶的数据top)

请求处理完毕,将各自storage中存储的数据进行销毁. 
```



参考文章 [[flask源码走读](https://www.cnblogs.com/lgjbky/p/10669397.html)]  
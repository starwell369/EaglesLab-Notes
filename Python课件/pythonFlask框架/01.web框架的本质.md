# 自定义web框架

web应用本质上就是一个socket服务端，浏览器是socket客户端，基于请求做出响应，客户都先请求，服务端做出对应的响应，按照http协议的请求协议发送请求，服务端按照http协议的响应协议来响应请求，这样的网络通信，我们就可以自己实现Web框架了。

准备一个html文件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>测试页面</title>
</head>
<body>
<h1>标题1</h1>
<img src="https://iproute.cn/images/logo.png" alt="头像">
</body>
</html>
```

编写python的socket服务端

```python
import socket
sk = socket.socket()
sk.bind(('127.0.0.1',8080))
sk.listen()
conn,addr = sk.accept()
b_msg = conn.recv(1024)
str_msg = b_msg.decode('utf-8')
conn.send(b'HTTP/1.1 200 ok \r\n\r\n')
conn.send(b'hello')
print(str_msg)
conn.close()
sk.close()
```

运行服务端之后，浏览器访问`http://127.0.0.1:8080` ，浏览器传给socket的内容如下

```
GET / HTTP/1.1   # 请求行，其中的/是路径
Host: 127.0.0.1:8080
Connection: keep-alive
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.116 Safari/537.36
Sec-Fetch-Dest: document
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Sec-Fetch-Site: none
Sec-Fetch-Mode: navigate
Sec-Fetch-User: ?1
Accept-Encoding: gzip, deflate, br
Accept-Language: zh-CN,zh;q=0.9,zh-TW;q=0.8
Cookie: smid=sys4OxpO9GZqFqSAA37ZAWOnLB54KsilDWWuipaewHYE9ggajIeWtlHRrIBuSZyR038Q7r4c2XNUXdfdWR-I4A; APP_HOST=http%3A//127.0.0.1%3A49153/; HOST=http%3A//127.0.0.1%3A49153/; kodUserLanguage=zh-CN; kodUserID=1; X-CSRF-TOKEN=i9YQRqWXnS4Iy3uRt3vW; p_h5_u=057F0CAB-3644-4539-A2BC-249B82EA9934
```

修改socket服务端，让其返回网页内容

```python
import socket
sk = socket.socket()
sk.bind(('127.0.0.1',8080))
sk.listen()
conn,addr = sk.accept()
b_msg = conn.recv(1024)
str_msg = b_msg.decode('utf-8')
print(str_msg)
conn.send(b'HTTP/1.1 200 ok \r\n\r\n')
with open('test.html','rb') as f:
    f_data = f.read()
conn.send(f_data)
conn.close()
sk.close()
```

这样就可以将网页内容返回给浏览器了

如果想要在网页中携带本地路径的图片，那么修改html代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>测试页面</title>
</head>
<body>
<h1>标题1</h1>
<img src="logo.png" alt="头像">
</body>
</html>
```

然后修改socket服务端

```python
import socket
sk = socket.socket()
sk.bind(('127.0.0.1',8080))
sk.listen()
while 1:    # 浏览器多次访问，所以需要while
    conn,addr = sk.accept()
    b_msg = conn.recv(1024)
    str_msg = b_msg.decode('utf-8')
    path = str_msg.split('\r\n')[0].split(' ')[1]
    print('path>>>',path)
    conn.send(b'HTTP/1.1 200 ok \r\n\r\n')
    if path == '/':
        with open('test.html','rb') as f:
            f_data = f.read()
        conn.send(f_data)
        conn.close()    # HTTP协议是短链接的，一次请求对应一次响应，这个请求就结束了，所以我们需要写上close，不然浏览器自己断了
    elif path == '/logo.png':
        with open('logo.png','rb') as f:
            f_data = f.read()
        conn.send(f_data)
        conn.close()
sk.close()
```

可以改成使用函数的版本

```python
import socket
sk = socket.socket()
sk.bind(('127.0.0.1',8080))
sk.listen()
def func1(conn):
    with open('test.html', 'rb') as f:
        f_data = f.read()
    conn.send(f_data)
    conn.close()
def func2(conn):
    with open('logo.png', 'rb') as f:
        f_data = f.read()
    conn.send(f_data)
    conn.close()

while 1:
    conn,addr = sk.accept()
    b_msg = conn.recv(1024)
    str_msg = b_msg.decode('utf-8')
    path = str_msg.split('\r\n')[0].split(' ')[1]
    print('path>>>',path)
    conn.send(b'HTTP/1.1 200 ok \r\n\r\n')
    if path == '/':
        func1(conn)
    elif path == '/logo.png':
        func2(conn)
sk.close()
```

现在还不支持高并发的情况，可以加上多线程

```python
import socket
from threading import Thread

sk = socket.socket()
sk.bind(('127.0.0.1',8080))
sk.listen()
def func1(conn):
    with open('test.html', 'rb') as f:
        f_data = f.read()
    conn.send(f_data)
    conn.close()
def func2(conn):
    with open('logo.png', 'rb') as f:
        f_data = f.read()
    conn.send(f_data)
    conn.close()

while 1:
    conn,addr = sk.accept()
    b_msg = conn.recv(1024)
    str_msg = b_msg.decode('utf-8')
    path = str_msg.split('\r\n')[0].split(' ')[1]
    print('path>>>',path)
    conn.send(b'HTTP/1.1 200 ok \r\n\r\n')
    if path == '/':
        t = Thread(target=func1,args=(conn,))
        t.start()
    elif path == '/logo.png':
        t = Thread(target=func2,args=(conn,))
        t.start()
sk.close()
```

替换字符串，实现不同的时间访问返回时间戳模拟动态内容

在网页中，用特殊的符号`@@666@@`表示需要被替换掉的地方，修改html代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>测试页面</title>
</head>
<body>
<h1>标题1</h1>
<img src="logo.png" alt="头像">
<h2>@@666@@</h2>
</body>
</html>
```

修改socket服务端

```python
import socket
from threading import Thread
import time

sk = socket.socket()
sk.bind(('127.0.0.1',8080))
sk.listen()
def func1(conn):
    with open('test.html', 'r',encoding="utf-8") as f:
        f_data = f.read()
        now = str(time.time())
        f_data = f_data.replace("@@666@@",now).encode('utf-8')
    conn.send(f_data)
    conn.close()
def func2(conn):
    with open('logo.png', 'rb') as f:
        f_data = f.read()
    conn.send(f_data)
    conn.close()

while 1:
    conn,addr = sk.accept()
    b_msg = conn.recv(1024)
    str_msg = b_msg.decode('utf-8')
    path = str_msg.split('\r\n')[0].split(' ')[1]
    print('path>>>',path)
    conn.send(b'HTTP/1.1 200 ok \r\n\r\n')
    if path == '/':
        t = Thread(target=func1,args=(conn,))
        t.start()
    elif path == '/logo.png':
        t = Thread(target=func2,args=(conn,))
        t.start()
sk.close()
```
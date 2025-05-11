# Python推导式

## 列表推导式

列表推导式主要是用于按照我们指定的内容填充，生成一个新的列表，基本语法如下：
> new_list = [ expression for item in iterable if condition ]


### 示例

```python
# 生成0~10的一个列表
l = [i for i in range(11)]
print(l)				# 输出: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# 生成平方数的列表
squares = [x ** 2 for x in range(10)]
print(squares)  		# 输出: [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# 生成偶数的列表
even_numbers = [x for x in range(20) if x % 2 == 0]
print(even_numbers)  	# 输出: [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]
```

推导式没有特殊之处，只是一种便利的编程方式....

### 案例

1. 找到嵌套列表中名字含有两个及以上‘a’的所有名字

```python
fruits = [['peach','Lemon','Pear','avocado','cantaloupe','Banana','Grape'],
          ['raisins','plum','apricot','nectarine','orange','papaya']]

print([name for lst in fruits for name in lst if name.count('a') >= 2])
/
# Output:
['avocado', 'cantaloupe', 'Banana', 'papaya']
```

2. 30以内所有能被3整除的数

```python
multiples = [i for i in range(30) if i % 3 == 0]
print(multiples)
```

## 集合推导式

集合推导式用于生成一个新的集合。它的语法与列表推导式类似，但使用大括号 `{}`。

```python
new_set = {expression for item in iterable if condition}
```

### 示例

```python
# 生成平方数的集合
squares_set = {x ** 2 for x in range(10)}
print(squares_set)  # 输出: {0, 1, 4, 9, 16, 25, 36, 49, 64, 81}

# 生成唯一的字符集合
unique_chars = {char for char in "hello world"}
print(unique_chars)  # 输出: {'h', 'e', 'l', 'o', ' ', 'r', 'w', 'd'}
```

### 案例

计算列表中每个值的平方，自带去重功能

```python
l = [1,2,3,4,1,-1,-2,3]

squared = {x**2 for x in l}
print(squared)

# Output:
{16, 1, 4, 9}
```

## 字典推导式

同上，我们可以使用字典推导式生成一个新的字典

```python
new_dict = {key_expression: value_expression for item in iterable if condition}
```

### 示例

```python
# 生成平方数的字典
squares_dict = {x: x ** 2 for x in range(10)}
print(squares_dict)  # 输出: {0: 0, 1: 1, 2: 4, 3: 9, 4: 16, 5: 25, 6: 36, 7: 49, 8: 64, 9: 81}

# 生成字符及其 ascii 值的字典
ascii_dict = {char: ord(char) for char in "abc"}
print(ascii_dict)  # 输出: {'a': 97, 'b': 98, 'c': 99}
```

### 案例

1. 将一个字典的key和value对调

```python
dic1 = {'a':1,'b':2}

dic2 = {dic1[k]: k for k in dic1}
print(dic2)
```

2. 合并大小写对应的value值，将k统一成小写

```python
dic1 = {'a':1,'b':2,'y':1, 'A':4,'Y':9}

dic2 = {k.lower():dic1.get(k.lower(),0) + dic1.get(k.upper(),0) for k in dic1.keys()}
print(dic2)  
```

## 生成器表达式

把列表推导式的的`[]`换成`()`就变成了生成器表达式，相比于列表表达式，生成器表达式不会直接产生值，而是需要我们手动去迭代它

### 案例

```python
gen_expr = (x ** 2 for x in range(5))
print(gen_expr)  

```

**手动迭代：**

```python
for value in gen_expr:
    print(value)
```

# 小练一下

使用推导式打印出九九乘法口诀表（仅使用一行代码）

```python
print('\n'.join(['\t'.join([f'{i}x{j}={i * j}' for i in range(1,j+1)]) for j in range(1, 10)]))
```
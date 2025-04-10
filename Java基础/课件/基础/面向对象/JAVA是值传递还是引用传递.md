
堆内存： 保存的是对象的具体信息
栈内存：保存的是一块堆内存的地址

# 形参和实参

形式参数：是在定义函数名和函数体的时候使用的参数,目的是用来接收调用该函数时传入的参数。
实际参数：在调用有参函数时，主调函数和被调函数之间有数据传递关系。

```java
public static void main(String[] args) {
        Test01 test = new Test0();
    	test.han("hello")  //实际参数为hello
    }

public void sout(String name) { //形式参数为name
	System.out.println(name);
}
```
# 值传递与引用传递

**值传递**：是指在调用函数时，将原始参对象复制一份作为实参传给形参，当在函数中对参数进行修改时，不会影响到实际参数。
**引用传递**：是指在调用函数时，将原始对象直接作为实参传给形参，一旦在函数中对其进行修改，将会影响实际参数。

| 
 | 值传递 | 引用传递 |
| --- | --- | --- |
| 区别 | 会创建副本 | 不会创建副本 |
| 所以 | 无法改变原始对象 | 会改变原始对象 |

```java
public class Person {
    int age;
    String name;

    public Person() {

    }


    public void print() {
        System.out.println(age);
        System.out.println(name);
    }
}
```
```java
public class TestPerson {
    public static void main(String[] args) {
        Person person01 = new Person();

        person01.name = "雷雷";
        person01.age = 25;

        Person person02 = person01;
        person02.age = 18;

        person01.print();
    }
}
```

![image.png](../../../images/2023/1697248545967-6fae9555-db4b-4586-9e13-9b2962d5316e.png)

```java
public class TestPerson {
    public static void main(String[] args) {
        Person person01 = new Person();

        person01.name = "leilei";
        person01.age = 25;

        change(person01); // 等价 Person person02 = person01;

        person01.print();
    }


    public static void change(Person person){
        person.age = 18;
    }
}
```

![image.png](../../../images/2023/1694396458226-d5653caf-e718-41cc-87af-eb2056ddc874.png)

```java
public class TestPerson {
    public static void main(String[] args) {
        Person person01 = new Person();
        Person person02 = new Person();

        person01.age = 18;
        person01.name = "leilei";

        person02.name = "herb";
        person02.age = 19;

        person02 = person01;
        person02.age =80;

        person01.print();
    }

}

```
![image.png](../../../images/2023/1694396416479-1c3b3fff-3e36-4bec-848b-882e910cc787.png)
# 总结

java中方法参数传递方式是按值传递。
如果参数是基本类型，传递的是基本类型的字面量值的拷贝。
如果参数是引用类型，传递的是该参量所引用的对象在堆中地址值的拷贝。

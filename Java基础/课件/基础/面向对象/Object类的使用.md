# 简介
1. `Object`类是所有`Java`类的根父类; 
2. 如果在类的声明中未使用`extends`关键字指明其父类，则默认父类为`java.lang.Object`类 
3. `Object`类中的功能(属性、方法)就具有通用性。
4. 属性:无

      方法:`equals()` / `toString()` / `getClass()` / `hashCode()` / `clone()` /`finalize()` 、`wait()` 、`notify()`、`notifyAll() `

5. Object类只声明了一个空参的构造器。

![image.png](../../../images/2023/1694410430187-3c85fe8f-0221-42ef-a9c2-c16300529a22.png)
![](../../../images/2022/1668929457356-d0619b21-4675-45b1-9c72-80234e9d89c4.png)

# == 和 equals方法（面试题）
`**==**`**运算符：**

1. 可以使用在基本数据类型变量和引用数据类型变量中。
2. 如果比较的是基本数据类型变量：
   1. 比较两个变量保存的数据是否相等。
   2. 如果比较的是引用数据类型变量：比较两个对象的地址值是否相同，即两个引用是否指向同一个对象实体。

`**equals()**`**方法的使用：**

1. 只能适用于引用数据类型。
2. 重写的`equals`方法比较的值。
3. 像`String`、`Date`、`File`、包装类等都重写了`Object`类中的`equals()`方法。比较两个对象的“实体内容”是否相同。
4. 显然，当`equals`为`true`时，`==`不一定为`true`；
```java
public class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    @Override
    public boolean equals(Object o) {
        //如果是传入对象的地址一样
        if (this == o) return true;
        //如果 两个对象的类型不一样
        if (!(o instanceof Person)) return false;

        Person person = (Person) o;
        if (age != person.age) return false;
        return Objects.equals(name, person.name);
    }
}
```
```java
public class Demo {
    public static void main(String[] args) {

        //TODO 在基本数据类型中
        int i = 100;
        int j = 100;
        double d = 100.0;

        System.out.println(i == j);//ture
        System.out.println(i == d);//ture

        char c = 100;
        System.out.println(i == c);//ture


        char c1 = 'A';
        char c2 = 65;
        System.out.println(c1 == c2);//ture


        //TODO ==在引用数据类型中 比较的是地址
        String str1 = new String("BAT");
        String str2 = new String("BAT");
        System.out.println(str1 == str2); //false

        System.out.println(str1.equals(str2));// true


        Person person1 = new Person("aa", 18);
        Person person2 = new Person("aa", 18);

        System.out.println(person1 == person2);// false

        System.out.println(person1);
        System.out.println(person2);


        //TODO Person 没有重写 equals（） 方法，,此时走的是父类的equals（）方法， 比较的还是地址，所以结果为false
        // 重写equals（）方法之后，比较的是值,结果为true
        System.out.println(person1.equals(person1));// false
    }
}
```
![image.png](../../../images/2023/1694411020419-293aafba-1b69-4b91-b571-2267add3d1e3.png)
# toString()
当我们输出一个引用对象时，实际上就是调用当前对象的`toString()`,
像`String`、`Date`、`File`、包装类等都重写了`Object`类中的`toString()`方法。 使得在调用`toString()`时，返回"实体内容"信息。
![image.png](../../../images/2023/1694411239168-5186d395-2501-430a-a13a-d6e22645a217.png)

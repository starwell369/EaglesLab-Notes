(1)this修饰属性：

1. 你想要访问的是属性的话，前面就加上`this. `例如`this.age`代表的就是属性的`age`
2. 当不发生重名问题（形参或者局部变量和属性不重名），`this.`可以省略不写
3. 当发生重名问题（形参或者局部变量和属性重名），`this.`不可以省略了，必须写

当发生重名问题（形参或者局部变量和属性重名），出现就近原则
```java
public class Person {
    //TODO 属性 ==》 成员变量
    //名字
    String name;
    //年龄
    int age;
    //身高
    double height;
    //体重
    double weight;


    //无参构造器
    //类中，默认就有这个方法,
    public Person() {
        System.out.println("你小子是不是在动我");
    }

    //有参构造器
    public Person(String MyName, int age, double height, double weight) {

        //TODO 当重名的时候，可以省略this，就近原则
        name = MyName;

        //TODO 当重名的时候，不可以省略this
        this.age = age;
        this.height = height;
        this.weight = weight;
    }


    //方法
    public void eat() {
        System.out.println("吃");
    }

    //喝
    public void drink(String drink) {
        System.out.println("喝" + drink);
    }
}

```
(2)this修饰方法：在同一个类中，方法之间可以相互调用，this.可以省略不写！
```java
//方法
public void eat() {
    //TODO 在同一个类中，方法之间可以相互调用，this.可以省略不写！

    drink("果汁");

    this.drink("鲜奶");

    System.out.println("吃");
}

//喝
public void drink(String drink) {
    System.out.println("喝" + drink);
}
```
```java
public class PersonTest {
    public static void main(String[] args) {

        //通过有参构造器创建对象，
        Person person = new Person("herb",25,180,180);

        person.eat();

    }
}
```
(3) this修饰 构造器：
同一个类中，构造器之间可以相互调用。 this（传入实参）
this修饰构造器，必须放在代码的第一行。
```java
public class Person02 {
    //TODO 属性 ==》 成员变量
    //名字
    String name;
    //年龄
    int age;
    //身高
    double height;
    //体重
    double weight;


    //无参构造器
    //类中，默认就有这个方法,
    public Person02() {
        this("herb");
        System.out.println("我是无参");
    }

    //有参构造器
    public Person02(String name, int age, double height, double weight) {

        //TODO 调用无参构造器， 只能放在第一行
        this();

        System.out.println("我是有参");

        this.name = name;
        this.age = age;
        this.height = height;
        this.weight = weight;
    }


    //有参构造器
    public Person02(String name) {
        this.name = name;
        System.out.println("我只有一个参数");
    }

}
```
```java
public class Person02Test {
    public static void main(String[] args) {

        //通过有参构造器创建对象，
        Person02 person = new Person02("herb",25,180,180);

        //Person02 person02 = new Person02();
    }
}

```

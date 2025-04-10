在`java`里面使用`final`关键字可以实现如下功能：**定义不能够被继承的类，不能够被覆写的方法，常量。**
**eg： 定义不能被继承的类**
```java
final class Father {
}

//TODO 报错  final修饰的，不能被继承
class Son extends Father{

}

class Test {
    public static void main(String[] args) {
        
    }
}
```
当子类继承父类之后实际上是可以进行父类中方法覆写的，但是如果你现在不希望你的某一个方法被子类所覆写，就可以使用final来定义。

**eg：定义不能被覆写的方法**
```java
public class Fathe01 {
    public final void show() {
        System.out.println("111");
    }
}

class Son01 extends Fathe01 {

    //TODO 报错 ，不能重写被 final 修饰 的方法
    public void show() {
        System.out.println("222");
    }
}

class Test01 {
    public static void main(String[] args) {
    }
}
```

**eg： 定义常量**
```java
public class MyMath {
    // 全局常量每一个字母都是大写
    public static final double PI = 3.14;

    public final void show() {
        //TODO 报错， 常量不能被修改
        //PI = 444;
    }
}

class Test02 {
    public static void main(String[] args) {

    }
}

```

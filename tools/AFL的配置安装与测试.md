### 1. AFL配置

1. 操作系统环境 ubuntu20.04

   参考：

   [(14条消息) AFL环境配置过程记录及遇见的问题_weixin_42877778的博客-CSDN博客](https://blog.csdn.net/weixin_42877778/article/details/125282251)

   [(14条消息) 利用AFL进行模糊测试_zhongzhehua的博客-CSDN博客](https://blog.csdn.net/zhongzhehua/article/details/117717656)

   [AFL--模糊测试使用浅析 - FreeBuf网络安全行业门户](https://www.freebuf.com/articles/web/334126.html)

   [(14条消息) Linux下安装AFL && 报错“Pipe at the beginning of ‘core_pattern’“解决方案_是周周不是粥粥的博客-CSDN博客](https://blog.csdn.net/weixin_45225566/article/details/115877331)

2. 创建lab文件夹，在termina下 

   ```
   $ git clone https://github.com/google/AFL.git`
   ```

3. 安装gcc

   ```
   $ sudo apt-get install gcc
   ```

   检查gcc是否安装成功

   ```
   $ gcc -v
   ```

   <img src="C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20221121152053363.png" alt="image-20221121152053363" style="zoom:67%;" />

4. 安装make

   ```
   $ apt install make
   ```

5. ```
   $ make
   ```
   
6. ```
   $ sudo make install
   ```

### 2. AFL简单测试

1. 返回lab目录下，创建test文件夹

2. test目录下，创建一个简单的测试，afl_test1.c，内容如下：

   ```c++
   #include <stdio.h> 
   #include <stdlib.h> 
   #include <unistd.h> 
   #include <string.h> 
   #include <signal.h> 
   
   int vuln(char *str)
   {
       int len = strlen(str);
       if(str[0] == 'A' && len == 66)
       {
           raise(SIGSEGV);
           //如果输入的字符串的首字符为A并且长度为66，则异常退出
       }
       else if(str[0] == 'F' && len == 6)
       {
           raise(SIGSEGV);
           //如果输入的字符串的首字符为F并且长度为6，则异常退出
       }
       else
       {
           printf("it is good!\n");
       }
       return 0;
   }
   
   int main(int argc, char *argv[])
   {
       char buf[100]={0};
       gets(buf);//存在栈溢出漏洞
       printf(buf);//存在格式化字符串漏洞
       vuln(buf);
   
       return 0;
   }
   ```

3. 对测试源代码进行插桩编译

   ```
   $ afl-gcc afl_test1.c -o afl_test1
   ```

   结果如下：

![image-20221121153334347](C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20221121153334347.png)

​		可以看到在编译过程中，编译器已经提示存在漏洞，不理会，用AFL去测试。

4. 在test目录下创建fuzz_in和fuzz_out文件夹。进入fuzz_in下，创建testcase文件，内容随意（保持简短）。

<img src="C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20221121154422580.png" alt="image-20221121154422580" style="zoom:80%;" />

5. 进行fuzz

   ```
   $ afl-fuzz -i fuzz_in -o fuzz_out ./afl_test1
   ```

   遇到报错：![image-20221121161518024](C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20221121161518024.png)

   解决办法：

   1）首先进入root

   ```
   $ sudo su
   ```

   2）然后在root模式下输入以下内容（上图倒数第三行内容）

   ```
   echo core >/proc/sys/kernel/core_pattern
   ```

   3）ctrl+d退出root，再重新进行fuzz命令

6. fuzz结果：

   <img src="C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20221121161934437.png" alt="image-20221121161934437" style="zoom:80%;" />

   <img src="C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20221121162344193.png" alt="image-20221121162344193" style="zoom:80%;" />

   可能会提示屏幕太小放不下，将虚拟机和terminal窗口全屏即可。
   
   也可以看到fuzz_out文件夹中产生了内容。
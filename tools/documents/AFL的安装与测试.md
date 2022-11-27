### 1. AFL（模糊测试工具）安装

1. 操作系统环境 ubuntu20.04

   参考：

   [(14条消息) AFL环境配置过程记录及遇见的问题_weixin_42877778的博客-CSDN博客](https://blog.csdn.net/weixin_42877778/article/details/125282251)

   [(14条消息) 利用AFL进行模糊测试_zhongzhehua的博客-CSDN博客](https://blog.csdn.net/zhongzhehua/article/details/117717656)

   [AFL--模糊测试使用浅析 - FreeBuf网络安全行业门户](https://www.freebuf.com/articles/web/334126.html)

   [(14条消息) Linux下安装AFL && 报错“Pipe at the beginning of ‘core_pattern’“解决方案_是周周不是粥粥的博客-CSDN博客](https://blog.csdn.net/weixin_45225566/article/details/115877331)

2. 安装gcc和g++

   ```
   $ sudo apt-get install gcc
   $ sudo apt-get install g++
   ```

4. 安装make

   ```
   $ apt install make
   ```

5. 下载并安装afl

   ```
   $ git clone https://github.com/google/AFL.git`
   $ cd AFL
   $ make
   $ sudo make install
   ```

### 2. AFL的一个简单测试

1. 返回上级目录，创建test文件夹

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
   
   ![image-20221121153334347](\\pictures\image-20221121153334347.png)

​		可以看到在编译过程中，编译器已经提示存在漏洞，不理会，用AFL去测试。

4. 在test目录下创建fuzz_in和fuzz_out文件夹。进入fuzz_in下，创建testcase文件，内容随意（保持简短）。

![image-20221121154422580](\\pictures\image-20221121154422580.png)

5. 进行fuzz

   ```
   $ afl-fuzz -i fuzz_in -o fuzz_out ./afl_test1
   ```

   遇到报错：![image-20221121161518024](\\pictures\image-20221121161518024.png)

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

   ![image-20221121162344193](\\pictures\image-20221121162344193.png)

   可能会提示屏幕太小放不下，将虚拟机和terminal窗口全屏即可。

   也可以看到fuzz_out文件夹中产生了内容。

### 3. 对openssl进行fuzz

​	参考：

​	[编译 OpenSSL (wingfuzz.com)](https://doc.wingfuzz.com/real_world_test_1.html)

​	[AFL使用指南 - tomyyyyy - 博客园 (cnblogs.com)](https://www.cnblogs.com/tomyyyyy/articles/13610206.html)

​	[使用美国模糊罗普 （AFL） |模糊应用程序作者：Ayush Priya |中等 (medium.com)](https://medium.com/@ayushpriya10/fuzzing-applications-with-american-fuzzy-lop-afl-54facc65d102)

1. 下载代码

   ```
   $ git clone https://github.com/openssl/openssl --branch=OpenSSL_1_0_1f --depth=1
   ```

   该版本（1.0.1f）是一个有着安全漏洞的源码版本,下载最新版本也可（去掉branch）

2. 使用afl进行编译

   ```
   $ cd openssl
   $ export CC=afl-gcc CXX=afl-g++
   $ ./config --prefix=$PWD/install
   ```

   然后make，该过程需要一段时间，耐心等待

   ```
   $ make
   ```

   然后make install

   ```
   $ make install
   ```

   如果报错如下：

   ![image-20221122150617173](\\pictures\image-20221122150617173.png)

   则在root权限下，执行rm -f /usr/bin/pod2man  然后重新make install：

   ```
   $ sudo su
   rm -f /usr/bin/pod2man
   ```

   退出root后重新make install即可

   最后检查是否安装成功：

   编译完成后，OpenSSL 的库将会安装在 openssl/install 目录下，检查下列文件是否存在：

   - openssl/install/lib/libcrypto.a
   - openssl/install/lib/libssl.a
   - openssl/install/include/openssl/

   如果均存在，说明已经成功的编译安装了OpenSSL

3. 进行fuzz

   由于找不到可执行文件，所以不知道该怎么进行fuzz

   设置target为./apps/openssl进行fuzz，出现问题
   
   <img src="\\pictures\5.png" alt="5" style="zoom:80%;" />

### 4. 对libxml2进行fuzz

1. 下载项目

   ```
   $ git clone https://github.com/GNOME/libxml2.git
   ```

2. 下载python3.8

   ```
   $ wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0a4.tar.xz
   $ tar Jxf Python-3.8.0a4.tar.xz
   $ cd Python-3.8.0a4
   $ ./configure prefix=/usr/local/python3
   $ make
   $ sudo make install
   ```

   make install可能会提示没有zlib，要先进行安装

   ```
   $ sudo apt-get install zlib*
   ```

   

   或者直接

   ```
   $ sudo apt-get install python3.8
   ```

   后面可能还会提示找不到python3.8，需要设置pkg_config_path之类的大概也许，还没找到好的解决方案

3. 下载并安装automake1.16.5

   ```
   $ cd libxml2
   $ wget http://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz
   $ tar -zxvf automake-1.16.5.tar.gz
   $ cd automake-1.16.5
   $ ./configure
   $ make
   $ sudo make install
   ```

4. 编译安装libxml2

   ```
   $ cd libxml2
   $ ./autogen.sh
   $ ./configure
   $ make
   $ sudo make install
   ```

5. 开始fuzz

   有点问题

### 5. 对binutils进行fuzz

1. 下载解压并编译binutil-2.37

   ```
   $ wget https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz
   $ tar -zxvf binutils-2.37.tar.gz -C ./
   $ cd binutils-2.37
   $ export CC=afl-gcc CXX=afl-g++
   $ ./configure
   $ make
   ```

2. 创建fuzz_in文件夹，里面再创建testcase文件，内容为hello

3. 在binutils-2.37中，开始fuzz，一共有6个target

    ```
    $ afl-fuzz -i fuzz_in -o fuzz_out ./binutils/size @@  
    ```

    ```
    $ afl-fuzz -i fuzz_in -o fuzz_out ./binutils/readelf -a @@
    ```

    ```
    $ afl-fuzz -i fuzz_in -o fuzz_out ./binutils/objdump -SD @@
    ```
   
    ```
    $ afl-fuzz -i fuzz_in -o fuzz_out ./binutils/nm-new -C @@
    ```
   
    ```
    $ afl-fuzz -i fuzz_in -o fuzz_out2 ./binutils/strip-new -o output @@ 
    ```

    ```
     
    ```

### 6. 对expat进行fuzz

1. clone并编译expat项目

   ```
   $ git clone https://github.com/libexpat/libexpat.git
   $ cd libexpat/expat
   $ export CC=afl-gcc CXX=afl-g++
   $ ./configure --disable-shared
   $ make
   $ sudo make install 
   ```

   注意./configure时，需要--disable-shared

2. 创建fuzz_in文件夹，里面再创建testcase文件，为空

3. 开始fuzz，target为./xmlwf/xmlwf

   ```
   $ afl-fuzz -i fuzz_in -o fuzz_out ./xmlwf/xmlwf
   ```


### 7. 对xpdf进行fuzz

1. 下载并编译

   ```
   $ wget https://dl.xpdfreader.com/old/xpdf-3.02.tar.gz
   $ tar -xvzf xpdf-3.02.tar.gz
   $ cd xpdf-3.02
   $ export CC=afl-gcc CXX=afl-g++
   $ ./configure
   $ make
   ```

2. 创建fuzz_in文件夹，里面再创建testcase文件，为空

3. 开始fuzz，target为./xpdf/pdfimages

   ```
   $ afl-fuzz -i fuzz_in -o fuzz_out ./xpdf/pdfimages @@ 
   ```

   发现问题

   <img src="\\pictures\4.png" alt="4" style="zoom:80%;" />

### 8.对splite进行fuzz

1. 下载并编译

   进入https://www.sqlite.org/index.html进行下载

   ```
   $ tar -xvzf sqlite-autoconf-3400000.tar.gz
   $ cd sqlite-autoconf-3400000
   $ export CC=afl-gcc CXX=afl-g++
   $ ./configure
   $ make
   ```

2. 创建fuzz_in文件夹，里面再创建testcase文件，内容为hello

3. 开始fuzz，目标为sqlite3

   ```
   $ afl-fuzz -i fuzz_in -o fuzz_out ./sqlite3 @@
   ```


### 9.对matio进行fuzz

1. 下载并编译

   ```
   $ git clone https://github.com/tbeu/matio.git
   $ cd matio
   $ export CC=afl-gcc CXX=afl-g++
   $ ./configure --disable-shared
   $ make
   ```

   注意./configure时，需要加--disable-shared

2. 创建fuzz_in文件夹，里面再创建testcase文件，内容为hello

3. 开始fuzz，目标为./tools/matdump

   ```
   $ afl-fuzz -i fuzz_in -o fuzz_out ./tools/matdump @@
   ```

   

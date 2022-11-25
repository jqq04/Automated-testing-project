### 1. Mull安装

1. 系统环境 ubuntu 20.04

   参考：

   [Welcome to Mull’s documentation! — Mull 0.19.0 documentation](https://mull.readthedocs.io/en/0.19.0/)

2. 设置 apt-repository

   ```
   $ curl -1sLf 'https://dl.cloudsmith.io/public/mull-project/mull-stable/setup.deb.sh' | sudo -E bash
   ```

   如果提示Command 'curl' not found，先安装curl

   ```
   $ sudo apt install curl
   ```

3. 安装软件包，（mull-12适用于ubuntu20.04）

   ```
   $ sudo apt-get update
   $ sudo apt-get install mull-12
   ```

4. 检查是否安装成功

   ```
   $ mull-runner-12 --version
   ```

   显示：

   ![image-20221121202250624](C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20221121202250624.png)

### 2. Mull简单测试

1. 安装Clang 12（c++编译器，clang12 对应于mull-12版本）

   ```
   $ sudo apt install clang-12
   ```

2. 选择一个地方，创建一个简单的c++程序 main.cpp

   ```
   int main() {
     return 0;
   }
   ```

   然后编译，会生成hello-world文件

   ```
   $ clang-12 main.cpp -o hello-world
   ```

3. 测试mull

   ```
   $ mull-runner-12 ./hello-world
   ```

   ![image-20221121203411328](C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20221121203411328.png)

   此时Mull已准备好使用可执行文件，但是没有变异体，需要将插件传递给clang

4. ```
   $ clang-12 -fexperimental-new-pass-manager \
     -fpass-plugin=/usr/local/lib/mull-ir-frontend-12 \
     -g -grecord-command-line \
     main.cpp -o hello-world
   ```

   

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


### 2. binutils

1. ```
   $ wget https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz
   $ tar -zxvf binutils-2.37.tar.gz -C ./
   $ cd binutils-2.37
   ```

2. 在项目根目录（或上一级目录）放置mull.yml，内容如下：

   ```
   mutators: # 使用的变异算子，参考官方文档"Supported Mutation Operators"页面
   - cxx_add_to_sub
   - cxx_logical
   excludePaths: # 被指定的路径下所有文件不会产生变异体，支持正则表达式，也可以直接写需要排除的代码文件的路径+文件名。参考官方文档Tutorials/Keeping #mutants under control/File Path Filters
   - gtest
   - gmock
   timeout: 3000 # 设置每个变异体的超时时间，默认单位为毫秒 
   quiet: false # 静默模式开关，若设为true，则编译时不会输出编译日志
   ```

3. mull插桩编译

   ```
   $ export CC=clang-12
   $ export CFLAGS="-O0 -fexperimental-new-pass-manager -fpass-plugin=/usr/lib/mull-ir-frontend-12 -g -grecord-command-line"
   $ ./configure
   $ ./make
   ```

   注意：CFLAGS中mull-12对应-O0，mull-10对应-O1；-fpass-plugin为mull-ir-frontend-12的地址，如果不知道地址可以命令行输入$whereis mull-ir-frontend-12查询

4. mull-runner

   ```
   $ mull-runner-12 ${target} ${testcase} --report-dir ${reportdir}
   ```

   其他可选的参数包括：

   --report-name filename：打印的报告名

   --report-dir directory：打印的报告地址

   --reporters reporter：报告类型，可选的有IDE（stdout）、SQLite、Elements（json文件）、Patches、GithubAnnotations

   --no-output：设置后屏蔽二进制程序本身的标准输出和标准错误

   --timeout number：每轮测试循环的超时时间，默认单位为毫秒

5. 将上述内容（3-4），编写成脚本自动运行（脚本放置项目根目录运行），该脚本会针对binutils下的6个target，以前面afl的fuzz_out结果作为输入（待测测试用例），进行mull-runner变异测试，并将结果存储至对应的report_dir。

   脚本内容：

   ```
   #!/bin/bash
   
   export CC=clang-12
   export CFLAGS="-O0 -fexperimental-new-pass-manager -fpass-plugin=/usr/lib/mull-ir-frontend-12 -g -grecord-command-line"
   
   ./configure
   ./make
   
   target_arr=("size" "readelf" "objdump" "cxxfilt" "strip_new" "nm_new")​
   for target in ${target_arr[@]}; do
   	dir=`ls ../${target}_fuzz_out/queue`
   	for file in ${dir}; do
   		if [ ${file:10:3} = "src" ]; then
   			mull-runner-12 ./binutils/${target} ../${target}_fuzz_out/queue/${file} --report-dir ../${target}_report_dir  --reporters Elements --no-output --report-name $file
   		fi
   	done
   done
   
   
   ```

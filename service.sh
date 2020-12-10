#!/bin/sh
# set -x
###################################
#该脚本为Linux下启动java、python、bash程序的通用脚本。即可以作为开机自启动service脚本被调用，
#也可以作为启动程序的独立脚本来使用。
#
#Author: ironartisan, Date: 2020/12/9
#
#警告!!!：该脚本stop部分使用系统kill命令来强制终止指定的程序进程。
#在杀死进程前，未作任何条件检查。在某些情况下，如程序正在进行文件或数据库写操作，
#可能会造成数据丢失或数据不完整。如果必须要考虑到这类情况，则需要改写此脚本，
#增加在执行kill命令前的一系列检查。
###################################

###################################
#环境变量及程序执行参数
#需要根据实际环境以及Java程序名称来修改这些参数
###################################
#Java执行文件路径
JAVA_PATH="/usr/bin/java"

#Java参数
JAVA_OPTS=" -jar"

#Python执行文件路径
PYTHON_PATH="python"

#Python执行参数
PYTHON_OPTS=""

#Python执行文件路径
BASH_PATH="/usr/bin/sh"

#Python执行参数
BASH_OPTS=""

#执行的程序类型
EXEC_PREFIX="$JAVA_PATH $JAVA_OPTS"
# EXEC_PREFIX="PYTHON_PATH PYTHON_OPTS"
# EXEC_PREFIX="BASH_PATH BASH_OPTS"

#可执行文件的版本号
VERSION="0.8.4"

#程序的绝对路径
APP_PATH="/tmp/web-server-${VERSION}-withoutKafka.jar"


# 程序的名称，根据此名称寻找进程pid
SERVICE_NAME="web-server"


#初始化psid变量（全局）
psid=0

###################################
#
#为输出文字添加颜色
###################################
## blue to echo
blue(){
    echo -e "\033[35m $1 \033[0m"
}

## green to echo
green(){
    echo -e "\033[32m $1 \033[0m"
}

## Error to Infoing with blink
bred(){
    echo -e "\033[31m\033[01m\033[05m $1 \033[0m"
}

## Error to Infoing with blink
byellow(){
    echo -e "\033[33m\033[01m\033[05m $1 \033[0m"
}


## Error
red(){
    echo -e "\033[31m\033[01m $1 \033[0m"
}

## Infoing
yellow(){
    echo -e "\033[33m\033[01m $1 \033[0m"
}

###################################
#(函数)判断程序是否已启动
#
#说明：
#使用ps命令找出pid
#使用awk，分割出pid (1部分)，及程序名称(2部分)
###################################
checkpid() {
   javaps=`ps -ef|grep -w "$SERVICE_NAME"|grep -v "grep"|awk '{print $2}'`

   if [[ -n $javaps ]]; then
      psid="$javaps"
   else
      psid=0
   fi
}

###################################
#(函数)启动程序
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则提示程序已启动
#3. 如果程序没有被启动，则执行启动命令行
#4. 启动命令执行后，再次调用checkpid函数
#5. 如果步骤4的结果能够确认程序的pid,则打印[OK]，否则打印[Failed]
#注意：echo -n 表示打印字符后，不换行
#注意: "nohup 某命令 >/dev/null 2>&1 &" 的用法
###################################
start() {
   checkpid

   if [ $psid -ne 0 ]; then
      yellow "================================"
      yellow "Info: $SERVICE_NAME already started! (pid=$psid)"
      yellow "================================"
   else
      green  "Starting $SERVICE_NAME ..."
      # 执行的命令
      $EXEC_PREFIX  $APP_PATH >/dev/null 2>&1 &
      checkpid
      if [ $psid -ne 0 ]; then
         green "(pid=$psid) OK"
      else
         red "Failed"
      fi
   fi
}

###################################
#(函数)停止程序
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则开始执行停止，否则，提示程序未运行
#3. 使用kill -9 pid命令进行强制杀死进程
#4. 执行kill命令行紧接其后，马上查看上一句命令的返回值: $?
#5. 如果步骤4的结果$?等于0,则打印[OK]，否则打印[Failed]
#6. 为了防止程序被启动多次，这里增加反复检查进程，反复杀死的处理（递归调用stop）。
#注意：echo -n 表示打印字符后，不换行
#注意: 在shell编程中，"$?" 表示上一句命令或者一个函数的返回值
###################################
stop() {
   checkpid

   if [ $psid -ne 0 ]; then
      echo -n "Stopping $SERVICE_NAME ...(pid=$psid) "
      su - $RUNNING_USER -c "kill -9 $psid"
      if [ $? -eq 0 ]; then
         green "OK"
      else
         red "Failed"
      fi

      checkpid
      if [ $psid -ne 0 ]; then
         stop
      fi
   else
      yellow "================================"
      yellow "Info: $SERVICE_NAME is not running"
      yellow "================================"
   fi
}

###################################
#(函数)检查程序运行状态
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则提示正在运行并表示出pid
#3. 否则，提示程序未运行
###################################
status() {
   checkpid

   if [ $psid -ne 0 ];  then
      yellow "$SERVICE_NAME is running! (pid=$psid)"
   else
      yellow "$SERVICE_NAME is not running"
   fi
}


###################################
#读取脚本的第一个参数($1)，进行判断
#参数取值范围：{start|stop|restart|status}
#如参数不在指定范围之内，则打印帮助信息
###################################
case "$1" in
   'start')
      start
      ;;
   'stop')
     stop
     ;;
   'restart')
     stop
     start
     ;;
   'status')
     status
     ;;
  *)
     blue "Usage: $0 {start|stop|restart|status}"
     exit 1
esac
exit 0
# set +x
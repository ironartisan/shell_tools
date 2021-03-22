# shell_tools
本项目的目的在于提供shell tools模板
### 1. service.sh
主要针对自定义的程序提供stop|start|restart|status的功能，可添加到系统的service。 
启动方式：
1. bash脚本启动
   1.1 sh service.sh status #查看服务状态
   1.2 sh service.sh start  #启动服务
   1.3 sh service.sh start  #停止服务
   1.4 sh service.sh start  #重启服务
2. 使用系统自带命令systemd方式启动
  修改server.sh后放在/etc/rc.d/init.d下，修改后缀，例如将server.sh ->web
   2.1 systemd status web或service web status  #查看服务状态
   2.2 systemd start web或service web start  #启动服务
   2.3 systemd stop web或service web stop  #停止服务
   2.4 systemd restart web或service web restart  #重启服务
 

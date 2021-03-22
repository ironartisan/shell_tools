# shell_tools
本项目的目的在于提供shell tools模板，可支持shell、java、python程序。
### 1. service.sh
主要针对自定义的程序提供stop|start|restart|status的功能，可添加到系统的service。 
#### 启动方式：
```
1. bash脚本启动
   sh service.sh status #查看服务状态
   sh service.sh start  #启动服务
   sh service.sh stop  #停止服务
   sh service.sh restart  #重启服务
2. 使用系统自带命令systemd方式启动
  修改server.sh后放在/etc/rc.d/init.d下，修改后缀，例如将server.sh ->web
   systemd status web或service web status  #查看服务状态
   systemd start web或service web start  #启动服务
   systemd stop web或service web stop  #停止服务
   systemd restart web或service web restart  #重启服务
```
#### 注意事项
1. service.sh中的SERVICE_NAME不能与最后修改的文件名一致。
# fn-docker-delay
本项目用于弥补目前Fnos无法对容器进行延时启动的缺陷

# 前言
在某些情况下，我们可能希望在启动 Docker 容器时存在先后顺序，以确保某些前置条件已经满足，例如等待数据库初始化完成、等待cd2完成挂载后再运行其他容器等等。目前飞牛docker暂不具有延时方面的相关功能，为此笔者写了一个简单的脚本项目来实现这一功能，脚本执行后会按用户要求创建一个服务，并按用户设置对容器进行启用（目前系统更新不会对用户创建的服务做更改），整体操作非常简单！
# 执行脚本
打开终端，输入一下命令，回车执行：

`curl -s https://raw.githubusercontent.com/sky300/fn-docker-delay/refs/heads/main/fndocker.sh -o /tmp/fndocker.sh && sudo bash /tmp/fndocker.sh && rm /tmp/fndocker.sh`

<img width="1317" height="540" alt="image" src="https://github.com/user-attachments/assets/420631a3-71e1-49dc-8a9e-67600a53d111" />

创建完成后，即可重启查看效果，无需进行其他设置。
此外，后续我们也可以直接对配置文件进行修改，默认位于/vol1/1000/config下，该脚本没有任何限制，完全可自定义，你也可以拿他来做别的事情。手动修改完成后，务必再次授予他可执行权限：

chmod +x /你的目录/start_docker.sh

🛠 开源代码引用

[宅着做贡献](https://gitee.com/ewedl/fn-docker-delay/tree/master)

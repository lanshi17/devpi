# devpi Podman 用户服务部署指南

本文档说明如何使用 rootless Podman 和用户级 systemd 服务部署 devpi。

## 1. 构建镜像

```bash
cd /home/yangzs/devpi
podman build -t devpi-image .
```

## 2. 创建数据目录

```bash
mkdir -p /home/yangzs/devpi/data
```

## 3. 启用 linger

为了让 `systemctl --user` 管理的服务在用户退出登录后继续运行，请执行：

```bash
loginctl enable-linger <user>
```

## 4. 安装用户级 systemd 服务

```bash
mkdir -p ~/.config/systemd/user/
cp /home/yangzs/devpi/devpi-container.service ~/.config/systemd/user/devpi-container.service
systemctl --user daemon-reload
systemctl --user enable --now devpi-container.service
```

## 5. 检查服务状态

```bash
systemctl --user status devpi-container.service
journalctl --user -u devpi-container.service -n 50
```

## 6. 常用服务管理命令

```bash
systemctl --user restart devpi-container.service
systemctl --user stop devpi-container.service
systemctl --user start devpi-container.service
systemctl --user disable devpi-container.service
```

## 7. 手动启动容器

如果暂时不想通过 systemd 管理，也可以直接使用 `podman run`：

```bash
podman run -d \
  --name devpi-container \
  -p 3141:3141 \
  -v /home/yangzs/devpi/data:/root/.devpi/server:z \
  devpi-image
```

## 8. 验证服务

```bash
curl http://localhost:3141
```

## 9. 故障排除

查看容器日志：

```bash
podman logs devpi-container
```

查看容器状态：

```bash
podman ps -a --filter name=devpi-container
```

停止并清理容器：

```bash
systemctl --user stop devpi-container.service
podman rm -f devpi-container
```

## 10. 目录与路径约定

- 项目目录：`/home/yangzs/devpi`
- 数据目录：`/home/yangzs/devpi/data`
- 用户服务目录：`~/.config/systemd/user/`
- 服务管理命令：`systemctl --user`

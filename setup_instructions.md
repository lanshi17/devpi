# devpi Docker 用户服务部署指南

本文档说明如何使用 Docker 和用户级 systemd 服务部署 devpi。

## 1. 构建镜像

```bash
cd /path/to/devpi
docker build -t devpi-image .
```

## 2. 创建数据目录

```bash
mkdir -p /path/to/devpi/data
```

## 3. 启用 linger

为了让 `systemctl --user` 管理的服务在用户退出登录后继续运行，请执行：

```bash
loginctl enable-linger <user>
```

## 4. 安装用户级 systemd 服务

```bash
mkdir -p ~/.config/systemd/user/
cp /path/to/devpi/devpi-container.service ~/.config/systemd/user/devpi-container.service
systemctl --user daemon-reload
systemctl --user enable --now devpi-container.service
```

> `devpi-container.service` 里的 `-v` 是绝对路径。仓库不在 `/mnt/data/Projects/Tools/Utilities/devpi` 时，先改成实际路径再启用服务。

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

如果暂时不想通过 systemd 管理，也可以直接使用 `docker run`：

```bash
docker run -d \
  --name devpi-container \
  -p 127.0.0.1:3141:3141 \
  -v /path/to/devpi/data:/root/.devpi/server \
  devpi-image:latest
```

## 8. 验证服务

```bash
curl http://localhost:3141
```

## 9. 故障排除

查看容器日志：

```bash
docker logs devpi-container
```

查看容器状态：

```bash
docker ps -a --filter name=devpi-container
```

停止并清理容器：

```bash
systemctl --user stop devpi-container.service
docker rm -f devpi-container
```

## 10. 目录与路径约定

- 项目目录：`/path/to/devpi`
- 数据目录：`/path/to/devpi/data`
- 用户服务目录：`~/.config/systemd/user/`
- 服务管理命令：`systemctl --user`

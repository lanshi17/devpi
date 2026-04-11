# DevPI 私有 PyPI 镜像

这是一个基于 `devpi-server` 的极简私有 PyPI 镜像方案，使用仓库内的镜像构建文件构建镜像，并通过 rootless Podman 部署运行。

## 特性

- 使用仓库自带的镜像构建文件构建镜像
- 使用 rootless Podman 运行容器
- 统一数据目录为 `/home/yangzs/devpi/data`
- 通过 `systemctl --user` 管理用户级 systemd 服务
- 使用 USTC 上游镜像，加快中国大陆环境下的包下载
- 本地缓存已下载的包，提升后续安装速度

## 项目结构

```text
devpi/
├── 镜像构建文件
├── devpi-container.service
├── start-devpi.sh
├── setup_instructions.md
├── README.md
└── README_zh.md
```

## 环境要求

- Podman 4+
- 支持用户级 systemd 服务
- 系统提供 `loginctl` 用于 linger 配置
- 至少 1 GB 可用磁盘空间用于包缓存

## 快速开始

### 1. 构建镜像

```bash
podman build -t devpi-image .
```

### 2. 准备数据目录

```bash
mkdir -p /home/yangzs/devpi/data
```

### 3. 手动启动容器

```bash
podman run -d \
  --name devpi-container \
  -p 3141:3141 \
  -v /home/yangzs/devpi/data:/root/.devpi/server:z \
  devpi-image
```

### 4. 验证服务

```bash
curl http://localhost:3141
```

## Rootless Podman 用户服务

为了让用户服务在登出后仍可运行，先启用 linger：

```bash
loginctl enable-linger <user>
```

安装并启动用户级服务：

```bash
mkdir -p ~/.config/systemd/user/
cp devpi-container.service ~/.config/systemd/user/devpi-container.service
systemctl --user daemon-reload
systemctl --user enable --now devpi-container.service
```

常用管理命令：

```bash
systemctl --user status devpi-container.service
systemctl --user restart devpi-container.service
systemctl --user stop devpi-container.service
journalctl --user -u devpi-container.service -n 50
```

## 使用方法

临时安装包：

```bash
pip install -i http://localhost:3141/root/pypi/ <package_name> --trusted-host localhost
```

永久配置 pip：

```bash
pip config set global.index-url http://localhost:3141/root/pypi/
pip config set global.trusted-host localhost
```

恢复默认 PyPI：

```bash
pip config unset global.index-url
pip config unset global.trusted-host
```

## 管理命令

进入正在运行的容器：

```bash
podman exec -it devpi-container bash
```

查看日志：

```bash
podman logs devpi-container
```

停止并删除容器：

```bash
podman stop devpi-container
podman rm devpi-container
```

## 配置说明

- 上游镜像：`https://pypi.mirrors.ustc.edu.cn/simple/`
- 默认用户：`root`
- 默认索引：`root/pypi`
- 数据目录：`/home/yangzs/devpi/data`
- 服务管理方式：`systemctl --user`
- 运行模式：`rootless` Podman

## 故障排查

如果用户服务启动失败：

```bash
systemctl --user status devpi-container.service
journalctl --user -u devpi-container.service -n 100
```

如果容器异常退出：

```bash
podman logs devpi-container
podman ps -a --filter name=devpi-container
```

如果安装包失败，可检查镜像源和本地服务：

```bash
curl -I https://pypi.mirrors.ustc.edu.cn/simple/
curl http://localhost:3141
```

## 参考资料

- [DevPI Documentation](https://devpi.net/)
- [USTC PyPI Mirror](https://mirrors.ustc.edu.cn/help/pypi.html)

# DevPI 私有 PyPI 镜像

这是一个基于 `devpi-server` 的极简私有 PyPI 镜像方案，使用仓库内的镜像构建文件构建镜像，并通过 Docker 部署运行。

## 特性

- 使用仓库自带的镜像构建文件构建镜像
- 使用 Docker 运行容器
- 统一数据目录为 `/home/yangzs/devpi/data`
- 通过 `systemctl --user` 管理用户级 systemd 服务
- 上游镜像按索引配置保存在 devpi 数据库（当前为 `https://pypi.org/simple/`）
- 运行参数已调优：8 个服务线程、连接上限、容器日志轮转
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

- Docker 24+
- 支持用户级 systemd 服务
- 系统提供 `loginctl` 用于 linger 配置
- 至少 1 GB 可用磁盘空间用于包缓存

## 快速开始

### 1. 构建镜像

```bash
docker build -t devpi-image .
```

### 2. 准备数据目录

```bash
mkdir -p /home/yangzs/devpi/data
```

### 3. 手动启动容器

```bash
docker run -d \
  --name devpi-container \
  -p 3141:3141 \
  -v /home/yangzs/devpi/data:/root/.devpi/server \
  devpi-image
```

### 4. 验证服务

```bash
curl http://localhost:3141
```

## Docker 用户服务

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
docker exec -it devpi-container bash
```

查看日志：

```bash
docker logs devpi-container
```

停止并删除容器：

```bash
docker stop devpi-container
docker rm devpi-container
```

## 配置说明

- 上游镜像：`https://pypi.org/simple/`（按索引存储，可用 `devpi index root/pypi mirror_url=...` 修改）
- 服务参数：`--threads=8 --connection-limit=20`（已固化在镜像 ENTRYPOINT）
- 默认用户：`root`
- 默认索引：`root/pypi`
- 数据目录：`/home/yangzs/devpi/data`
- 服务管理方式：`systemctl --user`
- 运行模式：Docker

## 故障排查

如果用户服务启动失败：

```bash
systemctl --user status devpi-container.service
journalctl --user -u devpi-container.service -n 100
```

如果容器异常退出：

```bash
docker logs devpi-container
docker ps -a --filter name=devpi-container
```

如果安装包失败，可检查镜像源和本地服务：

```bash
curl -I https://pypi.org/simple/
curl http://localhost:3141
```

### 代理环境下 devpi 失效

开启网络代理后，localhost 流量可能被发送到代理服务器，导致 pip 无法访问本地 devpi。
解决方法：确保 `no_proxy` 环境变量包含 localhost：

```bash
# 临时生效
export no_proxy=localhost,127.0.0.1
export NO_PROXY=localhost,127.0.0.1

# 永久生效 (添加到 ~/.bashrc 或 ~/.zshrc)
echo 'export no_proxy=localhost,127.0.0.1' >> ~/.bashrc
```

容器内的 devpi-server 也需要排除 localhost 代理（已在 Dockerfile 中预设）。
如果使用自定义代理，启动容器时可传递代理变量：

```bash
docker run -d \
  --name devpi-container \
  -p 3141:3141 \
  -v /home/yangzs/devpi/data:/root/.devpi/server \
  -e no_proxy=localhost,127.0.0.1 \
  -e HTTP_PROXY=http://your-proxy:port \
  -e HTTPS_PROXY=http://your-proxy:port \
  devpi-image
```

## 参考资料

- [DevPI Documentation](https://devpi.net/)
- [PyPI Simple Index](https://pypi.org/simple/)

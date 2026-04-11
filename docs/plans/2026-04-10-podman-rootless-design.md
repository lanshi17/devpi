# DevPI Podman Rootless Migration Design

## Goal
将项目从 Docker-only 启动方式迁移为 Podman-only，并默认采用 rootless Podman + 用户级 systemd service。

## Confirmed Decisions
- 仅保留 Podman 用法，不再保留 Docker 兼容说明。
- 运行模式采用 rootless Podman。
- systemd 服务采用用户级服务，使用 `systemctl --user` 管理。
- 数据目录统一为 `/home/yangzs/devpi/data`。
- 镜像名保留为 `devpi-image`。
- 容器名保留为 `devpi-container`。
- 端口保留为 `3141`。

## Scope
修改以下现有文件：
- `Dockerfile`
- `start-devpi.sh`
- `devpi-container.service`
- `README.md`
- `README_zh.md`
- `setup_instructions.md`

不引入以下内容：
- docker-compose / podman-compose
- Quadlet
- Kubernetes
- 新的辅助脚本或新的目录结构

## Runtime Design
### Manual startup
手动运行路径保持极简：
1. `podman build -t devpi-image .`
2. `./start-devpi.sh`

`start-devpi.sh` 负责：
- 创建 `/home/yangzs/devpi/data`
- 停止并删除旧容器 `devpi-container`
- 用 Podman 启动新容器并映射 `3141:3141`
- 输出当前容器状态

### User systemd service
`devpi-container.service` 改为用户级 service，面向：
- `~/.config/systemd/user/devpi-container.service`
- `systemctl --user daemon-reload`
- `systemctl --user enable --now devpi-container.service`
- `systemctl --user status devpi-container.service`

文档中补充：
- 如需登录前/重启后保持用户服务可用，执行 `loginctl enable-linger <user>`。

### Restart strategy
由 systemd 统一负责重启策略，service 中保留 `Restart=always`。容器运行命令不叠加 `--restart=always`，避免 systemd 与容器运行时双重管理。

### Network model
统一为端口映射模式：
- `-p 3141:3141`

不再保留 `--network host` 的双分支文档。

## Documentation Design
所有文档统一改为 Podman-only：
- 构建命令用 `podman build`
- 运行命令用 `podman run`
- 管理命令用 `podman exec/logs/stop/rm/ps`
- 系统要求中的 Docker 改为 Podman
- 新增 rootless Podman 与用户级 systemd 服务说明
- 移除 Docker daemon、Docker service、host network 等叙述

## Verification Criteria
完成后应满足：
1. `start-devpi.sh` 中不再出现 `docker`。
2. `devpi-container.service` 中不再依赖 `docker.service`。
3. 主文档中的构建、运行、管理命令统一为 `podman`。
4. 文档中明确 rootless Podman + 用户级 systemd service。
5. 数据目录统一为 `/home/yangzs/devpi/data`。

## Git / Remote
已记录远端仓库为：`git@github.com:lanshi17/devpi.git`。
本次设计与实现不默认执行 git 初始化、remote 配置或推送，除非用户后续明确要求。
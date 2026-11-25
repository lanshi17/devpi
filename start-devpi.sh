#!/bin/bash

# devpi 容器启动脚本
# 服务端调优参数(线程数/连接上限)已内置在镜像 ENTRYPOINT 中。
CONTAINER_NAME="devpi-container"
IMAGE_NAME="devpi-image:latest"
PORT="3141"
# 数据目录固定为仓库内的 data/, 重建容器不会丢包(.gitignore 已忽略)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$BASE_DIR/data"

# 创建数据目录
mkdir -p "$DATA_DIR"

# 停止并删除已存在的容器
docker stop -t 30 "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null

# 启动新容器
# 传递宿主机代理设置,但确保 localhost 不走代理
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "127.0.0.1:$PORT":3141 \
  -v "$DATA_DIR":/root/.devpi/server \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  --restart=always \
  -e no_proxy=localhost,127.0.0.1 \
  -e NO_PROXY=localhost,127.0.0.1 \
  ${HTTP_PROXY:+-e HTTP_PROXY="$HTTP_PROXY"} \
  ${HTTPS_PROXY:+-e HTTPS_PROXY="$HTTPS_PROXY"} \
  "$IMAGE_NAME"

echo "devpi container started on port $PORT"
echo "Container name: $CONTAINER_NAME"
echo "Data directory: $DATA_DIR"

# 显示容器状态
docker ps -f name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

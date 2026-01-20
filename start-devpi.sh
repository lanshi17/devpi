#!/bin/bash

# devpi 容器启动脚本
CONTAINER_NAME="devpi-container"
IMAGE_NAME="devpi-image"
PORT="3141"
DATA_DIR="/mnt/data/Projects/Tools/Utilities/devpi/data"

# 创建数据目录
mkdir -p "$DATA_DIR"

# 停止并删除已存在的容器
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null

# 启动新容器
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "$PORT":"$PORT" \
  -v "$DATA_DIR":/root/.devpi/server \
  --restart=always \
  "$IMAGE_NAME"

echo "devpi container started on port $PORT"
echo "Container name: $CONTAINER_NAME"
echo "Data directory: $DATA_DIR"

# 显示容器状态
docker ps -f name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
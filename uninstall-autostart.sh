#!/bin/bash

# Devpi 自启动卸载脚本

set -e

SERVICE_NAME="devpi"

echo "=== Devpi 自启动卸载程序 ==="

# 检查是否为root用户
if [[ $EUID -eq 0 ]]; then
    echo "检测到root用户，将移除系统级systemd服务"
    SYSTEMD_DIR="/etc/systemd/system"
    SYSTEMCTL_CMD="systemctl"
else
    echo "移除用户级systemd服务"
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    SYSTEMCTL_CMD="systemctl --user"
fi

SERVICE_FILE_PATH="${SYSTEMD_DIR}/${SERVICE_NAME}.service"

# 检查服务是否存在
if [[ ! -f "$SERVICE_FILE_PATH" ]]; then
    echo "服务文件不存在: $SERVICE_FILE_PATH"
    echo "devpi自启动可能未安装"
    exit 0
fi

# 停止服务
echo "停止devpi服务..."
$SYSTEMCTL_CMD stop "$SERVICE_NAME.service" 2>/dev/null || true

# 禁用服务
echo "禁用devpi服务..."
$SYSTEMCTL_CMD disable "$SERVICE_NAME.service" 2>/dev/null || true

# 删除服务文件
echo "删除服务文件..."
rm -f "$SERVICE_FILE_PATH"

# 重新加载systemd
echo "重新加载systemd配置..."
$SYSTEMCTL_CMD daemon-reload

echo ""
echo "=== 卸载完成 ==="
echo "devpi自启动服务已移除"
echo "注意: Docker容器可能仍在运行，如需停止请手动执行:"
echo "  cd $(pwd) && docker-compose down"
#!/bin/bash

# Devpi 自启动安装脚本
# 此脚本将设置devpi服务器开机自启动

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="devpi"
SERVICE_FILE="${SCRIPT_DIR}/${SERVICE_NAME}.service"

echo "=== Devpi 自启动安装程序 ==="

# 检查是否为root用户
if [[ $EUID -eq 0 ]]; then
    echo "警告: 检测到root用户，将使用系统级systemd服务"
    SYSTEMD_DIR="/etc/systemd/system"
    SYSTEMCTL_CMD="systemctl"
else
    echo "使用用户级systemd服务"
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    SYSTEMCTL_CMD="systemctl --user"

    # 创建用户systemd目录
    mkdir -p "$SYSTEMD_DIR"
fi

# 检查docker-compose是否存在
if ! command -v docker-compose &> /dev/null; then
    echo "错误: docker-compose 未安装或不在PATH中"
    echo "请先安装docker-compose"
    exit 1
fi

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo "错误: Docker服务未运行"
    echo "请启动Docker服务: sudo systemctl start docker"
    exit 1
fi

# 检查服务文件是否存在
if [[ ! -f "$SERVICE_FILE" ]]; then
    echo "错误: 服务文件 $SERVICE_FILE 不存在"
    exit 1
fi

# 复制服务文件
echo "复制服务文件到 $SYSTEMD_DIR..."
if [[ $EUID -eq 0 ]]; then
    cp "$SERVICE_FILE" "$SYSTEMD_DIR/"
else
    cp "$SERVICE_FILE" "$SYSTEMD_DIR/"
fi

# 重新加载systemd
echo "重新加载systemd配置..."
$SYSTEMCTL_CMD daemon-reload

# 启用服务
echo "启用devpi服务..."
$SYSTEMCTL_CMD enable "$SERVICE_NAME.service"

# 启动服务
echo "启动devpi服务..."
$SYSTEMCTL_CMD start "$SERVICE_NAME.service"

# 检查状态
sleep 2
echo "检查服务状态..."
$SYSTEMCTL_CMD status "$SERVICE_NAME.service" --no-pager

echo ""
echo "=== 安装完成 ==="
echo "devpi服务已配置为开机自启动"
echo ""
echo "常用命令:"
echo "  查看状态: $SYSTEMCTL_CMD status $SERVICE_NAME"
echo "  启动服务: $SYSTEMCTL_CMD start $SERVICE_NAME"
echo "  停止服务: $SYSTEMCTL_CMD stop $SERVICE_NAME"
echo "  重启服务: $SYSTEMCTL_CMD restart $SERVICE_NAME"
echo "  禁用自启: $SYSTEMCTL_CMD disable $SERVICE_NAME"
echo ""
echo "服务将在系统重启后自动启动"
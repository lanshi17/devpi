#!/bin/bash

echo "配置uv和pip使用devpi私有PyPI服务器..."

# 创建用户级pip配置目录
mkdir -p ~/.pip

# 复制pip配置文件到用户配置目录
cp pip.conf ~/.pip/pip.conf
echo "pip配置已更新到 ~/.pip/pip.conf"

# 创建用户级uv配置目录
mkdir -p ~/.config/uv

# 复制uv配置文件到用户配置目录
cp uv.toml ~/.config/uv/uv.toml
echo "uv配置已更新到 ~/.config/uv/uv.toml"

echo ""
echo "配置完成！现在pip和uv将使用devpi服务器 (http://localhost:3141/lanshi/lanshiIndex/)"
echo ""
echo "使用方法："
echo "  pip install <package>    # 使用devpi服务器"
echo "  uv add <package>         # 使用devpi服务器"
echo ""
echo "注意：确保devpi服务器正在运行 (docker-compose up -d)"

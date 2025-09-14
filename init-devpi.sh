#!/bin/bash

# 等待devpi服务器启动
echo "等待devpi服务器启动..."
sleep 15

# 初始化devpi客户端
echo "初始化devpi客户端..."
devpi-client --version

# 连接到devpi服务器
echo "连接到devpi服务器..."
devpi use http://localhost:3141

# 登录（默认用户）
echo "登录到devpi服务器..."
devpi login root --password=""

# 创建新用户
echo "创建新用户..."
devpi user -c myuser password=mypassword

# 创建新索引
echo "创建新索引..."
devpi index -c myindex bases=root/pypi

# 切换到新索引
echo "切换到新索引..."
devpi use myuser/myindex

echo "devpi服务器初始化完成！"
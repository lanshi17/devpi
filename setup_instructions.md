# devpi 容器自启动设置指南

## 方案一：在线安装（推荐，当网络正常时）

### 1. 构建Docker镜像
```bash
cd /mnt/data/Projects/Tools/Utilities/devpi
docker build -t devpi-image .
```

### 2. 创建数据目录
```bash
mkdir -p /mnt/data/Projects/Tools/Utilities/devpi/data
```

### 3. 安装systemd服务
```bash
sudo cp devpi-container.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable devpi-container.service
sudo systemctl start devpi-container.service
```

### 4. 验证服务状态
```bash
sudo systemctl status devpi-container.service
```

## 方案二：离线安装（当网络不可用时）

### 1. 在有网络的机器上准备依赖包
```bash
# 创建requirements.txt
echo "devpi-server" > requirements.txt
echo "devpi-client" >> requirements.txt
echo "devpi-web" >> requirements.txt

# 下载wheel包
pip download -r requirements.txt -d ./wheels
```

### 2. 修改Dockerfile使用本地wheel包
```dockerfile
FROM python:3.8

# 复制wheel包并安装
COPY wheels /wheels
RUN pip install --no-index --find-links /wheels /wheels/*.whl

# 其余配置保持不变...
```

### 3. 将整个目录复制到目标机器并按方案一继续

## 手动启动容器（临时方案）

如果systemd服务暂时无法使用，可以手动启动容器：

```bash
# 启动容器（后台运行）
docker run -d --name devpi-container \
  -p 3141:3141 \
  -v /mnt/data/Projects/Tools/Utilities/devpi/data:/root/.devpi/server \
  devpi-image

# 设置开机自启动（通过crontab）
echo "@reboot docker start devpi-container" | crontab -
```

## 故障排除

### 检查容器日志
```bash
docker logs devpi-container
```

### 重启服务
```bash
sudo systemctl restart devpi-container.service
```

### 停止并清理
```bash
sudo systemctl stop devpi-container.service
sudo systemctl disable devpi-container.service
docker rm -f devpi-container
```
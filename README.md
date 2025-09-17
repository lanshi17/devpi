# 🐍 企业级私有PyPI Server

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat&logo=docker)](https://www.docker.com/)
[![DevPI](https://img.shields.io/badge/DevPI-Private%20PyPI-green?style=flat)](https://devpi.net/)
[![UV](https://img.shields.io/badge/UV-Package%20Manager-blue?style=flat)](https://github.com/astral-sh/uv)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

基于 Docker Compose 快速构建的企业级 devpi 私有 PyPI 服务器，集成现代 Python 包管理工具 UV，支持自启动和进程保护。

## ✨ 特性

- 🚀 **一键部署**: 使用 Docker Compose 快速启动
- 🔒 **用户管理**: 支持多用户和自定义索引
- 📦 **包管理**: 完整的包上传、下载和缓存功能
- 🔄 **自启动**: systemd 服务配置，系统重启自动启动
- 🛡️ **进程保护**: 自动故障重启和健康检查
- ⚡ **UV集成**: 支持现代 Python 包管理工具
- 💾 **数据持久化**: Docker 卷存储，数据安全可靠

## 📁 项目结构

```
devpi/
├── docker-compose.yml          # Docker服务编排文件
├── devpi.service              # systemd服务配置
├── init-devpi.sh              # devpi服务器初始化脚本
├── install-autostart.sh       # 自启动安装脚本
├── uninstall-autostart.sh     # 自启动卸载脚本
├── setup-client-config.sh     # 客户端配置脚本
├── pip.conf                   # pip配置文件模板
├── uv.toml                    # uv配置文件模板
├── devpi-usage.md             # devpi管理操作文档
├── uv-usage-example.md        # uv使用示例
└── SUCCESS.md                 # 部署验证指南
```

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd devpi
```

### 2. 启动服务
```bash
# 启动 Docker 服务
docker-compose up -d

# 等待服务初始化完成（约15秒）
sleep 15

# 访问服务
curl http://localhost:3141
```

### 3. 配置自启动（可选）
```bash
# 安装 systemd 自启动服务
./install-autostart.sh

# 检查服务状态
systemctl --user status devpi
```

### 4. 访问Web界面
打开浏览器访问: [http://localhost:3141](http://localhost:3141)

## 🔧 配置说明

### 服务配置
- **端口**: 3141
- **数据存储**: Docker 卷 `devpi_data`
- **网络**: 自定义桥接网络 `devpi_network`
- **健康检查**: 内置健康检查机制

### 默认用户和索引
| 用户 | 密码 | 角色 | 索引 |
|------|------|------|------|
| root | (无) | 管理员 | root/pypi |
| lanshi | mypassword | 普通用户 | lanshi/lanshiIndex |

## 📦 使用指南

### UV 包管理器配置

#### 方法1: 环境变量配置
```bash
export UV_INDEX_URL=http://localhost:3141/lanshi/lanshiIndex/+simple/
export UV_EXTRA_INDEX_URL=https://pypi.org/simple/
```

#### 方法2: 配置文件
创建 `uv.toml`:
```toml
[index]
url = "http://localhost:3141/lanshi/lanshiIndex/+simple/"
extra-index-url = ["https://pypi.org/simple/"]
```

#### 方法3: 使用配置脚本
```bash
./setup-client-config.sh
```

### 包操作示例

```bash
# 安装包
uv pip install requests

# 从指定索引安装
uv pip install --index http://localhost:3141/lanshi/lanshiIndex/+simple/ mypackage

# 发布包到私有PyPI
uv publish --repository http://localhost:3141/lanshi/lanshiIndex/ dist/*

# 创建虚拟环境并安装依赖
uv venv
uv pip install -r requirements.txt
```

### PIP 配置
使用提供的 `pip.conf` 模板配置 pip:
```bash
cp pip.conf ~/.pip/pip.conf
```

## 🛠️ 管理操作

### 用户管理
```bash
# 创建用户
docker exec devpi-server devpi user -c newuser password=newpass

# 修改密码
docker exec devpi-server devpi user -m lanshi password=newpassword

# 删除用户
docker exec devpi-server devpi user --delete username -y
```

### 索引管理
```bash
# 创建索引
docker exec devpi-server devpi index -c user/indexname

# 删除索引
docker exec devpi-server devpi index --delete user/indexname -y

# 列出所有索引
docker exec devpi-server devpi index -l
```

### 服务管理
```bash
# 启动/停止服务
docker-compose up -d / docker-compose down

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f

# systemd 服务管理（如已安装）
systemctl --user start/stop/restart devpi
systemctl --user status devpi
```

## 🔒 安全建议

### 生产环境配置
1. **修改默认密码**
   ```bash
   docker exec devpi-server devpi user -m lanshi password=your_secure_password
   ```

2. **配置HTTPS**
   - 使用反向代理（nginx/traefik）
   - 配置SSL证书

3. **网络安全**
   - 限制访问IP范围
   - 使用防火墙规则

4. **备份策略**
   ```bash
   # 备份数据卷
   docker run --rm -v devpi_data:/data -v $(pwd):/backup alpine tar czf /backup/devpi-backup.tar.gz /data

   # 恢复数据
   docker run --rm -v devpi_data:/data -v $(pwd):/backup alpine tar xzf /backup/devpi-backup.tar.gz -C /
   ```

## 🐛 故障排除

### 常见问题

**Q: 服务启动失败**
```bash
# 检查容器状态
docker-compose ps

# 查看详细日志
docker-compose logs devpi-server

# 重新构建并启动
docker-compose down && docker-compose up -d
```

**Q: 无法访问Web界面**
```bash
# 检查端口占用
netstat -tlnp | grep 3141

# 检查防火墙
sudo ufw status
```

**Q: systemd服务无法启动**
```bash
# 检查服务状态
systemctl --user status devpi

# 查看服务日志
journalctl --user -u devpi -f

# 重新安装服务
./uninstall-autostart.sh && ./install-autostart.sh
```

## 📋 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- Linux系统（推荐Ubuntu 20.04+）
- 至少 1GB 可用磁盘空间
- 网络端口 3141 可用

## 🤝 贡献

欢迎提交问题和改进建议！

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 相关链接

- [DevPI 官方文档](https://devpi.net/)
- [UV 包管理器](https://github.com/astral-sh/uv)
- [Docker Compose 文档](https://docs.docker.com/compose/)

## 📞 支持

如有问题，请查看：
- [故障排除](#-故障排除)部分
- [Issues](../../issues) 页面
- [devpi-usage.md](devpi-usage.md) 详细操作文档
# 🐍 DevPI 私有 PyPI 镜像  

这是一个基于 Docker 的简易私有 PyPI 镜像，适用于生产环境。它使用了 **devpi-server**，并利用来自中国镜像的缓存机制来加快包的下载速度。  

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker)  
![DevPI](https://img.shields.io/badge/DevPI-Private%20PyPI-green?style=flat)  
![许可证](https://img.shields.io/badge/License-MIT-yellow.svg)  

## ✨ 主要特性  

- **极简的搭建流程**：仅需一个 Dockerfile，无需安装复杂的依赖项。  
- **支持中国镜像**：配置为使用中国科学技术大学（USTC）的 PyPI 镜像以加快下载速度。  
- **懒加载机制**：仅在需要时才会下载包，从而节省带宽和存储空间。  
- **本地缓存**：自动缓存下载的包，方便后续快速访问。  
- **兼容 VPN 环境**：可通过主机网络模式在 VPN 环境中无缝使用。  
- **简单易用**：配置和使用的命令都非常简单。  

## 📁 项目结构  

```
devpi/
├── Dockerfile          # 极简的 devpi 服务器配置文件
└── README.md           # 项目文档  
```

## 🚀 快速入门  

### 1. 构建 Docker 镜像  

```bash
docker build -t devpi .  
```  

### 2. 运行 DevPI 服务器  

**普通环境:**  
```bash
docker run -d --name devpi -p 3141:3141 devpi  
```  

**推荐用于 VPN 环境:**  
```bash
docker run -d --name devpi --network host devpi  
```  
> **注意：** 如果你位于 VPN 环境中或遇到网络连接问题，请使用 `--network host` 选项。  

### 3. 验证安装是否成功  

通过以下命令检查服务器是否正在运行：  
```bash
curl http://localhost:3141  
```  
你应该能看到 devpi 的网页界面。  

## 🔧 使用方法  

### 暂时安装包  

使用 `pip` 和 `-i` 标志直接安装包：  

```bash
# 普通网络模式（使用端口 3141）
pip install -i http://localhost:3141/root/pypi/ <package_name> --trusted-host localhost  

# 主机网络模式（使用 `--network host`）  
pip install -i http://localhost:3141/root/pypi/ <package_name> --trusted-host localhost  
```  
**示例：**  
```bash
pip install -i http://localhost:3141/root/pypi/ requests --trusted-host localhost  
```  

### 永久性配置  

将 `pip` 的默认镜像地址设置为 DevPI 镜像：  
```bash
pip config set global.index-url http://localhost:3141/root/pypi/  
pip config set global.trusted-host localhost  
```  
如需恢复到默认的 PyPI 镜像，请执行：  
```bash
pip config unset global.index-url  
pip config unset global.trusted-host  
```  

## ⚙️ 配置细节  

### 上游镜像信息  
- **镜像地址**: `https://pypi.mirrors.ustc.edu.cn/simple/`  
- **提供者**: 中国科学技术大学（USTC）  
- **优势**: 在中国境内下载速度更快，服务更可靠。  

### 服务器设置  
- **端口**: 3141  
- **默认用户**: `root`（无需密码）  
- **默认索引目录**: `root/pypi`  
- **缓存策略**: 禁用缓存（`mirror_cacheexpiry = 0`），以实现即时更新。  

### 网络模式  

| 模式 | 命令            | 适用场景        |  
|--------|------------------|---------------------------|  
| **桥接模式** | `-p 3141:3141`      | 普通网络环境（非 VPN 环境）    |  
| **主机模式** | `--network host`      | VPN 环境或网络故障排查     |  

## 🔄 工作原理  

1. **首次请求时**：DevPI 从 USTC 镜像下载包。  
2. **本地缓存**：下载的包会被存储在容器内。  
3. **后续请求**：直接从本地缓存中提供包，从而节省带宽。  
4. **自动更新**：DevPI 会定期检查新版本的包。  

这种懒加载机制既节省了带宽，又提供了快速的本地访问速度，同时仍能访问完整的 PyPI 生态系统。  

## 🛠️ 管理命令  

### 在容器内访问 DevPI 命令行界面  

```bash
# 进入容器  
docker exec -it devpi bash  

# 使用 DevPI 命令  
devpi use http://localhost:3141  
devpi login root --password=  
devpi index root/pypi  
```  

### 查看服务器日志  
```bash
docker logs devpi  
```  

### 停止并删除容器  
```bash
docker stop devpi && docker rm devpi  
```  

## 🌐 Web 界面  
通过以下地址访问 DevPI 的 Web 界面：  
- **桥接模式**: [http://localhost:3141](http://localhost:3141)  
- **主机模式**: [http://localhost:3141](http://localhost:3141)  
该界面可以显示可用包、用户信息及服务器状态。  

## 🐛 常见问题及解决方法  

**问题：** 安装包时出现连接超时？  
- **解决方法**：如果在 VPN 环境中，使用 `--network host` 选项。  
- **另请检查**: 确保 Docker 守护进程的 DNS 配置正确。  

**问题：** 无法解析镜像地址？  
- **解决方法**: 检查主机的网络连接是否正常。  
- **验证方法**: 执行 `docker run --rm alpine nslookup pypi.mirrors.ustc.edu.cn`。  

**问题：** 出现权限错误？  
- **解决方法**: 在 `pip` 命令中加上 `--trusted-host localhost`。  

### 测试网络连接  
```bash  
# 测试基本的网络连接  
curl -s http://localhost:3141 | head -5  

# 测试包的可用性  
pip install -i http://localhost:3141/root/pypi/ click==7.0 --trusted-host localhost  
```  

## 📋 系统要求**  
- **Docker**: 版本 20.10 或更高。  
- **磁盘空间**: 至少需要 1GB 的空间用于缓存包。  
- **内存**: 推荐使用 512MB 以上的内存。  
- **网络**: 需要可上网的环境以便进行初始的包下载。  

## 🤝 贡献方式  

本项目采用极简的设计原则。如需添加新功能：  
1. 克隆项目仓库（`fork`）。  
2. 根据需求修改 `Dockerfile`。  
3. 充分测试新功能。  
4. 提交带有完整文档的 Pull Request。  

## 📄 许可证  
本项目采用 MIT 许可证。详细信息请参阅 [LICENSE](LICENSE) 文件。  

## 🔗 参考资料**  
- [原始教程](https://blog.jojo.host/posts/RSKUCql3or/)  
- [DevPI 文档](https://devpi.net/)  
- [USTC PyPI 镜像](https://mirrors.ustc.edu.cn/help/pypi.html)  

**欢迎使用这个私有 PyPI 镜像！** 🎉

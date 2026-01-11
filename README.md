# 🐍 DevPI Private PyPI Mirror

A minimal, production-ready Docker-based private PyPI mirror using **devpi-server** with upstream caching from Chinese mirrors for faster package downloads.

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker)
![DevPI](https://img.shields.io/badge/DevPI-Private%20PyPI-green?style=flat)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![中文](https://github.com/lanshi17/devpi/blob/master/README_zh.md)

## ✨ Features

- **🚀 Minimal Setup**: Single Dockerfile, no complex dependencies
- **🇨🇳 Chinese Mirror Support**: Configured to use USTC PyPI mirror for faster downloads
- **🔄 Lazy Loading**: Downloads packages only when requested, saving bandwidth and storage
- **💾 Local Caching**: Automatically caches downloaded packages for fast subsequent access
- **🌐 Host Network Ready**: Works seamlessly with VPN environments using host networking
- **🔧 Easy Configuration**: Simple commands for setup and usage

## 📁 Project Structure

```
devpi/
├── Dockerfile          # Minimal devpi server configuration
└── README.md           # This documentation
```

## 🚀 Quick Start

### 1. Build the Docker Image

```bash
docker build -t devpi .
```

### 2. Run the DevPI Server

**For normal environments:**
```bash
docker run -d --name devpi -p 3141:3141 devpi
```

**For VPN environments (recommended):**
```bash
docker run -d --name devpi --network host devpi
```

> **Note**: Use `--network host` if you're behind a VPN or experiencing network connectivity issues.

### 3. Verify Installation

Check if the server is running:
```bash
curl http://localhost:3141
```

You should see the devpi web interface HTML.

## 🔧 Usage

### Temporary Package Installation

Install packages directly using pip with the `-i` flag:

```bash
# For normal network mode (-p 3141:3141)
pip install -i http://localhost:3141/root/pypi/ <package_name> --trusted-host localhost

# For host network mode (--network host)
pip install -i http://localhost:3141/root/pypi/ <package_name> --trusted-host localhost
```

**Example:**
```bash
pip install -i http://localhost:3141/root/pypi/ requests --trusted-host localhost
```

### Permanent Configuration

Configure pip to always use your devpi mirror:

```bash
pip config set global.index-url http://localhost:3141/root/pypi/
pip config set global.trusted-host localhost
```

To revert back to default PyPI:
```bash
pip config unset global.index-url
pip config unset global.trusted-host
```

## ⚙️ Configuration Details

### Upstream Mirror
- **Mirror URL**: `https://pypi.mirrors.ustc.edu.cn/simple/`
- **Provider**: University of Science and Technology of China (USTC)
- **Benefits**: Faster downloads in China, reliable service

### Server Settings
- **Port**: 3141
- **Default User**: `root` (no password required)
- **Default Index**: `root/pypi`
- **Cache Expiry**: Disabled (`mirror_cache_expiry = 0`) for immediate updates

### Network Modes

| Mode | Command | Use Case |
|------|---------|----------|
| **Bridge** | `-p 3141:3141` | Normal environments without VPN |
| **Host** | `--network host` | VPN environments, network troubleshooting |

## 🔄 How It Works

1. **First Request**: When you request a package, devpi fetches it from the USTC mirror
2. **Local Cache**: The package is stored locally in the container
3. **Subsequent Requests**: Future requests are served directly from local cache
4. **Automatic Updates**: devpi checks for new package versions periodically

This lazy-loading approach saves bandwidth and provides fast local access while maintaining access to the full PyPI ecosystem.

## 🛠️ Management Commands

### Access DevPI CLI (inside container)
```bash
# Enter the container
docker exec -it devpi bash

# Use devpi commands
devpi use http://localhost:3141
devpi login root --password=
devpi index root/pypi
```

### View Server Logs
```bash
docker logs devpi
```

### Stop and Remove
```bash
docker stop devpi && docker rm devpi
```

## 🌐 Web Interface

Access the devpi web interface at:
- **Bridge Mode**: [http://localhost:3141](http://localhost:3141)
- **Host Mode**: [http://localhost:3141](http://localhost:3141)

The web interface shows available packages, user management, and server status.

## 🐛 Troubleshooting

### Common Issues

**Q: Connection timeout when installing packages**
- **Solution**: Use `--network host` mode if you're behind a VPN
- **Alternative**: Ensure your Docker daemon has proper DNS configuration

**Q: Cannot resolve mirror URLs**
- **Solution**: Check your host's internet connectivity
- **Verify**: `docker run --rm alpine nslookup pypi.mirrors.ustc.edu.cn`

**Q: Permission denied errors**
- **Solution**: Add `--trusted-host localhost` to your pip commands

### Testing Connectivity
```bash
# Test basic server access
curl -s http://localhost:3141 | head -5

# Test package availability
pip install -i http://localhost:3141/root/pypi/ click==7.0 --trusted-host localhost
```

## 📋 System Requirements

- **Docker**: 20.10+
- **Disk Space**: At least 1GB for package cache
- **Memory**: 512MB+ recommended
- **Network**: Internet access for initial package downloads

## 🤝 Contributing

This project follows a minimal philosophy. If you need additional features:

1. Fork the repository
2. Modify the `Dockerfile` as needed
3. Test thoroughly
4. Submit a pull request with clear documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 References

- [Original Tutorial](https://blog.jojo.host/posts/RSKUCql3or/)
- [DevPI Documentation](https://devpi.net/)
- [USTC PyPI Mirror](https://mirrors.ustc.edu.cn/help/pypi.html)

---

**Enjoy your private PyPI mirror!** 🎉

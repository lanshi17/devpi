# 企业级私有PyPI Server

基于docker-compose快速构建的devpi私有PyPI服务器，集成uv包管理工具。

## 目录结构
- `docker-compose.yml`: 服务编排文件
- `init-devpi.sh`: devpi服务器初始化脚本
- `uv-usage-example.md`: uv工具使用示例
- `SUCCESS.md`: 部署成功验证指南

## 快速开始

1. 启动服务：
   ```bash
   docker-compose up -d
   ```

2. 等待服务初始化完成（约15秒）

3. 访问 http://localhost:3141 查看devpi界面

## 服务详情

### devpi服务器
- 端口: 3141
- 数据持久化: 使用Docker卷存储，确保服务重启后数据不丢失
- 健康检查: 内置健康检查机制

### 默认用户和索引
- 管理员用户: root (无密码)
- 测试用户: lanshi (密码: mypassword)
- 默认索引: root/pypi
- 自定义索引: lanshi/lanshiIndex

## 使用uv与私有PyPI

### 配置uv使用私有PyPI服务器

#### 方法1：使用环境变量
```bash
export UV_INDEX_URL=http://localhost:3141/lanshi/lanshiIndex/+simple/
export UV_EXTRA_INDEX_URL=https://pypi.org/simple/
```

#### 方法2：使用配置文件
创建 `uv.toml` 文件:
```toml
[index]
url = "http://localhost:3141/lanshi/lanshiIndex/+simple/"
extra-index-url = ["https://pypi.org/simple/"]
```

### 使用uv安装包
```bash
# 从私有PyPI安装包
uv pip install package_name

# 从私有PyPI安装包并指定索引
uv pip install --index http://localhost:3141/lanshi/lanshiIndex/+simple/ package_name

# 发布包到私有PyPI
uv publish --repository http://localhost:3141/lanshi/lanshiIndex/ dist/*
```

## 在项目中使用
1. 创建 `requirements.txt` 或 `pyproject.toml`
2. 使用uv安装依赖:
```bash
uv pip install -r requirements.txt
```

## 注意事项
- 确保devpi服务器正在运行
- 如果使用认证，需要在URL中包含用户名和密码:
  `http://username:password@localhost:3141/lanshi/lanshiIndex/+simple/`
- 建议在生产环境中修改默认密码并配置HTTPS

## 验证部署成功
参考 `SUCCESS.md` 文件了解如何验证部署是否成功以及下一步建议。

## 下一步建议
1. 修改默认用户密码
2. 配置HTTPS以增强安全性
3. 设置备份策略保护数据
4. 根据团队需求创建更多用户和索引
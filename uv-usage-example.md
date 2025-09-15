# 使用uv与私有PyPI服务器

## 配置uv使用私有PyPI服务器

### 方法1：使用环境变量
```bash
export UV_INDEX_URL=http://localhost:3141/lanshi/lanshiIndex/+simple/
export UV_EXTRA_INDEX_URL=https://pypi.org/simple/
```

### 方法2：使用配置文件
创建 `uv.toml` 文件:
```toml
[index]
url = "http://localhost:3141/lanshi/lanshiIndex/+simple/"
extra-index-url = ["https://pypi.org/simple/"]
```

## 使用uv安装包
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
# DevPI 用户和索引管理操作

本文档记录了在 DevPI 服务器上执行的用户和索引管理操作。

## 环境信息

- DevPI 服务器运行在 Docker 容器中
- 容器名称: `devpi-server`
- 访问地址: http://localhost:3141

## 执行的操作

### 1. 修改用户密码

**操作**: 修改用户 `lanshi` 的密码为 `Yzs20030317`

```bash
docker exec devpi-server devpi user -m lanshi password=Yzs20030317
```

**输出**:
```
/lanshi changing password: ********
user modified: lanshi
```

### 2. 删除用户

**操作**: 删除用户 `myuser`

```bash
docker exec devpi-server devpi user --delete myuser -y
```

**输出**:
```
About to remove: <URL 'http://localhost:3141/myuser'>
Are you sure (yes/no)? yes (autoset from -y option)
user deleted: myuser
```

### 3. 删除索引

**操作**: 删除索引 `root/myindex`

```bash
docker exec devpi-server devpi index --delete root/myindex -y
```

**输出**:
```
About to remove: <URL 'http://localhost:3141/root/myindex'>
Are you sure (yes/no)? yes (autoset from -y option)
index deleted: <URL 'http://localhost:3141/root/myindex'>
```

## 常用命令参考

### 用户管理

- 创建用户: `devpi user -c <username> password=<password>`
- 修改用户: `devpi user -m <username> <key=value>`
- 删除用户: `devpi user --delete <username> -y`
- 列出用户: `devpi user -l`

### 索引管理

- 创建索引: `devpi index -c <user>/<index>`
- 删除索引: `devpi index --delete <user>/<index> -y`
- 列出索引: `devpi index -l`

### 注意事项

1. 使用 `-y` 参数可以自动确认删除操作，避免交互式确认
2. 在 Docker 容器中执行命令需要使用 `docker exec devpi-server` 前缀
3. 删除操作是不可逆的，请谨慎操作
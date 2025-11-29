# SSH免密登录指南

## ✅ 当前状态

SSH密钥连接已配置，可以免密登录。

## 🔧 使用方法

### 方法1：使用SSH密钥连接（推荐）

```bash
# 在本地Mac终端执行
ssh -i ~/.ssh/id_rsa root@47.243.177.166

# 或者如果密钥已添加到ssh-agent，可以直接：
ssh root@47.243.177.166
```

### 方法2：配置SSH别名（更方便）

编辑 `~/.ssh/config` 文件：

```bash
# 编辑SSH配置
nano ~/.ssh/config
# 或
vim ~/.ssh/config
```

添加以下内容：

```
Host video-server
    HostName 47.243.177.166
    User root
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
```

保存后，就可以直接使用：

```bash
ssh video-server
```

## ⚠️ 常见问题

### 问题1：提示输入密码

**原因**：
- 没有使用 `-i ~/.ssh/id_rsa` 参数
- 或者密钥权限不正确

**解决方法**：
```bash
# 检查密钥权限
chmod 600 ~/.ssh/id_rsa

# 使用密钥连接
ssh -i ~/.ssh/id_rsa root@47.243.177.166
```

### 问题2：在服务器上执行命令需要密码

**原因**：
- 某些命令需要 `sudo` 权限
- 或者文件权限问题

**解决方法**：
```bash
# 如果已经是root用户，不需要sudo
# 如果提示密码，可能是：
# 1. 不是root用户
# 2. 需要sudo权限

# 检查当前用户
whoami

# 如果是root，所有命令都不需要密码
```

### 问题3：某些操作需要密码

**可能的原因**：
1. **文件操作权限**：某些文件可能属于其他用户
2. **服务操作**：systemctl等命令可能需要密码

**解决方法**：
```bash
# 检查文件权限
ls -l /path/to/file

# 修复权限（如果是root用户）
chown root:root /path/to/file
chmod 644 /path/to/file
```

## 📝 快速命令

### 查看删除日志

```bash
ssh -i ~/.ssh/id_rsa root@47.243.177.166 "tail -100 /tmp/video_server.log | grep -A 20 '删除\|delete'"
```

### 重启服务器

```bash
ssh -i ~/.ssh/id_rsa root@47.243.177.166 "cd /root/video_server && pkill -9 -f video_server.py && nohup python3 video_server.py > /tmp/video_server.log 2>&1 &"
```

### 查看服务器状态

```bash
ssh -i ~/.ssh/id_rsa root@47.243.177.166 "ps aux | grep video_server"
```

## 🎯 建议

1. **使用SSH别名**：配置 `~/.ssh/config` 后更方便
2. **确保使用密钥**：总是使用 `-i ~/.ssh/id_rsa` 参数
3. **检查权限**：确保密钥文件权限是 `600`

---

**如果还是提示密码，请告诉我：**
1. 你在哪里输入的命令？（本地Mac终端？还是服务器上？）
2. 具体是什么命令提示要密码？
3. 错误信息是什么？











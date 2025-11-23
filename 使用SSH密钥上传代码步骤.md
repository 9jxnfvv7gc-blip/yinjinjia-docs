# 使用SSH密钥上传代码步骤

## ✅ 当前状态

- ✅ 本地已有SSH密钥（`id_rsa` 和 `id_rsa.pub`）
- ⏳ 需要测试密钥登录
- ⏳ 需要上传代码到服务器

---

## 📋 操作步骤

### 步骤1：查看公钥内容

```bash
# 查看公钥内容（需要添加到服务器）
cat ~/.ssh/id_rsa.pub
```

**复制输出的公钥内容**（以 `ssh-rsa` 开头的一行）

---

### 步骤2：测试密钥登录

```bash
# 使用密钥登录测试
ssh -i ~/.ssh/id_rsa root@47.243.177.166
```

**可能的结果**：

1. **如果成功登录**：
   - 会显示服务器信息
   - 说明密钥已配置好
   - 输入 `exit` 退出
   - 继续步骤4

2. **如果提示 "Permission denied"**：
   - 说明服务器还没有你的公钥
   - 需要添加公钥到服务器
   - 继续步骤3

---

### 步骤3：添加公钥到服务器（如果需要）

#### 方法A：使用Workbench添加

1. **在本地查看公钥**：
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```

2. **复制公钥内容**（整行，以 `ssh-rsa` 开头）

3. **在服务器Workbench终端执行**：
   ```bash
   # 创建.ssh目录（如果不存在）
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   
   # 添加公钥（将下面的内容替换为你的公钥）
   echo "你的公钥内容" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

4. **验证**：
   ```bash
   cat ~/.ssh/authorized_keys
   ```

---

### 步骤4：使用rsync上传代码

#### 如果密钥登录成功，使用以下命令：

```bash
rsync -avz --progress -e "ssh -i ~/.ssh/id_rsa" \
  /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/ \
  root@47.243.177.166:/root/app/ \
  --exclude='build/' \
  --exclude='.dart_tool/' \
  --exclude='ios/' \
  --exclude='macos/' \
  --exclude='web/'
```

**或者使用单行命令**：

```bash
rsync -avz --progress -e "ssh -i ~/.ssh/id_rsa" /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/ root@47.243.177.166:/root/app/ --exclude='build/' --exclude='.dart_tool/' --exclude='ios/' --exclude='macos/' --exclude='web/'
```

---

## 🔍 详细说明

### 1. 查看公钥

```bash
cat ~/.ssh/id_rsa.pub
```

**输出示例**：
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... xiaohuihu@mac
```

**复制整行内容**（从 `ssh-rsa` 到结尾）

---

### 2. 测试密钥登录

```bash
ssh -i ~/.ssh/id_rsa root@47.243.177.166
```

**如果成功**：
```
Welcome to Alibaba Cloud Elastic Compute Service !
Last login: ...
root@iZj6cg78ov73x6cxbephc1Z:~#
```

**如果失败**：
```
Permission denied (publickey).
```

---

### 3. 添加公钥到服务器

在服务器Workbench终端：

```bash
# 创建目录
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 添加公钥（替换为你的公钥）
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... xiaohuihu@mac" >> ~/.ssh/authorized_keys

# 设置权限
chmod 600 ~/.ssh/authorized_keys

# 验证
cat ~/.ssh/authorized_keys
```

---

### 4. 使用rsync上传

```bash
rsync -avz --progress -e "ssh -i ~/.ssh/id_rsa" \
  /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/ \
  root@47.243.177.166:/root/app/ \
  --exclude='build/' \
  --exclude='.dart_tool/' \
  --exclude='ios/' \
  --exclude='macos/' \
  --exclude='web/'
```

**参数说明**：
- `-a`: 归档模式（保持文件属性）
- `-v`: 详细输出
- `-z`: 压缩传输
- `--progress`: 显示进度
- `-e "ssh -i ~/.ssh/id_rsa"`: 使用指定的SSH密钥
- `--exclude`: 排除不需要的目录

---

## 📝 快速命令总结

### 1. 查看公钥：
```bash
cat ~/.ssh/id_rsa.pub
```

### 2. 测试登录：
```bash
ssh -i ~/.ssh/id_rsa root@47.243.177.166
```

### 3. 上传代码（单行）：
```bash
rsync -avz --progress -e "ssh -i ~/.ssh/id_rsa" /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/ root@47.243.177.166:/root/app/ --exclude='build/' --exclude='.dart_tool/' --exclude='ios/' --exclude='macos/' --exclude='web/'
```

---

## 💡 提示

1. **如果密钥登录失败**：需要先在服务器上添加公钥
2. **如果上传中断**：rsync支持断点续传，重新运行命令即可
3. **上传时间**：取决于文件大小，通常几分钟到十几分钟

---

**现在可以开始操作了！** 🚀


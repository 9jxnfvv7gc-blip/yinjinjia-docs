# 解决SSH密码登录失败问题

## ❌ 问题描述

SSH密码登录失败，提示"操作系统禁用了密码登录方式"。

---

## ✅ 解决方案

### 方案1：使用SSH密钥登录（推荐）

#### 步骤1：检查本地是否有SSH密钥

```bash
# 检查SSH密钥
ls -la ~/.ssh/
```

**如果看到 `id_rsa` 和 `id_rsa.pub`**：
- 说明已有SSH密钥
- 继续步骤2

**如果没有SSH密钥**：
- 需要生成新的SSH密钥（见方案2）

---

#### 步骤2：检查服务器是否已有公钥

在服务器Workbench终端执行：

```bash
# 检查authorized_keys
cat ~/.ssh/authorized_keys
```

**如果看到你的公钥**：
- 可以直接使用密钥登录
- 继续步骤3

**如果没有公钥**：
- 需要添加公钥到服务器（见步骤4）

---

#### 步骤3：使用SSH密钥登录

```bash
# 使用密钥登录
ssh -i ~/.ssh/id_rsa root@47.243.177.166
```

**如果成功**：
- 可以直接登录
- 然后使用rsync上传代码

---

#### 步骤4：添加公钥到服务器（如果需要）

**方法A：使用Workbench**

1. 在本地查看公钥：
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
2. 复制公钥内容
3. 在服务器Workbench终端执行：
   ```bash
   # 创建.ssh目录（如果不存在）
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   
   # 添加公钥
   echo "你的公钥内容" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

---

### 方案2：使用Workbench直接上传文件（最简单）

#### 步骤1：在Workbench中打开文件管理器

1. 登录阿里云Workbench
2. 连接到服务器
3. 使用文件上传功能

#### 步骤2：上传项目文件

1. 选择要上传的文件/文件夹
2. 上传到 `/root/app/` 目录
3. 排除不需要的目录：
   - `build/`
   - `.dart_tool/`
   - `ios/`
   - `macos/`
   - `web/`

---

### 方案3：生成新的SSH密钥（如果没有）

#### 步骤1：生成SSH密钥

```bash
# 生成SSH密钥（如果还没有）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 按提示操作：
# - 保存位置：直接回车（使用默认位置）
# - 密码：可以设置密码或直接回车（不设置密码）
```

#### 步骤2：查看公钥

```bash
# 查看公钥内容
cat ~/.ssh/id_rsa.pub
```

#### 步骤3：添加公钥到服务器

在服务器Workbench终端执行：

```bash
# 创建.ssh目录
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 添加公钥（将下面的内容替换为你的公钥）
echo "你的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

### 方案4：重新启用密码登录（不推荐）

如果需要重新启用密码登录：

1. **在阿里云控制台重置密码**
2. **通过VNC连接服务器**
3. **修改SSH配置**：
   ```bash
   # 编辑SSH配置
   sudo vi /etc/ssh/sshd_config
   
   # 找到并修改：
   PasswordAuthentication yes
   
   # 重启SSH服务
   sudo systemctl restart sshd
   ```

**注意**：不推荐，因为密钥登录更安全。

---

## 🎯 推荐操作流程

### 最简单的方法：使用Workbench上传

1. **打开Workbench**
2. **使用文件上传功能**
3. **上传项目文件夹到 `/root/app/`**

---

### 如果要用rsync：配置SSH密钥

1. **检查是否有SSH密钥**：
   ```bash
   ls -la ~/.ssh/id_rsa*
   ```

2. **如果有密钥**：
   - 使用 `ssh -i ~/.ssh/id_rsa root@47.243.177.166` 测试登录
   - 如果成功，使用rsync上传

3. **如果没有密钥**：
   - 生成新密钥
   - 添加公钥到服务器
   - 然后使用rsync

---

## 📝 快速命令

### 检查SSH密钥：
```bash
ls -la ~/.ssh/
```

### 使用密钥登录：
```bash
ssh -i ~/.ssh/id_rsa root@47.243.177.166
```

### 使用密钥rsync：
```bash
rsync -avz --progress -e "ssh -i ~/.ssh/id_rsa" \
  /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/ \
  root@47.243.177.166:/root/app/ \
  --exclude='build/' --exclude='.dart_tool/' --exclude='ios/' --exclude='macos/' --exclude='web/'
```

---

## 💡 建议

**最简单的方法**：使用Workbench的文件上传功能，不需要配置SSH密钥。

**如果要用rsync**：先配置SSH密钥，然后使用密钥登录。

---

**你想用哪种方法？我推荐使用Workbench上传，最简单！** 🚀


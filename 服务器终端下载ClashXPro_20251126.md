# 📥 在服务器终端下载 ClashX Pro（2025-11-26）

## ✅ 使用 SSH 终端下载

可以直接在服务器终端中使用命令下载 ClashX Pro，然后传输到 Mac。

---

## 🚀 操作步骤

### 步骤1：SSH 连接到服务器

在 Mac 终端运行：

```bash
ssh root@47.243.177.166
```

### 步骤2：在服务器上下载 ClashX Pro

#### 方法1：直接下载最新版本（推荐）

```bash
# 进入临时目录
cd /tmp

# 下载最新版本的 ClashX Pro
# 注意：需要手动查看 GitHub 页面获取实际下载链接
wget https://github.com/yichengchen/clashX/releases/download/v1.96.1/ClashX-Pro-1.96.1.dmg
```

**注意**：版本号可能需要更新，请先查看 GitHub 页面获取最新版本号。

#### 方法2：查找最新版本并下载

```bash
# 进入临时目录
cd /tmp

# 方法A：使用 GitHub API（如果可用）
curl -s https://api.github.com/repos/yichengchen/clashX/releases/latest | grep browser_download_url | grep '\.dmg' | cut -d '"' -f 4 | wget -i -

# 方法B：手动指定版本（如果知道版本号）
# 例如：v1.96.1
wget https://github.com/yichengchen/clashX/releases/download/v1.96.1/ClashX-Pro-1.96.1.dmg
```

#### 方法3：如果 GitHub API 不可用，手动获取链接

1. **在远程桌面 Firefox 中查看下载链接**（或让朋友帮忙查看）
2. **复制下载链接**
3. **在服务器终端运行**：
   ```bash
   cd /tmp
   wget [复制的下载链接]
   ```

### 步骤3：验证下载

```bash
# 查看下载的文件
ls -lh /tmp/ClashX-Pro-*.dmg

# 确认文件大小（应该有几 MB 到几十 MB）
```

### 步骤4：传输到 Mac

**退出 SSH 连接**（输入 `exit` 或按 `Ctrl+D`），然后在 Mac 终端运行：

```bash
# 传输文件到 Mac 的 Downloads 目录
scp root@47.243.177.166:/tmp/ClashX-Pro-*.dmg ~/Downloads/
```

如果提示输入密码，输入服务器 root 用户的密码。

---

## 🔍 如果找不到正确的下载链接

### 方法1：在远程桌面查看链接

1. **连接远程桌面**（Windows App）
2. **打开 Firefox**
3. **访问**：https://github.com/yichengchen/clashX/releases
4. **找到最新版本的 .dmg 文件**
5. **右键点击，选择"复制链接地址"**
6. **在服务器终端运行**：
   ```bash
   cd /tmp
   wget [粘贴复制的链接]
   ```

### 方法2：使用 curl 获取页面并解析

```bash
# 获取 releases 页面
curl -s 'https://github.com/yichengchen/clashX/releases' > /tmp/releases.html

# 查找 .dmg 文件链接（可能需要手动查看）
grep -oE 'href="[^"]*ClashX-Pro[^"]*\.dmg"' /tmp/releases.html | head -1
```

---

## 📝 完整操作示例

### 在服务器上（SSH 连接后）

```bash
# 1. 进入临时目录
cd /tmp

# 2. 下载 ClashX Pro（需要替换为实际版本号）
# 先尝试获取最新版本信息
curl -s https://api.github.com/repos/yichengchen/clashX/releases/latest

# 如果 API 可用，提取下载链接
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/yichengchen/clashX/releases/latest | grep browser_download_url | grep '\.dmg' | cut -d '"' -f 4)

# 下载文件
if [ -n "$DOWNLOAD_URL" ]; then
    wget "$DOWNLOAD_URL"
else
    echo "无法自动获取下载链接，请手动下载"
    echo "访问：https://github.com/yichengchen/clashX/releases"
fi

# 3. 查看下载的文件
ls -lh ClashX-Pro-*.dmg
```

### 在 Mac 上（退出 SSH 后）

```bash
# 传输文件到 Mac
scp root@47.243.177.166:/tmp/ClashX-Pro-*.dmg ~/Downloads/

# 查看文件
ls -lh ~/Downloads/ClashX-Pro-*.dmg
```

---

## 🎯 推荐操作

### 最简单的方法：

1. **SSH 连接到服务器**：
   ```bash
   ssh root@47.243.177.166
   ```

2. **在服务器上下载**：
   ```bash
   cd /tmp
   # 如果知道版本号，直接下载
   wget https://github.com/yichengchen/clashX/releases/download/v1.96.1/ClashX-Pro-1.96.1.dmg
   
   # 或者先查看 GitHub 页面获取最新版本号
   ```

3. **退出 SSH**（输入 `exit`）

4. **在 Mac 终端传输文件**：
   ```bash
   scp root@47.243.177.166:/tmp/ClashX-Pro-*.dmg ~/Downloads/
   ```

---

## ✅ 下载后

1. **在 Mac 上安装**：
   - 双击 ~/Downloads/ 目录中的 .dmg 文件
   - 将 ClashX Pro 拖到应用程序文件夹

2. **继续配置**：
   - 按照之前的配置步骤
   - 创建配置文件
   - 开启局域网共享
   - 配置 iPhone Wi-Fi 代理

---

**最后更新**：2025-11-26  
**推荐**：使用 SSH 终端下载（快速、直接）









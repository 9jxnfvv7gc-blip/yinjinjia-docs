# 📥 在香港服务器下载 ClashX Pro（2025-11-26）

## ✅ 方案：在远程桌面下载

香港服务器可以直接访问 GitHub，可以在远程桌面中下载 ClashX Pro，然后传输到 Mac。

---

## 🚀 操作步骤

### 方法1：在远程桌面图形界面下载（推荐）

#### 步骤1：连接远程桌面

1. **打开 Windows App**（远程桌面应用）
2. **连接到服务器**：
   - 服务器：`47.243.177.166`
   - 用户名：`desktop`
   - 密码：你的密码

#### 步骤2：在远程桌面中下载

1. **打开 Firefox**（在远程桌面中）
2. **访问**：https://github.com/yichengchen/clashX/releases
3. **下载最新版本的 .dmg 文件**：
   - 找到最新版本（通常是第一个）
   - 点击 `.dmg` 文件下载
   - 等待下载完成

#### 步骤3：传输到 Mac

**方法A：使用 SCP 传输**

1. **在 Mac 终端运行**：
   ```bash
   scp desktop@47.243.177.166:~/Downloads/ClashX-Pro-*.dmg ~/Downloads/
   ```
   - 如果文件在其他位置，调整路径

**方法B：使用云盘**

1. **在远程桌面中**：
   - 上传到百度网盘、OneDrive 等云盘
   - 在 Mac 上下载

**方法C：使用远程桌面共享**

1. **在远程桌面中**：
   - 将文件放到共享文件夹（如果有）
   - 在 Mac 上访问共享文件夹

---

### 方法2：使用命令行下载（更快）

#### 步骤1：SSH 连接到服务器

```bash
ssh root@47.243.177.166
```

#### 步骤2：查找最新版本下载链接

```bash
# 获取最新版本信息
curl -s https://api.github.com/repos/yichengchen/clashX/releases/latest | grep browser_download_url | grep '\.dmg' | head -1
```

#### 步骤3：下载文件

```bash
# 下载到 /tmp 目录
cd /tmp
wget https://github.com/yichengchen/clashX/releases/download/v1.xxx/ClashX-Pro-1.xxx.dmg
```

（将 `v1.xxx` 和 `1.xxx` 替换为实际版本号）

#### 步骤4：传输到 Mac

```bash
# 在 Mac 终端运行（退出 SSH 后）
scp root@47.243.177.166:/tmp/ClashX-Pro-*.dmg ~/Downloads/
```

---

## 🔍 如果找不到下载链接

### 手动查找步骤

1. **在远程桌面 Firefox 中访问**：
   - https://github.com/yichengchen/clashX/releases

2. **找到最新版本**（通常是第一个）

3. **找到 .dmg 文件**：
   - 在 Assets 部分
   - 找到 `ClashX-Pro-*.dmg` 文件
   - 右键点击，复制链接地址

4. **在服务器终端下载**：
   ```bash
   cd /tmp
   wget [复制的链接地址]
   ```

5. **传输到 Mac**：
   ```bash
   # 在 Mac 终端运行
   scp root@47.243.177.166:/tmp/ClashX-Pro-*.dmg ~/Downloads/
   ```

---

## 📝 快速操作命令

### 在服务器上（SSH 连接后）

```bash
# 进入临时目录
cd /tmp

# 获取最新版本下载链接（需要手动查看 GitHub 页面获取实际链接）
# 然后下载
wget https://github.com/yichengchen/clashX/releases/download/v[版本号]/ClashX-Pro-[版本号].dmg

# 查看下载的文件
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

### 最简单的方法：在远程桌面图形界面下载

1. **连接远程桌面**
2. **打开 Firefox**
3. **访问 GitHub releases 页面**
4. **下载 .dmg 文件**
5. **使用 SCP 传输到 Mac**（或使用云盘）

---

## ✅ 下载后

1. **在 Mac 上安装 ClashX Pro**：
   - 双击 .dmg 文件
   - 将 ClashX Pro 拖到应用程序文件夹

2. **继续配置**：
   - 按照之前的配置步骤
   - 创建配置文件
   - 开启局域网共享
   - 配置 iPhone Wi-Fi 代理

---

**最后更新**：2025-11-26  
**推荐**：在远程桌面图形界面下载（最简单）









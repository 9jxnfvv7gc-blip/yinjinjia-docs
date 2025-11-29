# 📥 在远程桌面下载 ClashX Pro（2025-11-26）

## ✅ 推荐方法：在远程桌面图形界面下载

香港服务器可以直接访问 GitHub，可以在远程桌面中下载 ClashX Pro，然后传输到 Mac。

---

## 🚀 操作步骤

### 步骤1：连接远程桌面

1. **打开 Windows App**（远程桌面应用）
2. **连接到服务器**：
   - 服务器：`47.243.177.166`
   - 用户名：`desktop`
   - 密码：你的密码

### 步骤2：在远程桌面中下载

1. **打开 Firefox**（在远程桌面中）：
   - 如果 Firefox 没有运行，在终端运行：`firefox &`

2. **访问 GitHub**：
   - 在 Firefox 地址栏输入：`https://github.com/yichengchen/clashX/releases`
   - 按回车

3. **下载最新版本**：
   - 找到最新版本（通常是第一个，显示 "Latest" 标签）
   - 向下滚动，找到 "Assets" 部分
   - 找到 `ClashX-Pro-*.dmg` 文件（例如：`ClashX-Pro-1.96.1.dmg`）
   - 点击下载

4. **等待下载完成**：
   - 文件通常下载到 `~/Downloads/` 目录

### 步骤3：传输到 Mac

#### 方法A：使用 SCP 传输（推荐）

1. **在 Mac 终端运行**：
   ```bash
   scp desktop@47.243.177.166:~/Downloads/ClashX-Pro-*.dmg ~/Downloads/
   ```
   - 如果提示输入密码，输入 `desktop` 用户的密码

2. **如果文件在其他位置**，先查找文件：
   ```bash
   # 在远程桌面终端运行
   find ~ -name "ClashX-Pro-*.dmg" 2>/dev/null
   ```

#### 方法B：使用云盘

1. **在远程桌面中**：
   - 上传到百度网盘、OneDrive 等云盘
   - 在 Mac 上下载

---

## 🔍 如果找不到下载链接

### 手动查找步骤

1. **在远程桌面 Firefox 中访问**：
   - https://github.com/yichengchen/clashX/releases

2. **如果页面显示 404 或找不到**：
   - 尝试访问：https://github.com/yichengchen/clashX
   - 点击 "Releases" 标签
   - 找到最新版本

3. **如果仓库不存在或已改名**：
   - 可以尝试搜索其他 ClashX 相关仓库
   - 或使用其他代理客户端（如 Clash for Windows）

---

## 💡 替代方案：使用其他代理客户端

如果 ClashX Pro 下载困难，可以使用其他代理客户端：

### 选项1：Clash for Windows（Mac 版）

1. **在远程桌面 Firefox 中访问**：
   - https://github.com/Fndroid/clash_for_windows_pkg/releases

2. **下载 Mac 版本**：
   - 找到 `Clash.for.Windows-*.dmg` 文件
   - 下载并传输到 Mac

3. **配置方法类似 ClashX Pro**

### 选项2：V2RayU（Mac 版）

1. **在远程桌面 Firefox 中访问**：
   - https://github.com/yanue/V2rayU/releases

2. **下载 Mac 版本**：
   - 找到 `.dmg` 文件
   - 下载并传输到 Mac

---

## 📝 快速操作命令

### 在远程桌面终端（查找下载的文件）

```bash
# 查找下载的 .dmg 文件
find ~ -name "*.dmg" -type f 2>/dev/null | head -5

# 查看 Downloads 目录
ls -lh ~/Downloads/ | grep -i clash
```

### 在 Mac 终端（传输文件）

```bash
# 传输文件到 Mac
scp desktop@47.243.177.166:~/Downloads/ClashX-Pro-*.dmg ~/Downloads/

# 如果文件在其他位置，先查找
ssh desktop@47.243.177.166 "find ~ -name 'ClashX-Pro-*.dmg' 2>/dev/null"
```

---

## 🎯 推荐操作

### 最简单的方法：

1. **连接远程桌面**
2. **打开 Firefox**
3. **访问 GitHub releases 页面**：
   - https://github.com/yichengchen/clashX/releases
   - 或搜索 "ClashX Pro Mac" 找到正确的仓库
4. **下载 .dmg 文件**
5. **使用 SCP 传输到 Mac**：
   ```bash
   scp desktop@47.243.177.166:~/Downloads/ClashX-Pro-*.dmg ~/Downloads/
   ```

---

## ✅ 下载后

1. **在 Mac 上安装**：
   - 双击 .dmg 文件
   - 将 ClashX Pro 拖到应用程序文件夹
   - 打开应用程序文件夹，双击 ClashX Pro 启动

2. **继续配置**：
   - 按照之前的配置步骤
   - 创建配置文件
   - 开启局域网共享
   - 配置 iPhone Wi-Fi 代理

---

**最后更新**：2025-11-26  
**推荐**：在远程桌面图形界面下载（最简单、最可靠）









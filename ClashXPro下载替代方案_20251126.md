# 🔧 ClashX Pro 下载替代方案（2025-11-26）

## ❌ 问题

尝试下载 ClashX Pro 时遇到 404 错误，可能是版本号不对或仓库结构变化。

---

## ✅ 解决方案

### 方案1：使用 Clash for Windows（Mac 版）（推荐）

Clash for Windows 也有 Mac 版本，功能类似，更容易下载。

#### 在服务器终端下载

```bash
# 进入临时目录
cd /tmp

# 下载 Clash for Windows Mac 版（使用最新版本）
# 可以尝试这些版本：v0.20.39, v0.20.38 等
wget https://github.com/Fndroid/clash_for_windows_pkg/releases/download/v0.20.39/Clash.for.Windows-0.20.39-x64.dmg
```

如果版本号不对，可以：

1. **在远程桌面 Firefox 中查看**：
   - 访问：https://github.com/Fndroid/clash_for_windows_pkg/releases
   - 找到最新版本的 Mac .dmg 文件
   - 复制下载链接

2. **在服务器终端下载**：
   ```bash
   cd /tmp
   wget [复制的下载链接]
   ```

#### 配置方法

Clash for Windows 的配置方法与 ClashX Pro 类似：

1. **创建配置文件** `config.yaml`：
   ```yaml
   port: 7890
   socks-port: 7891
   allow-lan: true
   mode: rule
   
   proxies:
     - name: "HongKong-Squid"
       type: http
       server: 47.243.177.166
       port: 3128
   
   proxy-groups:
     - name: "Proxy"
       type: select
       proxies:
         - "HongKong-Squid"
   
   rules:
     - MATCH,Proxy
   ```

2. **开启局域网共享**：
   - 在 Clash for Windows 设置中
   - 开启"Allow LAN"（允许局域网连接）

---

### 方案2：在远程桌面查看正确的 ClashX Pro 链接

1. **连接远程桌面**（Windows App）
2. **打开 Firefox**
3. **访问**：https://github.com/yichengchen/clashX/releases
4. **找到最新版本**：
   - 查看实际显示的版本号
   - 找到 .dmg 文件的完整下载链接
5. **复制链接**，在服务器终端运行：
   ```bash
   cd /tmp
   wget [复制的完整链接]
   ```

---

### 方案3：使用 V2RayU（Mac 版）

如果 Clash 系列都下载困难，可以使用 V2RayU：

```bash
# 在服务器终端下载
cd /tmp
wget https://github.com/yanue/V2rayU/releases/download/v4.0.0/V2rayU.dmg
```

---

## 🚀 推荐操作

### 方法1：使用 Clash for Windows（最简单）

1. **在服务器终端运行**：
   ```bash
   cd /tmp
   wget https://github.com/Fndroid/clash_for_windows_pkg/releases/download/v0.20.39/Clash.for.Windows-0.20.39-x64.dmg
   ```

2. **如果版本号不对**，在远程桌面查看正确版本：
   - 访问：https://github.com/Fndroid/clash_for_windows_pkg/releases
   - 找到 Mac 版本的 .dmg 文件
   - 复制链接并下载

3. **传输到 Mac**：
   ```bash
   # 退出 SSH 后，在 Mac 终端运行
   scp root@47.243.177.166:/tmp/Clash.for.Windows-*.dmg ~/Downloads/
   ```

---

## 📝 完整操作步骤（Clash for Windows）

### 在服务器上

```bash
# 1. 进入临时目录
cd /tmp

# 2. 尝试下载（如果版本号不对，会提示 404）
wget https://github.com/Fndroid/clash_for_windows_pkg/releases/download/v0.20.39/Clash.for.Windows-0.20.39-x64.dmg

# 3. 如果下载成功，查看文件
ls -lh Clash.for.Windows-*.dmg
```

### 在 Mac 上（退出 SSH 后）

```bash
# 传输文件到 Mac
scp root@47.243.177.166:/tmp/Clash.for.Windows-*.dmg ~/Downloads/

# 查看文件
ls -lh ~/Downloads/Clash.for.Windows-*.dmg
```

---

## 🎯 现在请操作

1. **尝试下载 Clash for Windows**：
   ```bash
   cd /tmp
   wget https://github.com/Fndroid/clash_for_windows_pkg/releases/download/v0.20.39/Clash.for.Windows-0.20.39-x64.dmg
   ```

2. **如果版本号不对**（404 错误）：
   - 在远程桌面查看正确版本
   - 或告诉我，我可以帮你查找

3. **下载成功后，传输到 Mac**

---

**最后更新**：2025-11-26  
**推荐**：使用 Clash for Windows（更容易下载）









# 🎯 Clash Verge 配置指南（2025-11-26）

## ✅ 下载成功

Clash Verge v1.3.8 已下载并传输到 Mac。

---

## 🚀 安装和配置步骤

### 步骤1：安装 Clash Verge

1. **打开 Downloads 文件夹**：
   - 在 Finder 中打开 `~/Downloads/`
   - 找到 `Clash.Verge_1.3.8_x64.dmg` 文件

2. **安装**：
   - 双击 .dmg 文件
   - 将 Clash Verge 拖到应用程序文件夹
   - 打开应用程序文件夹，双击 Clash Verge 启动

3. **允许运行**（如果提示）：
   - 系统设置 → 隐私与安全性
   - 允许 Clash Verge 运行

---

### 步骤2：配置 Clash Verge 使用香港服务器

1. **打开 Clash Verge**

2. **创建配置文件**：
   - 点击菜单栏的 Clash Verge 图标
   - 选择"配置"或"Profiles"
   - 点击"+"或"添加配置"
   - 选择"新建配置"或"New Profile"

3. **编辑配置文件**，内容如下：

```yaml
port: 7890
socks-port: 7891
allow-lan: true
mode: rule
log-level: info

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

4. **保存配置文件**（例如命名为 `hongkong.yaml`）

5. **选择这个配置**

6. **设置为系统代理**：
   - 点击"系统代理"或"System Proxy"按钮
   - 或点击菜单栏图标，选择"设置为系统代理"

---

### 步骤3：测试 Mac 访问 Google

1. **在 Mac 上打开浏览器**
2. **访问**：`https://www.google.com`
3. **确认可以访问**（如果能看到 Google 首页，说明配置成功）

---

### 步骤4：开启局域网共享

1. **打开 Clash Verge 设置**：
   - 点击菜单栏的 Clash Verge 图标
   - 选择"设置"或"Settings"

2. **开启局域网连接**：
   - 找到"允许局域网连接"或"Allow LAN"
   - ✅ 勾选这个选项
   - 记录 HTTP 端口：**7890**
   - 记录 SOCKS5 端口：**7891**

3. **查看 Mac 内网 IP**：
   - 打开终端（Terminal）
   - 运行命令：
     ```bash
     ipconfig getifaddr en0
     ```
   - 记录显示的 IP 地址（例如：192.168.1.105）

4. **防火墙放行**（如果需要）：
   - 系统设置 → 网络 → 防火墙 → 选项
   - 允许 Clash Verge 入站连接
   - 或临时关闭防火墙测试

---

### 步骤5：配置 iPhone Wi-Fi 代理

1. **确保 iPhone 和 Mac 在同一 Wi-Fi 网络**

2. **打开 iPhone 设置 → Wi-Fi**

3. **配置代理**：
   - 点击当前连接的 Wi-Fi 网络旁边的 ⓘ 图标
   - 向下滚动到"HTTP 代理"
   - 选择"手动"

4. **填写代理信息**：
   - **服务器**：输入 Mac 的内网 IP（例如：192.168.1.105）
   - **端口**：输入 `7890`
   - **认证**：关闭（如果开启了认证，填写用户名和密码）

5. **保存**：
   - 点击左上角"< Wi-Fi"返回
   - 代理配置会自动保存

---

### 步骤6：测试 iPhone 访问 Google

1. **测试 IP 切换**：
   - 在 iPhone 上打开 Safari
   - 访问：`http://ipinfo.io`
   - 确认 IP 已切换（应该显示香港 IP 或外国 IP）

2. **测试 Google 访问**：
   - 访问：`https://www.google.com`
   - 看是否能打开 Google 首页

3. **测试 Google 注册**：
   - 访问：`https://accounts.google.com/signup`
   - 看是否能打开注册页面

---

## 🔍 常见问题解决

### 问题1：Mac 无法访问 Google

**检查**：
- Clash Verge 是否已启动
- 是否选择了正确的配置
- 是否设置为系统代理

**解决**：
- 重新启动 Clash Verge
- 重新选择配置
- 重新设置为系统代理

### 问题2：iPhone 无法连接代理

**检查**：
- Mac 内网 IP 是否正确
- 端口是否正确（7890）
- iPhone 和 Mac 是否在同一 Wi-Fi 网络
- Clash Verge 是否开启了"允许局域网连接"

**解决**：
- 重新查看 Mac 内网 IP：`ipconfig getifaddr en0`
- 确认 Clash Verge 已开启"允许局域网连接"
- 重新配置 iPhone Wi-Fi 代理

### 问题3：iPhone 能访问百度但无法访问 Google

**可能原因**：
- HTTPS 证书问题
- 浏览器安全策略

**解决**：
- 清除 Safari 缓存
- 尝试使用 Chrome 浏览器
- 或尝试访问 HTTP 版本的 Google（不推荐）

---

## 📝 配置检查清单

- [ ] Mac 已安装 Clash Verge
- [ ] 已创建配置文件（使用香港服务器）
- [ ] 已选择配置并设置为系统代理
- [ ] Mac 可以访问 Google
- [ ] 已开启"允许局域网连接"
- [ ] 已记录 Mac 内网 IP
- [ ] iPhone 已配置 Wi-Fi 代理
- [ ] iPhone 可以访问 Google

---

## 🎯 下一步

配置成功后：

1. **在 iPhone 上完成 Google 注册**：
   - 访问：`https://accounts.google.com/signup`
   - 填写注册信息
   - 如果提示手机验证，尝试使用备用邮箱（`lmminakols@hotmail.com`）

2. **完成 Google Play Console 注册**：
   - 访问：`https://play.google.com/console`
   - 使用刚注册的 Google 账号登录
   - 完成开发者注册（需要支付 $25 一次性费用）

---

**最后更新**：2025-11-26  
**状态**：文件已下载，准备安装和配置









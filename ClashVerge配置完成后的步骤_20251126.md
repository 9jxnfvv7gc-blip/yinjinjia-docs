# ✅ Clash Verge 配置完成后的步骤（2025-11-26）

## 🎉 配置文件已选择

你已经成功选择了 `hongkong.yaml` 配置文件。

---

## 🚀 下一步操作

### 步骤1：选择配置

1. **在 Clash Verge 的 Profiles 标签中**
2. **找到 `hongkong` 配置**
3. **点击选择它**（应该会高亮显示）

### 步骤2：设置为系统代理

1. **在 Clash Verge 主窗口中**
2. **找到"系统代理"或"System Proxy"按钮**
3. **点击开启系统代理**
4. **或者点击菜单栏的 Clash Verge 图标**
5. **选择"设置为系统代理"或"Set as System Proxy"**

### 步骤3：测试 Mac 访问 Google

1. **在 Mac 上打开浏览器**（Safari 或 Chrome）
2. **访问**：`https://www.google.com`
3. **确认可以访问**（如果能看到 Google 首页，说明配置成功 ✅）

---

## 🔍 如果无法访问 Google

### 检查清单

- [ ] Clash Verge 是否已启动
- [ ] 是否选择了 `hongkong` 配置
- [ ] 是否已设置为系统代理
- [ ] 配置文件内容是否正确

### 测试代理连接

在终端运行：

```bash
curl -x http://47.243.177.166:3128 -I https://www.google.com
```

如果返回 200 或 302，说明代理可以访问 Google。

---

## 📝 配置检查

### 确认配置正确

1. **在 Clash Verge 中查看配置**
2. **确认代理服务器**：47.243.177.166:3128
3. **确认端口**：7890（HTTP），7891（SOCKS5）

---

## 🎯 如果 Mac 可以访问 Google

### 下一步：开启局域网共享

1. **打开 Clash Verge 设置**
2. **找到"允许局域网连接"或"Allow LAN"**
3. **✅ 勾选这个选项**
4. **记录 HTTP 端口**：7890

### 然后配置 iPhone

1. **查看 Mac 内网 IP**：
   ```bash
   ipconfig getifaddr en0
   ```

2. **在 iPhone 上配置 Wi-Fi 代理**：
   - 设置 → Wi-Fi → 点击当前网络 ⓘ
   - HTTP 代理 → 手动
   - 服务器：Mac 的内网 IP
   - 端口：7890
   - 保存

3. **测试 iPhone 访问 Google**

---

## ✅ 现在请操作

1. **选择 `hongkong` 配置**
2. **设置为系统代理**
3. **测试 Mac 访问 Google**：`https://www.google.com`

如果 Mac 可以访问 Google，告诉我，我们继续配置 iPhone。

---

**最后更新**：2025-11-26









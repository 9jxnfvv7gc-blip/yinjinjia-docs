# 🔧 Clash Verge HTTPS 问题修复（2025-11-26）

## ❌ 问题

Clash Verge 本地代理端口正在监听，但 HTTPS 连接有问题。

---

## ✅ 解决方案

### 方法1：更新配置文件（推荐）

Clash Verge 的配置可能需要调整以支持 HTTPS。

#### 步骤1：编辑配置文件

1. **在 Clash Verge 中**
2. **右键点击 `hongkong` 配置**
3. **选择 "edit file"**
4. **将配置内容替换为**：

```yaml
port: 7890
socks-port: 7891
allow-lan: true
mode: rule
log-level: info
external-controller: 127.0.0.1:9090

proxies:
  - name: "HongKong-Squid"
    type: http
    server: 47.243.177.166
    port: 3128
    skip-cert-verify: true

proxy-groups:
  - name: "Proxy"
    type: select
    proxies:
      - "HongKong-Squid"

rules:
  - DOMAIN-SUFFIX,google.com,Proxy
  - DOMAIN-SUFFIX,googleapis.com,Proxy
  - DOMAIN-SUFFIX,gstatic.com,Proxy
  - MATCH,Proxy
```

5. **保存文件**
6. **重新选择配置**

---

### 方法2：检查系统代理设置

1. **系统设置 → 网络**
2. **选择当前网络连接**
3. **点击"高级"**
4. **查看"代理"标签**
5. **确认 HTTP 代理已配置**：
   - 服务器：127.0.0.1
   - 端口：7890
6. **确认 HTTPS 代理已配置**（如果有）：
   - 服务器：127.0.0.1
   - 端口：7890

---

### 方法3：尝试使用 SOCKS5 代理

如果 HTTP 代理不工作，可以尝试 SOCKS5：

1. **系统设置 → 网络 → 高级 → 代理**
2. **勾选"SOCKS 代理"**
3. **填写**：
   - 服务器：127.0.0.1
   - 端口：7891
4. **保存**

---

### 方法4：重新启动 Clash Verge

1. **完全退出 Clash Verge**
2. **重新启动 Clash Verge**
3. **选择 `hongkong` 配置**
4. **选择 "Proxy" 代理组**
5. **开启系统代理**
6. **等待几秒**
7. **重新测试访问 Google**

---

## 🔍 检查清单

- [ ] Clash Verge 已启动
- [ ] 已选择 `hongkong` 配置
- [ ] 已选择 "Proxy" 代理组
- [ ] 系统代理已开启
- [ ] 本地代理端口正在监听（7890）
- [ ] 系统代理设置正确（127.0.0.1:7890）
- [ ] 配置文件包含正确的规则

---

## 🎯 现在请操作

1. **编辑配置文件**（添加 `skip-cert-verify: true` 和更详细的规则）
2. **保存并重新选择配置**
3. **重新启动 Clash Verge**
4. **测试 Mac 访问 Google**

如果还是不行，告诉我，我可以进一步排查。

---

**最后更新**：2025-11-26









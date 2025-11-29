# 📝 Clash Verge 配置名称填写（2025-11-26）

## 🎯 填写配置名称

看到需要填写：
- **name**：配置名称
- **remote file**：灰色提示文字（可以忽略）

---

## ✅ 操作步骤

### 步骤1：填写 name

1. **在 "name" 字段中填写**：`hongkong`
   - 这是配置的名称，可以随意命名
   - 建议使用 `hongkong` 或 `hongkong-proxy`

2. **"remote file" 提示可以忽略**：
   - 因为你选择了 "local" 类型
   - 不需要填写远程文件 URL
   - 这个提示可能是界面设计问题

### 步骤2：继续下一步

1. **填写完 name 后**
2. **点击"下一步"、"创建"或"确定"按钮**
3. **会打开编辑器窗口**

### 步骤3：编辑配置文件

1. **在编辑器中粘贴配置内容**：

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

2. **保存配置文件**

---

## 🔍 如果界面不同

### 如果必须填写 "remote file"

**可能的情况**：
- 界面设计问题
- 或者需要填写本地文件路径

**可以尝试**：
- 留空（如果允许）
- 或者填写：`hongkong.yaml`
- 或者填写本地文件路径（如果要求）

---

## ✅ 现在请操作

1. **在 "name" 字段填写**：`hongkong`
2. **"remote file" 可以留空或忽略**
3. **点击"下一步"或"创建"按钮**
4. **在编辑器中粘贴配置内容**
5. **保存配置文件**

如果遇到问题，告诉我具体看到了什么。

---

**最后更新**：2025-11-26









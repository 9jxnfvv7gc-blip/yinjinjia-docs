# 📝 Clash Verge 创建配置步骤（2025-11-26）

## 🎯 在 Clash Verge 中创建配置文件

你在 Profiles 标签中看到了：
- 一个文本框（提示：profile url）
- 两个按钮：**import** 和 **new**

---

## ✅ 操作步骤

### 步骤1：点击 "new" 按钮

1. **在 Profiles 标签中**
2. **点击 "new" 按钮**（创建新配置）

### 步骤2：输入配置名称

1. **会弹出一个对话框或新窗口**
2. **输入配置名称**（例如：`hongkong`）
3. **确认或点击"创建"**

### 步骤3：编辑配置文件

1. **会打开一个编辑器窗口**
2. **清空默认内容**（如果有）
3. **粘贴以下配置内容**：

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

4. **保存配置文件**（点击"保存"按钮或按 Command + S）

---

## 🔍 如果界面不同

### 如果点击 "new" 后没有编辑器

**可能的情况**：
1. **需要先输入配置名称**
2. **然后会打开编辑器**
3. **或者需要双击配置名称来编辑**

### 如果看到的是 URL 输入框

**"import" 按钮**：
- 用于从 URL 导入配置
- 我们不需要这个，因为我们手动创建配置

**"new" 按钮**：
- 用于创建新配置
- 点击这个按钮

---

## 📝 完整操作流程

### 方法1：通过 "new" 按钮创建

1. **点击 "new" 按钮**
2. **输入配置名称**：`hongkong`
3. **在编辑器中粘贴配置内容**
4. **保存配置文件**

### 方法2：如果 "new" 按钮不可用

**使用终端创建**（我们之前已经创建过了）：
- 配置文件已经创建在：`~/Library/Application Support/clash-verge/profiles/hongkong.yaml`
- 在 Clash Verge 中刷新或重新启动
- 应该能看到 `hongkong` 配置

---

## 🔄 刷新配置

如果配置文件已经通过终端创建，但在 Clash Verge 中看不到：

1. **重新启动 Clash Verge**
2. **或点击"刷新"按钮**（如果有）
3. **或关闭并重新打开 Profiles 标签**

---

## ✅ 现在请操作

1. **点击 "new" 按钮**
2. **输入配置名称**：`hongkong`
3. **在编辑器中粘贴配置内容**（上面的 YAML 内容）
4. **保存配置文件**

如果遇到问题，告诉我具体看到了什么界面，我可以进一步指导。

---

**最后更新**：2025-11-26









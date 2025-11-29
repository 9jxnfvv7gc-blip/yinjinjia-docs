# 📝 Clash Verge 配置文件创建方法（2025-11-26）

## 🎯 两种方法创建配置文件

### 方法1：通过 Clash Verge 图形界面创建（推荐）

#### 步骤1：打开 Clash Verge

1. **打开应用程序文件夹**
2. **双击 Clash Verge 启动**
3. **如果提示，允许运行**

#### 步骤2：创建配置文件

1. **点击 Clash Verge 窗口中的"配置"或"Profiles"标签**
2. **点击"+"或"添加"按钮**
3. **选择"新建配置"或"New Profile"**
4. **输入配置名称**（例如：`hongkong`）
5. **在编辑器中粘贴以下内容**：

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

6. **保存配置文件**

---

### 方法2：手动创建配置文件（如果图形界面不可用）

#### 步骤1：找到配置文件夹

Clash Verge 的配置文件通常存储在：

```bash
~/Library/Application Support/clash-verge/profiles/
```

#### 步骤2：创建配置文件

1. **打开终端（Terminal）**

2. **创建配置文件夹**（如果不存在）：
   ```bash
   mkdir -p ~/Library/Application\ Support/clash-verge/profiles/
   ```

3. **创建配置文件**：
   ```bash
   nano ~/Library/Application\ Support/clash-verge/profiles/hongkong.yaml
   ```

4. **粘贴以下内容**：

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

5. **保存文件**：
   - 按 `Ctrl + O`（保存）
   - 按 `Enter`（确认文件名）
   - 按 `Ctrl + X`（退出）

6. **在 Clash Verge 中刷新配置**：
   - 重新启动 Clash Verge
   - 或点击"刷新"按钮

---

## 🔍 如果找不到配置选项

### Clash Verge 界面说明

Clash Verge 的界面可能因版本而异，常见位置：

1. **主窗口**：
   - 左侧可能有"配置"、"Profiles"或"配置管理"标签
   - 点击进入配置管理页面

2. **菜单栏**：
   - 点击菜单栏的 Clash Verge 图标
   - 查找"配置"、"Profiles"或"Settings"选项

3. **设置页面**：
   - 点击"设置"或"Settings"
   - 查找"配置管理"或"Profile Management"

---

## 📝 快速操作（推荐方法2）

如果图形界面找不到配置选项，使用终端创建：

### 在 Mac 终端运行：

```bash
# 1. 创建配置文件夹
mkdir -p ~/Library/Application\ Support/clash-verge/profiles/

# 2. 创建配置文件
cat > ~/Library/Application\ Support/clash-verge/profiles/hongkong.yaml << 'EOF'
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
EOF

# 3. 查看文件是否创建成功
ls -lh ~/Library/Application\ Support/clash-verge/profiles/
```

---

## ✅ 创建后

1. **重新启动 Clash Verge**（如果正在运行）
2. **在 Clash Verge 中选择这个配置**（`hongkong`）
3. **设置为系统代理**
4. **测试 Mac 访问 Google**

---

## 🎯 现在请操作

### 推荐：使用终端创建（最简单）

1. **打开终端（Terminal）**
2. **复制并运行上面的命令**（从 `mkdir -p` 开始到 `EOF` 结束）
3. **重新启动 Clash Verge**
4. **选择配置并设置为系统代理**

如果遇到问题，告诉我。

---

**最后更新**：2025-11-26









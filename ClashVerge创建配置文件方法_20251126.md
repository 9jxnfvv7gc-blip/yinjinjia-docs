# 📝 Clash Verge 创建配置文件方法（2025-11-26）

## ❌ 问题

输入路径后，提示配置文件创建和另外一个文件的md格式，没有看到hongkong.yaml文件。

---

## ✅ 解决方案

### 方法1：在文件选择对话框中创建新文件

#### 步骤1：导航到配置文件夹

1. **点击 "choose file"**
2. **按 `Command + Shift + G`**
3. **输入路径**：`~/Library/Application Support/clash-verge/profiles/`
4. **按回车**

#### 步骤2：创建新文件

1. **在文件选择对话框中**
2. **右键点击空白处**
3. **选择"新建文档"或"New Document"**
4. **或者按 `Command + N` 创建新文件**
5. **命名为**：`hongkong.yaml`
6. **保存到当前文件夹**

#### 步骤3：编辑文件内容

1. **创建文件后，用文本编辑器打开**
2. **粘贴以下内容**：

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

3. **保存文件**（Command + S）

#### 步骤4：在 Clash Verge 中选择文件

1. **回到 Clash Verge**
2. **再次点击 "choose file"**
3. **选择刚创建的 `hongkong.yaml` 文件**

---

### 方法2：使用终端创建文件（推荐）

如果文件选择对话框不方便，可以在终端创建文件：

#### 步骤1：在终端创建配置文件

```bash
# 确保文件夹存在
mkdir -p ~/Library/Application\ Support/clash-verge/profiles/

# 创建配置文件
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
```

#### 步骤2：在 Clash Verge 中选择文件

1. **回到 Clash Verge**
2. **点击 "choose file"**
3. **按 `Command + Shift + G`**
4. **输入路径**：`~/Library/Application Support/clash-verge/profiles/`
5. **选择 `hongkong.yaml` 文件**

---

### 方法3：直接在 Clash Verge 中创建（如果支持）

有些版本的 Clash Verge 可能支持直接创建和编辑配置：

1. **在 "choose file" 对话框中**
2. **查看是否有"新建"或"New"按钮**
3. **如果有，点击创建新文件**
4. **命名为 `hongkong.yaml`**
5. **编辑内容并保存**

---

## 🔍 如果文件选择对话框只显示特定格式

### 可能需要更改文件类型过滤

1. **在文件选择对话框底部**
2. **查看文件类型过滤选项**
3. **选择"所有文件"或"All Files"**
4. **或者选择"YAML"格式**

---

## 📝 快速操作（推荐方法2）

### 在终端运行：

```bash
mkdir -p ~/Library/Application\ Support/clash-verge/profiles/

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
```

### 然后在 Clash Verge 中：

1. **点击 "choose file"**
2. **按 `Command + Shift + G`**
3. **输入**：`~/Library/Application Support/clash-verge/profiles/`
4. **选择 `hongkong.yaml`**

---

## ✅ 现在请操作

1. **在终端运行上面的命令**（创建文件）
2. **回到 Clash Verge**
3. **点击 "choose file"**
4. **按 `Command + Shift + G`**
5. **输入路径**：`~/Library/Application Support/clash-verge/profiles/`
6. **选择 `hongkong.yaml` 文件**

如果还是看不到文件，告诉我，我可以帮你检查。

---

**最后更新**：2025-11-26









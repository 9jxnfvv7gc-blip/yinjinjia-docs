# ✅ Clash Verge 选择配置步骤（2025-11-26）

## 🎯 操作步骤

你在 Profiles 标签中看到了 `hongkong` 配置，右键菜单有：
- **select**：选择配置 ✅ **点击这个**
- **edit info**：编辑信息
- **edit file**：编辑文件
- **open file**：打开文件
- **delete**：删除

---

## ✅ 操作步骤

### 步骤1：选择配置

1. **右键点击 `hongkong` 配置**
2. **选择 "select"**（选择配置）
3. **或者直接点击 `hongkong` 配置名称**（可能也会选择）

### 步骤2：确认配置已选择

1. **配置应该会高亮显示**（表示已选择）
2. **等待几秒，让配置加载**

### 步骤3：检查配置文件内容（可选）

如果还是不工作，可以检查配置文件：

1. **右键点击 `hongkong` 配置**
2. **选择 "edit file"**（编辑文件）
3. **查看文件内容，确认是否包含**：
   ```yaml
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
   ```

4. **如果内容不对，可以在这里编辑**
5. **保存文件**

### 步骤4：切换到 Proxies 标签

1. **切换到 Proxies 标签**
2. **查看是否能看到 "Proxy" 代理组**
3. **选择 "Proxy" 代理组**（不要选择 "direct"）

---

## 🔍 如果还是看不到 "Proxy" 代理组

### 方法1：重新加载配置

1. **右键点击 `hongkong` 配置**
2. **选择 "select"**（重新选择）
3. **等待配置加载**

### 方法2：检查配置文件

1. **右键点击 `hongkong` 配置**
2. **选择 "edit file"**
3. **确认配置文件内容正确**
4. **保存文件**
5. **重新选择配置**

### 方法3：重新启动 Clash Verge

1. **完全退出 Clash Verge**
2. **重新启动**
3. **选择 `hongkong` 配置**
4. **等待配置加载**

---

## 📝 配置文件应该包含的内容

如果编辑文件，应该看到：

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

---

## 🎯 现在请操作

1. **右键点击 `hongkong` 配置**
2. **选择 "select"**（选择配置）
3. **等待几秒，让配置加载**
4. **切换到 Proxies 标签**
5. **查看是否能看到 "Proxy" 代理组**

如果还是看不到，告诉我，我可以帮你进一步检查。

---

**最后更新**：2025-11-26









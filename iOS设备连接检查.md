# 📱 iOS设备连接检查

## ✅ 没有"信任此电脑"弹窗的可能原因

### 原因1：已经信任过了（最常见）
- iPhone之前已经信任过这台Mac
- 不需要再次确认

### 原因2：设备未正确连接
- USB线问题
- USB端口问题
- 需要重新连接

## 🔍 检查设备连接

### 方法1：在Mac上检查
```bash
# 检查USB设备
system_profiler SPUSBDataType | grep -i "iphone\|ipad"

# 检查Flutter设备
flutter devices
```

### 方法2：在iPhone上检查
1. **打开设置**
2. **通用 → 关于本机**
3. **查看是否显示"已信任的电脑"**

### 方法3：在Xcode中检查
1. **Xcode → Window → Devices and Simulators**
2. **查看左侧是否显示你的iPhone**

## 🚀 如果设备已连接

如果设备已连接（即使没有弹窗），可以直接：

1. **在Xcode中选择设备**：
   - 顶部工具栏选择你的iPhone

2. **配置签名**：
   - Runner → Signing & Capabilities
   - 选择Team

3. **运行应用**：
   - 点击运行按钮（▶️）

## ⚠️ 如果设备未连接

### 步骤1：重新连接
1. 拔掉USB线
2. 等待3秒
3. 重新插入USB线

### 步骤2：检查iPhone设置
1. **设置 → 通用 → 传输或还原iPhone**
2. **查看是否有"信任此电脑"选项**

### 步骤3：重启设备
- 重启iPhone
- 重启Mac（如果需要）

---

**请先检查Xcode中是否能看到你的iPhone设备！**



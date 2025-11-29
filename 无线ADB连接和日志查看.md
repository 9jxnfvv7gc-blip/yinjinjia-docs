# 📱 无线ADB连接和日志查看指南

## 🔌 无线ADB连接步骤

### 方法1: 如果之前连接过（推荐）

1. **在手机上查看IP地址**：
   - 设置 → WLAN → 点击当前连接的WiFi → 查看IP地址
   - 或者：设置 → 关于手机 → 状态信息 → IP地址

2. **在Mac终端连接**：
   ```bash
   # 替换为你的手机IP地址（格式：192.168.x.x:5555）
   adb connect 192.168.10.104:5555
   ```

3. **检查连接**：
   ```bash
   adb devices
   ```
   应该显示你的设备。

### 方法2: 首次无线连接

1. **先用USB连接一次**：
   ```bash
   adb devices  # 确认USB连接成功
   adb tcpip 5555  # 开启TCP/IP模式
   ```

2. **查看手机IP地址**（同上）

3. **断开USB，用WiFi连接**：
   ```bash
   adb connect 你的手机IP:5555
   ```

## 🔍 查看应用日志（找出视频不显示的原因）

### 步骤1: 清空日志
```bash
adb logcat -c
```

### 步骤2: 在手机上打开应用

### 步骤3: 查看日志
```bash
# 查看所有错误
adb logcat | grep -i "error\|exception\|failed" --line-buffered

# 或者查看网络相关
adb logcat | grep -i "http\|network\|video\|api" --line-buffered

# 或者查看Flutter相关
adb logcat | grep -i "flutter" --line-buffered
```

## 🧪 测试服务器连接

### 从手机测试服务器
```bash
# 测试服务器根路径
adb shell "curl -s http://47.243.177.166:8081/ | head -c 200"

# 测试API（需要URL编码）
adb shell "curl -s 'http://47.243.177.166:8081/api/list/原创视频' | head -c 500"
```

### 在手机浏览器测试
1. 打开手机浏览器
2. 访问：`http://47.243.177.166:8081/`
3. 如果能看到服务器状态，说明网络正常

## 🔧 常见问题和解决方案

### 问题1: adb connect 失败
**解决**：
- 确保手机和Mac在同一WiFi网络
- 检查防火墙设置
- 尝试重新开启TCP/IP：`adb tcpip 5555`

### 问题2: 应用看不到视频
**可能原因**：
1. 网络权限问题（虽然已自动授予）
2. 服务器API路径问题
3. 应用代码中的网络请求失败
4. 服务器返回空数据

**排查步骤**：
1. 查看应用日志找出错误
2. 测试服务器是否可访问
3. 检查应用配置中的服务器地址

---

**现在请先连接设备，然后查看日志找出问题！**



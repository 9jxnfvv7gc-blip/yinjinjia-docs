# 🚀 Android Studio首次设置指南

## 📋 设置向导步骤

### 步骤1：欢迎界面

**Welcome to Android Studio**

1. **选择设置类型**：
   - 选择 **"Standard"**（标准安装）- 推荐
   - 或选择 **"Custom"**（自定义安装）- 如果你知道需要什么

2. **点击 "Next"**

---

### 步骤2：选择UI主题

**Choose your UI theme**

1. **选择主题**：
   - **Darcula**（深色主题）
   - **IntelliJ Light**（浅色主题）
   - 选择你喜欢的

2. **点击 "Next"**

---

### 步骤3：验证设置

**Verify Settings**

1. **检查设置**：
   - SDK Location（SDK位置）
   - 通常默认是：`~/Library/Android/sdk`
   - 如果不对，点击"Edit"修改

2. **点击 "Next"**

---

### 步骤4：下载组件

**Downloading Components**

1. **Android Studio会自动下载**：
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)
   - 其他必需组件

2. **等待下载完成**（可能需要10-30分钟，取决于网络速度）

3. **不要关闭窗口**，等待完成

---

### 步骤5：完成设置

**Finish**

1. **点击 "Finish"**

2. **Android Studio会重启**

---

## 🔧 设置完成后：安装SDK工具

### 设置完成后，需要安装额外的SDK工具：

1. **打开SDK Manager**：
   - Tools → SDK Manager
   - 或点击工具栏的SDK Manager图标

2. **SDK Platforms标签**：
   - 勾选最新的Android版本（推荐：**Android 13 (API 33)** 或 **Android 14 (API 34)**）
   - 点击"Apply"安装

3. **SDK Tools标签**：
   - ✅ 勾选"Android SDK Build-Tools"
   - ✅ 勾选"Android SDK Command-line Tools (latest)" - **重要！**
   - ✅ 勾选"Android SDK Platform-Tools"
   - ✅ 勾选"Android Emulator"
   - ✅ 勾选"Google Play services"
   - 点击"Apply"安装

4. **等待安装完成**

---

## 📱 创建Android模拟器

### 设置完成后，创建模拟器：

1. **打开Device Manager**：
   - Tools → Device Manager
   - 或点击工具栏的Device Manager图标

2. **创建设备**：
   - 点击"Create Device"
   - 选择设备（推荐：**Pixel 5** 或 **Pixel 6**）
   - 点击"Next"

3. **选择系统镜像**：
   - 选择Android版本（推荐：**Android 13 (API 33)** 或 **Android 14 (API 34)**）
   - 选择带有"Google APIs"或"Google Play"的版本
   - 如果没有，点击"Download"下载
   - 点击"Next"

4. **完成创建**：
   - 可以修改AVD名称（默认即可）
   - 点击"Finish"

---

## 🎯 重要提示

### 在设置过程中：

1. **保持网络连接**：需要下载大量文件
2. **不要关闭窗口**：等待下载完成
3. **选择Standard安装**：最简单，适合大多数情况
4. **SDK位置**：记住SDK安装位置（通常是 `~/Library/Android/sdk`）

### 设置完成后：

1. **必须安装Command-line Tools**：这是Flutter需要的
2. **创建至少一个模拟器**：用于测试
3. **接受Android许可证**：运行 `flutter doctor --android-licenses`

---

## 📋 设置检查清单

### 首次设置
- [ ] 完成设置向导
- [ ] SDK下载完成
- [ ] Android Studio重启成功

### SDK工具
- [ ] 打开SDK Manager
- [ ] 安装Android SDK Platform（至少一个版本）
- [ ] 安装Android SDK Command-line Tools (latest)
- [ ] 安装Android SDK Platform-Tools
- [ ] 安装Android Emulator

### 模拟器
- [ ] 创建Android模拟器
- [ ] 模拟器启动成功

### Flutter
- [ ] 接受Android许可证（`flutter doctor --android-licenses`）
- [ ] `flutter devices`显示Android设备

---

## 🚀 设置完成后

### 1. 接受Android许可证

```bash
flutter doctor --android-licenses
```

按 `y` 接受所有许可证。

---

### 2. 检查设备

```bash
flutter devices
```

应该看到Android模拟器。

---

### 3. 运行应用

```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter run -d android
```

---

## ❓ 如果遇到问题

### 问题1：下载很慢

**解决方法**：
- 检查网络连接
- 使用VPN（如果需要）
- 耐心等待（首次下载需要时间）

---

### 问题2：下载失败

**解决方法**：
1. 检查网络连接
2. 重试下载
3. 或手动下载SDK工具

---

### 问题3：找不到SDK Manager

**解决方法**：
- 设置完成后，Android Studio会显示主界面
- Tools → SDK Manager
- 或 View → Tool Windows → SDK Manager

---

## 💡 提示

- **首次设置需要时间**：下载和安装可能需要30-60分钟
- **保持耐心**：这是正常的过程
- **完成后就可以使用了**：之后会很快

---

现在请按照设置向导完成设置，完成后告诉我，我会继续指导你下一步！


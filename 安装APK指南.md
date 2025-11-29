# 📱 安装APK指南

## ✅ 找到的APK文件

- **文件位置**：`~/Desktop/app-release.apk`
- **文件大小**：46MB
- **构建日期**：2025年11月23日
- **文件类型**：Android Release APK

## 🚀 安装方法

### 方法1：使用ADB安装（推荐）

1. **连接Android设备**：
   - 用USB线连接手机和电脑
   - 在手机上确认"允许USB调试"

2. **检查设备连接**：
   ```bash
   adb devices
   ```
   应该看到你的设备ID

3. **安装APK**：
   ```bash
   adb install ~/Desktop/app-release.apk
   ```

4. **如果应用已存在，使用覆盖安装**：
   ```bash
   adb install -r ~/Desktop/app-release.apk
   ```

### 方法2：直接传输到手机安装

1. **将APK文件传输到手机**：
   - 通过USB传输
   - 或通过云盘/微信传输

2. **在手机上安装**：
   - 打开文件管理器
   - 找到 `app-release.apk`
   - 点击安装
   - 允许"安装未知来源应用"（如果需要）

## 📝 安装命令

### 快速安装命令：
```bash
# 检查设备
adb devices

# 安装APK（覆盖已存在的版本）
adb install -r ~/Desktop/app-release.apk

# 或者指定完整路径
adb install -r /Users/xiaohuihu/Desktop/app-release.apk
```

## ⚠️ 注意事项

1. **如果应用已安装**：
   - 使用 `-r` 参数覆盖安装
   - 或先卸载：`adb uninstall com.example.video_music_app`

2. **如果安装失败**：
   - 检查设备是否连接：`adb devices`
   - 检查USB调试是否启用
   - 尝试重启adb：`adb kill-server && adb start-server`

3. **应用名称**：
   - 安装后查找：**"影音播放器"** 或 **"video_music_app"**

## 🎯 安装后

安装成功后：
1. 在手机上找到应用图标
2. 应用名称：**"影音播放器"**
3. 点击打开应用
4. 开始测试功能

---

**这个APK可以直接使用，无需重新编译！**



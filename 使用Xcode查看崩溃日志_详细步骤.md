# 📱 使用 Xcode 查看崩溃日志 - 详细步骤

## 🎯 为什么必须使用 Xcode？

- ✅ **可以看到完整的崩溃堆栈**：包括所有详细信息
- ✅ **不会因为手机重启而断开**：Xcode 会自动重连
- ✅ **可以查看设备日志**：即使应用已经崩溃

## 📋 完整操作步骤

### 步骤 1：打开 Xcode 项目

我已经帮你打开了项目，Xcode 应该已经打开了。

如果没有打开，在终端执行：
```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
open ios/Runner.xcworkspace
```

### 步骤 2：连接设备

1. **用 USB 连接 iPhone 到 Mac**
2. 在 Xcode 顶部工具栏选择设备：`Dianhua` 或你的 iPhone 名称
3. 如果是第一次连接，需要在 iPhone 上点击"信任此电脑"

### 步骤 3：运行应用

1. 点击 Xcode 左上角的**运行按钮**（▶️）或按 `Cmd + R`
2. 等待应用构建并安装到手机上
3. 应用启动后，点击**停止按钮**（⏹️）或按 `Cmd + .`
   - **重要**：停止运行后，应用会留在手机上

### 步骤 4：打开 Console

1. 在 Xcode 底部打开 **Console** 窗口
   - 如果没有显示，按 `Shift + Cmd + C` 打开
2. 确保 Console 显示的是**设备日志**（不是模拟器）
   - 在 Console 顶部应该显示设备名称

### 步骤 5：测试冷启动

1. **重启手机** → 解锁
2. **直接点击桌面上的应用图标**
3. **观察 Xcode Console**：
   - 如果应用崩溃，Console 会显示详细的崩溃信息
   - 包括错误类型、崩溃位置、完整堆栈跟踪

### 步骤 6：如果 Console 没有显示，查看设备日志

如果 Console 没有显示崩溃信息，可以查看设备日志：

1. 在 Xcode 菜单栏：`Window → Devices and Simulators`（或按 `Shift + Cmd + 2`）
2. 在左侧选择你的 iPhone
3. 点击 **"View Device Logs"** 按钮
4. 在列表中找到最新的崩溃日志：
   - 按时间排序，最新的在最上面
   - 名字类似 `Runner-2025-11-29-...` 或 `com.xiaohui.videoMusicApp-...`
   - 时间应该是刚刚重启后闪退的时间
5. **双击打开**，可以看到完整的崩溃堆栈

## 🔍 如果看到崩溃日志

请把 Xcode Console 或设备日志中显示的**完整崩溃信息**发给我，包括：

1. **错误类型**（如 `EXC_BAD_ACCESS`、`SIGSEGV` 等）
2. **崩溃位置**（如 `PathProviderPlugin.register`、`SharedPreferencesPlugin.register` 等）
3. **完整的堆栈跟踪**（从崩溃位置到应用启动的完整调用链）

## ⚠️ 重要提示

- **保持 Xcode 打开**：不要关闭 Xcode
- **保持设备连接**：确保 iPhone 通过 USB 连接到 Mac
- **查看最新日志**：确保查看的是刚刚重启后闪退的日志

---

**现在请按照上面的步骤在 Xcode 中操作，然后把崩溃日志发给我！**


# 如何预览修改后的App

## 当前状态
✅ **iOS Simulator运行时已安装** (iOS 26.1 - 23B86)
⏳ **NDK正在下载中**（Android构建需要，约几百MB）
🔄 **iPhone Simulator正在启动**（"Preparing iPhone Simulator - Booting"是正常的）

## 三种预览方式

### 方式1：在macOS桌面运行（最简单，推荐先试这个）

```bash
cd /Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905
flutter run -d macos
```

**优点：**
- 不需要等待模拟器
- 运行速度快
- 可以直接看到桌面版效果

**首次运行可能需要几分钟编译，请耐心等待**

---

### 方式2：在iOS Simulator运行（等模拟器启动完成后）

**步骤1：等待iPhone Simulator启动完成**
- 看到模拟器窗口打开并显示iOS主屏幕即可

**步骤2：运行应用**
```bash
cd /Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905
flutter run -d ios
```

或者让Flutter自动选择iOS模拟器：
```bash
flutter run
```

**优点：**
- 可以看到手机版效果
- 测试触摸操作
- 更接近真实手机体验

---

### 方式3：在Chrome浏览器运行（用于快速测试UI）

```bash
cd /Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905
flutter run -d chrome
```

**优点：**
- 启动最快
- 适合测试UI布局
- 可以打开浏览器开发者工具

**注意：** 某些功能（如文件选择、本地存储）在Web版本可能有限制

---

## 实时预览（热重载）

运行后，如果修改代码并保存，可以在终端输入：
- `r` - 热重载（Hot Reload）- 快速刷新界面，保留状态
- `R` - 热重启（Hot Restart）- 完全重启应用
- `q` - 退出应用

## 查看所有可用设备

```bash
flutter devices
```

## 常见问题

### Q: 模拟器启动很慢怎么办？
A: 第一次启动需要几分钟，这是正常的。后续启动会快很多。

### Q: 编译时出错怎么办？
A: 运行 `flutter clean && flutter pub get` 清理并重新获取依赖

### Q: 如何停止正在运行的应用？
A: 在运行应用的终端按 `Ctrl+C` 或输入 `q`

---

## 推荐顺序

1. **先试macOS版本**（最快，不需要等待模拟器）
2. **再试iOS模拟器**（等模拟器启动完成后）
3. **最后试Chrome**（如果需要快速测试）



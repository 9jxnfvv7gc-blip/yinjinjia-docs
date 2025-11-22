# iOS Simulator启动指南

## 当前问题
Simulator启动失败，错误：`launchd failed to respond`

## 解决方法

### 方法1：通过Xcode启动（最可靠）

1. **打开Xcode**
2. **菜单**：Xcode → Open Developer Tool → Simulator
3. **等待Simulator窗口打开**（可能需要1-2分钟）
4. **选择设备**：
   - 菜单：File → Open Simulator → iOS 26.1
   - 选择一个设备（如 iPhone 15 或 iPhone 17 Pro）

### 方法2：重置Simulator

如果Simulator一直无法启动，可以尝试重置：

```bash
# 关闭所有Simulator
killall Simulator
xcrun simctl shutdown all

# 删除Simulator数据（谨慎操作，会删除所有模拟器数据）
# xcrun simctl erase all

# 重新打开
open -a Simulator
```

### 方法3：检查Xcode许可证

确保已接受Xcode许可证：
```bash
sudo xcodebuild -license accept
```

### 方法4：重启Mac（如果以上都不行）

有时Simulator服务需要系统重启才能正常工作。

## 验证Simulator是否启动成功

运行：
```bash
flutter devices
```

如果看到类似这样的输出，说明成功了：
```
iPhone 15 (mobile) • <设备ID> • ios • iOS 17.0 (simulator)
```

## 如果Simulator启动成功

然后运行：
```bash
cd /Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905
flutter run -d ios
```

## 临时替代方案

如果Simulator一直无法启动，你可以：

1. **等待Android构建完成**（NDK下载完成后）
2. **在真实Android设备上测试**（如果有）
3. **使用macOS桌面版**（虽然可能有代码签名问题）


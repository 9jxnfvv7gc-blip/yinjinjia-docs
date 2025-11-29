# 📱 flutter logs 命令说明

## 🎯 基本命令

### 查看所有设备的日志
```bash
flutter logs
```

### 查看指定设备的日志
```bash
flutter logs -d <设备ID>
```

### 查看你的 iPhone 的日志
```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
flutter logs -d Dianhua
```

或者使用设备 ID：
```bash
flutter logs -d 00008110-00046D203CEBA01E
```

## 📋 完整操作步骤

### 1. 打开终端

### 2. 进入项目目录
```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
```

### 3. 启动日志查看
```bash
flutter logs -d Dianhua
```

### 4. 保持终端运行

### 5. 重启手机并测试
- 重启手机 → 解锁
- 点击应用图标
- 观察终端输出

## 🔍 查看设备列表

如果不确定设备名称，可以先查看设备列表：
```bash
flutter devices
```

## ⚠️ 注意事项

1. **保持终端运行**：不要关闭 `flutter logs`，这样可以看到实时日志
2. **连接设备**：确保 iPhone 已通过 USB 连接到 Mac
3. **信任设备**：如果是第一次连接，需要在 iPhone 上点击"信任此电脑"

## 📝 如果看到崩溃日志

请把终端中显示的完整崩溃信息发给我，包括：
- 错误类型
- 崩溃位置
- 完整的堆栈跟踪

---

**现在请在终端执行：`flutter logs -d Dianhua`**


# 📱 查找Android版本号

## 🔍 你提供的信息

**版本号：PECM30-11-F.20**

这是**设备型号或内部版本号**，不是Android系统版本。

---

## 🎯 需要找到Android系统版本

### 在手机上查找：

#### 方法1：设置 → 关于手机

1. **打开设置**
2. **关于手机**（可能在"系统"或底部）
3. **查找"Android版本"**或"Android系统版本"
4. **应该显示**：
   - Android 5.0
   - Android 6.0
   - Android 7.0
   - Android 8.0
   - Android 9.0
   - Android 10
   - Android 11
   - Android 12
   - Android 13
   - 等等

#### 方法2：软件信息

1. **设置 → 关于手机**
2. **软件信息**或**系统信息**
3. **查找"Android版本"**

#### 方法3：直接查看

在"关于手机"页面，通常会有：
- **设备型号**：PECM30（你看到的）
- **Android版本**：需要找到这个
- **内部版本号**：F.20（你看到的）

---

## ⚠️ 重要：Android版本要求

### Flutter要求：

- ✅ **Android 5.0 (API 21) 或更高版本**
- ❌ **Android 4.x 及以下不支持**

---

## 🔍 如果找不到Android版本

### 可以通过adb检查（如果设备已连接）：

```bash
adb shell getprop ro.build.version.release
```

这会显示Android版本号。

---

## 📋 请告诉我

1. ✅ 在"关于手机"中，是否看到"Android版本"？
2. ✅ 如果看到，版本号是多少？
3. ✅ 或者运行 `adb shell getprop ro.build.version.release` 看看结果

根据Android版本，我可以判断是否支持运行Flutter应用！


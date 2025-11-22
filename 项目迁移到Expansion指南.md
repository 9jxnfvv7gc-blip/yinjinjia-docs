# 项目迁移到Expansion指南

## 📍 何时可以迁移？

### ✅ 可以立即迁移的情况
项目可以随时迁移到Expansion移动硬盘，**不会影响开发进度**。

### ⏳ 建议等待的情况
如果你想等一些操作完成后再迁移：

1. **等待NDK下载完成**（如果需要Android构建）
   - 当前状态：正在下载中（后台进行）
   - 可以迁移：✅ 可以（下载会继续）
   - 建议等待：如果想避免重新下载

2. **等待iOS构建成功**（如果想先测试iOS）
   - 当前状态：代码签名问题
   - 可以迁移：✅ 可以（迁移后可能解决签名问题）
   - 建议：迁移后再测试，因为Expansion不在iCloud同步范围内

3. **等待依赖安装完成**
   - 当前状态：✅ 已完成
   - 可以迁移：✅ 可以立即迁移

---

## 🎯 推荐迁移时机

### 方案A：立即迁移（推荐）
**优点：**
- 避免iCloud同步导致的问题（如代码签名错误）
- 不占用本地存储空间
- 项目更稳定

**时机：** 现在就可以迁移

### 方案B：等待NDK完成后再迁移
**优点：**
- 避免重新下载NDK（虽然可以继续下载）

**时机：** 等待5-15分钟（NDK下载完成）

---

## 📦 迁移步骤

### 1. 检查Expansion是否已挂载
```bash
ls /Volumes/Expansion
```
如果没有挂载，先连接移动硬盘。

### 2. 创建项目目录
```bash
mkdir -p /Volumes/Expansion/FlutterProjects
```

### 3. 停止所有正在运行的进程
```bash
# 停止Flutter
pkill -f "flutter run"

# 停止Gradle（如果正在构建Android）
pkill -f "gradle"
```

### 4. 移动项目
```bash
# 移动到Expansion
mv "/Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905" /Volumes/Expansion/FlutterProjects/
```

### 5. 重新打开项目
```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter pub get
```

### 6. 测试运行
```bash
# 测试iOS（可能解决签名问题）
flutter run -d ios

# 或测试macOS
flutter run -d macos
```

---

## ⚠️ 注意事项

### 1. 确保Expansion已挂载
迁移前确保移动硬盘已连接并挂载。

### 2. 停止后台进程
迁移前停止所有Flutter和Gradle进程，避免文件被占用。

### 3. 检查路径
移动后，所有相对路径仍然有效，但绝对路径会改变。

### 4. NDK下载
如果NDK正在下载，迁移后：
- ✅ 可以继续下载（Android SDK路径不变）
- ⚠️ 但如果中断，可能需要重新开始

---

## 🔄 迁移后需要做的事情

1. **重新打开IDE**（如果使用Cursor/VSCode）
   - 打开新路径的项目

2. **验证依赖**
   ```bash
   flutter pub get
   ```

3. **清理构建缓存**（可选）
   ```bash
   flutter clean
   flutter pub get
   ```

4. **重新运行**
   ```bash
   flutter run -d ios
   # 或
   flutter run -d macos
   ```

---

## 💡 迁移的好处

1. **避免iCloud同步问题**
   - 代码签名错误通常与iCloud同步有关
   - Expansion不在iCloud范围内，更稳定

2. **节省本地存储**
   - 项目文件不占用Mac本地存储

3. **更好的性能**
   - 移动硬盘通常有更好的I/O性能

4. **避免同步冲突**
   - 多人协作或多设备同步时不会有冲突

---

## 🚀 快速迁移命令（一键执行）

```bash
# 1. 检查Expansion
if [ ! -d "/Volumes/Expansion" ]; then
    echo "❌ Expansion未挂载，请先连接移动硬盘"
    exit 1
fi

# 2. 停止进程
pkill -f "flutter run"
pkill -f "gradle"

# 3. 创建目录
mkdir -p /Volumes/Expansion/FlutterProjects

# 4. 移动项目
mv "/Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905" /Volumes/Expansion/FlutterProjects/

# 5. 进入新目录
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905

# 6. 验证
flutter pub get

echo "✅ 项目已迁移到Expansion！"
echo "新路径：/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
```

---

## 📊 迁移时间估算

- **小项目**（<100MB）：几秒钟
- **中等项目**（100MB-1GB）：1-5分钟
- **大项目**（>1GB）：5-15分钟

当前项目大小：检查中...

---

## ✅ 迁移检查清单

迁移前：
- [ ] Expansion已挂载
- [ ] 停止所有Flutter/Gradle进程
- [ ] 备份重要文件（可选）

迁移后：
- [ ] 验证项目可以打开
- [ ] 运行 `flutter pub get`
- [ ] 测试构建（iOS/macOS/Android）
- [ ] 更新IDE项目路径


# 重新运行Flutter应用

## 🔄 方法1：停止并重新运行（推荐）

### 步骤1：停止当前运行的应用

在运行`flutter run`的终端中：
- 按 `q` 键退出应用
- 或者按 `Ctrl+C` 停止

### 步骤2：重新运行

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
flutter run -d macos
```

---

## 🔄 方法2：如果应用已经在运行，使用热重载

如果应用窗口已经打开，在运行`flutter run`的终端中：
- 按 `r` 键进行热重载（Hot Reload）
- 或者按 `R` 键进行热重启（Hot Restart）

**注意**：热重载可能不会完全应用所有更改，特别是UI结构的大改动。

---

## 🔄 方法3：完全清理并重新构建

如果上面的方法不行，完全清理并重新构建：

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

# 清理构建缓存
flutter clean

# 重新获取依赖
flutter pub get

# 重新运行
flutter run -d macos
```

---

## 🔄 方法4：查找并停止所有Flutter进程

如果应用没有响应，强制停止：

```bash
# 查找Flutter进程
ps aux | grep flutter

# 停止所有Flutter相关进程
pkill -f flutter

# 或者更精确地停止
killall -9 dart
killall -9 Flutter

# 然后重新运行
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
flutter run -d macos
```

---

## 📋 推荐步骤

1. **在运行Flutter的终端中按 `q` 退出**
2. **重新运行**：
   ```bash
   cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
   flutter run -d macos
   ```

---

## 🎯 测试批量上传功能

应用重新运行后：
1. 点击"上传视频"或"上传歌曲"
2. 在文件选择器中选择**多个文件**（按住Cmd键选择多个）
3. 应该看到批量上传进度对话框
4. 显示成功/失败数量

---

**先按 `q` 退出，然后重新运行！** 🚀


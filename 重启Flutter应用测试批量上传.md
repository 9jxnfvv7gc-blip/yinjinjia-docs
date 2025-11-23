# 重启Flutter应用测试批量上传

## ✅ 服务器状态

- ✅ 服务器正常运行
- ✅ API返回正确的JSON（有3个视频）
- ✅ 服务已配置自动启动

---

## 🔄 重启Flutter应用

### 方法1：如果应用正在运行

在运行`flutter run`的终端中：
1. **按 `q` 键退出应用**
2. **重新运行**：
   ```bash
   cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
   flutter run -d macos
   ```

---

### 方法2：如果应用没有响应

```bash
# 1. 停止所有Flutter进程
pkill -f flutter
killall -9 dart 2>/dev/null || true

# 2. 重新运行
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
flutter run -d macos
```

---

### 方法3：完全清理并重新构建

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

## 🧪 测试批量上传功能

应用重新运行后：

1. **点击"上传视频"或"上传歌曲"**
2. **在文件选择器中**：
   - **按住 `Cmd` 键**（Mac上的Command键）
   - **点击多个文件**（不要松开Cmd键）
   - **选择完成后点击"打开"**
3. **应该看到**：
   - 批量上传进度对话框
   - 显示"正在上传: X / Y"
   - 显示成功/失败数量
4. **上传完成后**：
   - 显示"成功上传 X 个文件"
   - 如果有失败，显示失败的文件列表

---

## 📋 推荐步骤

1. **在运行Flutter的终端中按 `q` 退出**
2. **重新运行**：
   ```bash
   cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
   flutter run -d macos
   ```
3. **测试批量上传**（按住Cmd键多选文件）

---

**先按 `q` 退出，然后重新运行！** 🚀


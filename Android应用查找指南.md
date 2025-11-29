# 📱 Android应用查找指南

## 🔍 应用信息

- **应用名称**：影音播放器（已修改为中文）
- **应用包名**：com.example.video_music_app
- **应用图标**：默认Flutter图标

## 🔎 如何找到应用

### 方法1：在所有应用中查找
1. 打开应用抽屉（所有应用列表）
2. 向下滚动查找
3. 查找名称：**"影音播放器"**
4. 或者查找图标（默认Flutter图标）

### 方法2：搜索应用
1. 在应用抽屉顶部搜索框
2. 输入：**"影音"** 或 **"播放器"**
3. 应该能找到应用

### 方法3：查看最近安装
1. 打开应用商店（Google Play或应用市场）
2. 查看"我的应用"或"已安装应用"
3. 查找最近安装的应用

### 方法4：使用ADB命令启动
如果应用已安装但找不到图标，可以用命令启动：

```bash
adb shell am start -n com.example.video_music_app/com.example.video_music_app.MainActivity
```

## ⚠️ 如果还是找不到

### 检查应用是否真的安装成功

```bash
# 检查应用是否安装
adb shell pm list packages | grep example

# 应该看到：package:com.example.video_music_app
```

### 重新安装

```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter run -d android
```

## 📝 应用安装后的位置

- **应用名称**：影音播放器
- **包名**：com.example.video_music_app
- **安装位置**：/data/app/com.example.video_music_app-xxx/

## 🎯 快速启动应用

如果应用已安装，可以用以下命令直接启动：

```bash
adb shell monkey -p com.example.video_music_app -c android.intent.category.LAUNCHER 1
```

---

**记住：应用名称现在是"影音播放器"，在应用列表中查找这个名称！**



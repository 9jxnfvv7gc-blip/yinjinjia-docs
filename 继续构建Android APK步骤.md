# 继续构建Android APK步骤

## ✅ 当前状态

- ✅ 视频播放功能已修复
- ✅ 代码已恢复到稳定版本
- ⏳ 需要在服务器上构建Android APK

---

## 📋 构建步骤

### 步骤1：上传最新代码到服务器

#### 在本地Mac终端执行：

```bash
# 使用rsync上传代码（支持断点续传）
rsync -avz --progress \
  /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/ \
  root@47.243.177.166:/root/app/ \
  --exclude='build/' \
  --exclude='.dart_tool/' \
  --exclude='ios/' \
  --exclude='macos/' \
  --exclude='web/'
```

**说明**：
- `--exclude` 排除不需要的文件，加快上传速度
- 如果之前已经上传过，rsync只会上传更改的文件

---

### 步骤2：在服务器上检查代码

#### 在服务器Workbench终端执行：

```bash
# 1. 进入项目目录
cd /root/app

# 2. 加载环境变量
source ~/.bashrc

# 3. 检查Flutter版本
flutter --version

# 4. 检查代码文件
ls -la lib/
```

---

### 步骤3：清理之前的构建（如果存在）

#### 在服务器Workbench终端执行：

```bash
# 1. 进入项目目录
cd /root/app

# 2. 清理之前的构建
flutter clean

# 3. 获取依赖
flutter pub get
```

---

### 步骤4：构建APK

#### 在服务器Workbench终端执行：

```bash
# 1. 进入项目目录
cd /root/app

# 2. 加载环境变量
source ~/.bashrc

# 3. 构建APK（使用详细输出）
flutter build apk --verbose
```

**说明**：
- `--verbose` 显示详细输出，方便查看进度
- 第一次构建可能需要30-60分钟
- 构建过程中会下载依赖和编译代码

---

### 步骤5：检查构建结果

#### 在服务器Workbench终端执行：

```bash
# 检查APK文件
ls -lh /root/app/build/app/outputs/flutter-apk/app-release.apk

# 查看文件大小和修改时间
stat /root/app/build/app/outputs/flutter-apk/app-release.apk
```

---

### 步骤6：下载APK到本地

#### 在本地Mac终端执行：

```bash
# 下载APK到桌面
scp root@47.243.177.166:/root/app/build/app/outputs/flutter-apk/app-release.apk ~/Desktop/app-release.apk
```

---

## ⏱️ 构建时间参考

### 第一次构建：
- **总时间**：30-60分钟
- **Gradle下载依赖**：10-20分钟
- **编译代码**：10-15分钟
- **打包APK**：5-10分钟

### 后续构建（代码更改后）：
- **总时间**：5-15分钟
- **增量编译**：更快

---

## 🔍 构建过程中的正常现象

### 1. 警告信息
```
warning: onListen(...) overrides ...; overridden method is a bridge method
```
**说明**：这是正常的警告，不影响构建

---

### 2. "Already watching path" 信息
```
Caught exception: Already watching path: /root/app/android
```
**说明**：这是正常的文件监听，不影响构建

---

### 3. 进度指示器不动
**说明**：
- 可能正在下载依赖（需要等待）
- 可能正在编译代码（需要等待）
- 第一次构建需要较长时间

---

## ❌ 如果构建失败

### 检查错误信息

查看终端输出的错误信息，常见错误：

1. **依赖下载失败**
   - 检查网络连接
   - 检查服务器是否能访问Google服务器

2. **编译错误**
   - 检查代码是否有语法错误
   - 运行 `flutter analyze` 检查代码

3. **内存不足**
   - 检查服务器内存使用情况
   - 可能需要增加服务器内存

---

## 📝 快速命令总结

### 上传代码：
```bash
rsync -avz --progress \
  /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/ \
  root@47.243.177.166:/root/app/ \
  --exclude='build/' --exclude='.dart_tool/' --exclude='ios/' --exclude='macos/' --exclude='web/'
```

### 在服务器上构建：
```bash
cd /root/app
source ~/.bashrc
flutter clean
flutter pub get
flutter build apk --verbose
```

### 下载APK：
```bash
scp root@47.243.177.166:/root/app/build/app/outputs/flutter-apk/app-release.apk ~/Desktop/app-release.apk
```

---

## 💡 提示

1. **保持连接**：构建过程中保持Workbench连接
2. **耐心等待**：第一次构建需要较长时间
3. **查看输出**：观察终端输出，了解构建进度
4. **检查文件**：构建完成后检查APK文件是否存在

---

**现在可以开始构建了！** 🚀


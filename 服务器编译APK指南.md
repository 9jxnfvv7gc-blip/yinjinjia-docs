# 🖥️ 服务器编译APK指南

## 📋 前提条件

服务器需要安装：
- ✅ Flutter SDK
- ✅ Android SDK
- ✅ Java JDK
- ✅ 项目代码（已同步最新修改）

## 🚀 在服务器上编译APK

### 步骤1：SSH连接到服务器

```bash
ssh root@47.243.177.166
# 或使用你的服务器IP和用户名
```

### 步骤2：进入项目目录

```bash
cd /root/video_server  # 或你的项目路径
# 或者如果项目在服务器上，找到项目目录
```

### 步骤3：同步最新代码（如果需要）

如果服务器上的代码不是最新的，需要：
1. **上传修改后的AndroidManifest.xml**
2. **或者使用Git拉取最新代码**

### 步骤4：编译APK

```bash
# 进入Flutter项目目录
cd /path/to/flutter/project

# 获取依赖
flutter pub get

# 编译Debug版本APK
flutter build apk --debug

# 或编译Release版本APK
flutter build apk --release
```

### 步骤5：下载APK到本地

编译完成后，APK文件在：
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

**下载方法：**

#### 方法1：使用scp下载
```bash
# 在本地Mac终端运行
scp root@47.243.177.166:/path/to/app-debug.apk ~/Desktop/
```

#### 方法2：使用SFTP
```bash
# 使用FileZilla或其他SFTP工具
# 连接到服务器，下载APK文件
```

#### 方法3：通过HTTP下载（如果服务器有Web服务）
```bash
# 将APK放到Web目录，通过浏览器下载
# http://47.243.177.166:8081/app-debug.apk
```

### 步骤6：安装到手机

下载到本地后：
```bash
adb install -r ~/Desktop/app-debug.apk
```

## 📝 需要上传的文件

如果服务器上没有最新的代码，需要上传：

1. **AndroidManifest.xml**（已修复网络权限）
   - 路径：`android/app/src/main/AndroidManifest.xml`

2. **其他修改的文件**（如果有）

## 🔧 快速命令

### 在服务器上：
```bash
# 1. 进入项目目录
cd /path/to/flutter/project

# 2. 拉取最新代码（如果使用Git）
git pull

# 3. 获取依赖
flutter pub get

# 4. 编译APK
flutter build apk --debug

# 5. 查看APK位置
ls -lh build/app/outputs/flutter-apk/app-debug.apk
```

### 在本地Mac：
```bash
# 下载APK
scp root@47.243.177.166:/path/to/app-debug.apk ~/Desktop/

# 安装到手机
adb install -r ~/Desktop/app-debug.apk
```

## ⚠️ 注意事项

1. **确保服务器有Flutter环境**：
   ```bash
   flutter doctor
   ```

2. **确保Android SDK已配置**：
   ```bash
   flutter doctor -v
   ```

3. **确保代码是最新的**：
   - 上传修改后的AndroidManifest.xml
   - 或使用Git同步

## 🎯 如果服务器没有Flutter环境

如果服务器上没有Flutter，可以：

1. **安装Flutter**（需要时间）
2. **或者在本地编译**（等网络恢复）
3. **或者使用CI/CD服务**（如GitHub Actions）

---

**请告诉我服务器上是否有Flutter环境，我可以提供更详细的步骤！**



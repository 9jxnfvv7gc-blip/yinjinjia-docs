# 在服务器上编译APK

## 📋 前提条件

### 1. 服务器空间要求
- **最少需要**: 5-7GB 可用空间
- **推荐**: 10GB+ 可用空间

### 2. 需要安装的组件
- Flutter SDK (~1.5GB)
- Android SDK (~3-5GB)
- Java JDK (已安装 ✅)
- 项目文件 (~100MB)

---

## 🚀 安装步骤

### 步骤1：清理空间（如果不够）

```bash
# 在服务器上执行
ssh root@47.243.177.166

# 检查视频目录大小
du -sh /root/videos

# 如果需要，可以删除一些不常用的视频
# 或者移动到其他位置
```

### 步骤2：安装Flutter SDK

```bash
# 在服务器上执行
cd /root

# 下载Flutter SDK
wget https://storage.flutter-io.cn/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.2-stable.tar.xz

# 解压
tar xf flutter_linux_3.38.2-stable.tar.xz

# 添加到PATH
echo 'export PATH="$PATH:/root/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# 验证安装
flutter --version
```

### 步骤3：安装Android SDK

```bash
# 安装Android SDK命令行工具
cd /root
mkdir -p android-sdk
cd android-sdk

# 下载命令行工具
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
mkdir -p cmdline-tools
mv cmdline-tools latest
mv latest cmdline-tools/

# 设置环境变量
export ANDROID_HOME=/root/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# 安装必要的SDK组件
sdkmanager --install "platform-tools" "platforms;android-33" "build-tools;34.0.0"

# 接受许可证
yes | sdkmanager --licenses
```

### 步骤4：配置Flutter

```bash
# 运行Flutter doctor检查
flutter doctor

# 接受Android许可证
flutter doctor --android-licenses
```

### 步骤5：上传项目文件

```bash
# 在本地Mac上执行
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

# 创建压缩包（排除不必要的文件）
tar -czf project.tar.gz \
  --exclude='build' \
  --exclude='.dart_tool' \
  --exclude='ios/Pods' \
  --exclude='android/.gradle' \
  --exclude='android/app/build' \
  --exclude='node_modules' \
  --exclude='*.tar.gz' \
  .

# 上传到服务器
scp -i ~/.ssh/id_rsa project.tar.gz root@47.243.177.166:/root/
```

### 步骤6：在服务器上编译

```bash
# 在服务器上执行
cd /root
tar -xzf project.tar.gz -C /root/app
cd /root/app

# 获取依赖
flutter pub get

# 编译APK
flutter build apk --release

# APK位置
# /root/app/build/app/outputs/flutter-apk/app-release.apk
```

### 步骤7：下载APK

```bash
# 在本地Mac上执行
scp -i ~/.ssh/id_rsa root@47.243.177.166:/root/app/build/app/outputs/flutter-apk/app-release.apk ~/Desktop/app-release-$(date +%Y%m%d).apk
```

---

## ⚠️ 注意事项

1. **空间管理**：
   - 编译完成后可以删除Flutter和Android SDK（如果不再需要）
   - 或者保留以便后续编译

2. **网络问题**：
   - 服务器可以访问外网，应该能正常下载依赖
   - 如果仍有问题，检查防火墙设置

3. **编译时间**：
   - 首次编译可能需要30-60分钟
   - 后续编译会快很多

---

## 🔧 快速安装脚本

可以创建一个自动化安装脚本，简化流程。

---

## 📝 当前建议

1. **先检查空间**：确保有足够空间
2. **逐步安装**：先安装Flutter，再安装Android SDK
3. **测试编译**：先编译一个简单的测试，确认环境正确
4. **正式编译**：环境确认后再编译完整项目

---

**需要我帮你创建自动化安装脚本吗？**











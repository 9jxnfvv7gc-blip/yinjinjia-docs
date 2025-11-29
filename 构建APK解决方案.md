# 🔧 构建 APK 网络问题解决方案

## ❌ 当前问题

无法从 Google 服务器下载 Flutter 引擎依赖：
```
Could not HEAD 'https://storage.googleapis.com/download.flutter.io/...'
Connection reset
```

## ✅ 解决方案

### 方案1：使用现有 APK（推荐，最快）

**已有 APK 文件：**
- 路径：`release/app-release-20251124.apk`
- 可以直接用于备案

**提取证书信息：**
```bash
# 提取证书 MD5 指纹
keytool -printcert -jarfile release/app-release-20251124.apk | grep -i MD5
```

---

### 方案2：配置代理（如果有 VPN/代理）

1. **检查代理端口**（常见端口：7890, 1080, 8080）

2. **配置 Gradle 代理**：
   编辑 `android/gradle.properties`，添加：
   ```properties
   systemProp.http.proxyHost=127.0.0.1
   systemProp.http.proxyPort=7890
   systemProp.https.proxyHost=127.0.0.1
   systemProp.https.proxyPort=7890
   ```

3. **重新构建**：
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

---

### 方案3：在服务器上构建（如果有香港服务器）

如果您的香港服务器可以访问 Google 服务：

```bash
# 在服务器上
cd /root/app
flutter clean
flutter pub get
flutter build apk --release

# 下载 APK
scp root@服务器IP:/root/app/build/app/outputs/flutter-apk/app-release.apk ~/Desktop/
```

---

### 方案4：使用 Flutter 中国镜像（部分有效）

Flutter 引擎必须从 Google 下载，但可以尝试：

1. **配置 Flutter 镜像**：
   ```bash
   export PUB_HOSTED_URL=https://pub.flutter-io.cn
   export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   ```

2. **重新构建**：
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

⚠️ 注意：Flutter 引擎的 Maven 仓库不在中国镜像中，可能仍然失败。

---

## 📋 备案所需信息（使用现有 APK）

### Android
1. **软件包名称**：`com.example.video_music_app`
2. **APK 文件**：`release/app-release-20251124.apk`
3. **证书 MD5**：从 APK 中提取（见上方命令）

### iOS
1. **Bundle ID**：`com.xiaohui.videoMusicApp`
2. **证书 SHA-1**：`A1204EB2C3235DFB06AA4ECE2A2E81D87F574860`

---

## 💡 推荐操作

**对于备案：**
1. 直接使用现有 APK：`release/app-release-20251124.apk`
2. 提取证书信息用于备案
3. 如果需要新版本，再考虑在服务器上构建

**对于开发测试：**
1. 使用代理/VPN 配置 Gradle
2. 或在服务器上构建

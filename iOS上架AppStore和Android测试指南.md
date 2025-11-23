# iOS上架App Store和Android测试指南

## 📋 任务清单

1. ✅ 构建iOS应用（用于App Store上架）
2. ✅ 测试Android真机

---

## 1. iOS上架App Store

### 步骤1：准备Apple开发者账号

#### 1.1 注册Apple开发者账号

1. **访问**：https://developer.apple.com/
2. **注册账号**（需要Apple ID）
3. **支付费用**：$99 USD/年（约700元人民币）

**注意**：
- 需要有效的Apple ID
- 需要支付方式（信用卡）
- 需要等待审核（通常1-2个工作日）

---

### 步骤2：配置Xcode项目

#### 2.1 打开iOS项目

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
open ios/Runner.xcworkspace
```

**或者使用Xcode直接打开**：
- 在Xcode中：File → Open
- 选择：`ios/Runner.xcworkspace`

---

#### 2.2 配置签名和证书

1. **在Xcode中选择项目**：
   - 左侧选择 "Runner"
   - 选择 "Signing & Capabilities" 标签

2. **配置Team**：
   - 选择你的Apple开发者账号
   - Xcode会自动管理证书

3. **配置Bundle Identifier**：
   - 例如：`com.yourname.videomusicapp`
   - 必须是唯一的

4. **配置版本号**：
   - Version: `1.0.0`
   - Build: `1`

---

### 步骤3：构建iOS应用

#### 方法1：使用Flutter命令（推荐）

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
flutter build ios --release
```

**这会生成**：
- `build/ios/iphoneos/Runner.app`（用于真机）
- 或使用Xcode构建IPA文件

---

#### 方法2：使用Xcode构建

1. **在Xcode中**：
   - Product → Archive
   - 等待构建完成

2. **导出IPA**：
   - 选择 "Distribute App"
   - 选择 "App Store Connect"
   - 按照向导完成

---

### 步骤4：上传到App Store Connect

#### 4.1 访问App Store Connect

1. **访问**：https://appstoreconnect.apple.com/
2. **登录**你的Apple开发者账号

#### 4.2 创建应用

1. **点击"我的App"**
2. **点击"+"创建新App**
3. **填写信息**：
   - 平台：iOS
   - 名称：你的应用名称
   - 主要语言：简体中文
   - Bundle ID：选择你配置的Bundle ID
   - SKU：唯一标识符

#### 4.3 上传构建版本

1. **使用Xcode上传**：
   - 在Xcode中：Window → Organizer
   - 选择Archive
   - 点击 "Distribute App"
   - 选择 "App Store Connect"
   - 上传

2. **或使用命令行**：
   ```bash
   xcrun altool --upload-app --type ios --file "path/to/app.ipa" --username "your@email.com" --password "app-specific-password"
   ```

---

### 步骤5：填写应用信息

1. **应用截图**（必需）
   - iPhone 6.7"（iPhone 14 Pro Max等）
   - iPhone 6.5"（iPhone 11 Pro Max等）
   - iPhone 5.5"（iPhone 8 Plus等）

2. **应用描述**
3. **关键词**
4. **隐私政策URL**（如果需要）

---

### 步骤6：提交审核

1. **完成所有必填信息**
2. **选择构建版本**
3. **提交审核**
4. **等待审核**（通常1-3个工作日）

---

## 2. 测试Android真机

### 步骤1：连接Android设备

#### 1.1 启用USB调试

1. **在Android设备上**：
   - 设置 → 关于手机
   - 连续点击"版本号"7次
   - 返回设置 → 开发者选项
   - 启用"USB调试"

#### 1.2 连接设备

1. **用USB连接Android设备到Mac**
2. **在设备上确认**：
   - 允许USB调试
   - 点击"确定"

---

### 步骤2：检查设备连接

在终端执行：

```bash
# 检查设备
flutter devices
```

**应该看到你的Android设备**，例如：
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
```

---

### 步骤3：运行应用到Android设备

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
flutter run -d <设备ID>
```

**或者直接运行**：
```bash
flutter run -d android
```

**Flutter会自动选择连接的Android设备**

---

### 步骤4：或使用已构建的APK

#### 4.1 下载APK

```bash
scp root@47.243.177.166:/root/app/build/app/outputs/flutter-apk/app-release.apk ~/Desktop/app-release.apk
```

#### 4.2 传输到Android设备

**方法A：USB传输**
1. 连接设备到Mac
2. 在Finder中查看设备
3. 拖拽APK到设备

**方法B：云存储**
1. 上传APK到云存储
2. 在Android设备上下载

#### 4.3 安装APK

1. 在Android设备上找到APK文件
2. 点击安装
3. 允许"未知来源"安装
4. 完成安装

---

## 📋 快速命令总结

### iOS构建：
```bash
# 构建iOS应用
flutter build ios --release

# 或使用Xcode
open ios/Runner.xcworkspace
```

### Android测试：
```bash
# 检查设备
flutter devices

# 运行到Android设备
flutter run -d android

# 或使用设备ID
flutter run -d <设备ID>
```

### 下载APK：
```bash
scp root@47.243.177.166:/root/app/build/app/outputs/flutter-apk/app-release.apk ~/Desktop/app-release.apk
```

---

## 💡 重要提示

### iOS上架：

1. **需要Apple开发者账号**：$99/年
2. **需要Xcode**：在Mac上安装
3. **需要配置签名**：在Xcode中配置
4. **审核时间**：通常1-3个工作日

### Android测试：

1. **需要启用USB调试**：在Android设备上
2. **需要允许未知来源**：安装APK时
3. **服务器地址**：应用需要连接到本地服务器（`http://你的Mac IP:8081`）

---

## 🎯 推荐操作流程

### iOS上架：

1. **注册Apple开发者账号**（$99/年）
2. **在Xcode中配置项目**
3. **构建iOS应用**
4. **上传到App Store Connect**
5. **提交审核**

### Android测试：

1. **连接Android设备**
2. **启用USB调试**
3. **运行 `flutter run -d android`**
4. **或使用已构建的APK**

---

**现在可以开始iOS上架准备和Android测试了！** 🚀


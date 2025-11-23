# 服务器构建APK完整步骤

## 📋 构建前准备

### 步骤1：重新上传最新代码（包含新功能）

#### 在本地Mac终端执行：

```bash
# 从Expansion上传最新代码到服务器（排除构建文件）
rsync -avz --progress -e "ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no" \
  "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/" \
  root@47.243.177.166:/root/app/ \
  --exclude='build/' \
  --exclude='.dart_tool/' \
  --exclude='.git/' \
  --exclude='*.md'
```

### 步骤2：在服务器上验证代码

#### 在服务器Workbench终端执行：

```bash
# 进入项目目录
cd /root/app

# 检查新文件是否存在
ls -la lib/services/
ls -la lib/models.dart

# 应该看到：
# - lib/services/playback_service.dart
# - lib/services/theme_service.dart
```

---

## 🔨 构建APK

### 在服务器Workbench终端执行：

```bash
# 1. 进入项目目录
cd /root/app

# 2. 加载环境变量
source ~/.bashrc

# 3. 验证Flutter版本（应该是3.38.3）
flutter --version

# 4. 获取依赖
flutter pub get

# 5. 构建APK（可能需要30-60分钟）
flutter build apk
```

---

## ⏳ 构建过程

### 构建过程包括：
1. **下载Gradle依赖**（如果还没有）
2. **编译Dart代码**
3. **构建Android APK**
4. **优化和打包**

### 预计时间：
- **第一次构建**：30-60分钟
- **后续构建**：10-20分钟

---

## 📥 构建完成后

### 步骤1：下载APK

#### 在本地Mac终端执行：

```bash
# 下载APK到桌面
scp -i ~/.ssh/id_rsa root@47.243.177.166:/root/app/build/app/outputs/flutter-apk/app-release.apk ~/Desktop/app-release.apk
```

### 步骤2：安装到Android设备

```bash
# 检查设备连接
adb devices

# 安装APK
adb install ~/Desktop/app-release.apk
```

---

## 🧪 调试新功能

### 测试清单：

#### 1. 深色模式 ✅
- [ ] 点击主题切换按钮
- [ ] 检查主题是否切换
- [ ] 重新启动应用，检查主题是否保存

#### 2. 搜索功能 ✅
- [ ] 点击搜索按钮
- [ ] 输入搜索关键词
- [ ] 选择筛选类型（全部/视频/音乐）
- [ ] 查看搜索结果
- [ ] 清除搜索条件

#### 3. 播放历史 ✅
- [ ] 播放一些视频/音乐
- [ ] 点击"更多" → "播放历史"
- [ ] 查看播放历史
- [ ] 从历史记录重新播放
- [ ] 清除播放历史

#### 4. 播放列表 ✅
- [ ] 创建播放列表
- [ ] 添加内容到播放列表
- [ ] 查看播放列表
- [ ] 播放播放列表中的内容
- [ ] 删除播放列表

#### 5. 上传功能 ✅
- [ ] 点击"上传新内容"
- [ ] 选择文件类型
- [ ] 选择文件（应该能看到所有卷）
- [ ] 上传文件
- [ ] 检查上传后是否显示

---

## 📝 请告诉我

### 执行构建命令后，请告诉我：

1. **代码是否成功上传？**
   - 服务器上是否有新文件？

2. **构建是否开始？**
   - 是否显示构建进度？

3. **构建是否成功？**
   - 是否显示 "Built build/app/outputs/flutter-apk/app-release.apk"？

4. **是否有错误？**
   - 如果有错误，请告诉我完整的错误信息

---

## 🎯 总结

### 当前状态：
- ✅ 新功能已实现并测试
- ✅ 本地服务器运行正常
- ⏳ 需要上传最新代码到服务器
- ⏳ 需要在服务器上构建APK
- ⏳ 构建完成后测试新功能

### 下一步：
1. **上传最新代码到服务器**
2. **在服务器上构建APK**
3. **下载APK到本地**
4. **安装到Android设备**
5. **测试所有新功能**

**请先在本地Mac终端执行上传代码的命令，然后在服务器上执行构建命令，然后告诉我结果！**


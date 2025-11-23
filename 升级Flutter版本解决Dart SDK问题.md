# 升级Flutter版本解决Dart SDK问题

## ❌ 问题分析

### 当前问题：
- **Flutter版本**：3.24.5
- **Dart SDK版本**：3.5.4
- **项目要求**：Dart SDK ^3.10.0
- **版本不匹配**：需要升级Flutter

---

## ✅ 解决方案：升级Flutter

### 在服务器Workbench终端执行：

```bash
# 1. 进入Flutter目录
cd /opt/flutter

# 2. 更新Flutter到最新稳定版
git pull origin stable

# 3. 或者切换到最新版本
flutter upgrade

# 4. 验证新版本
flutter --version
```

---

## 🔄 如果git pull失败，手动升级

### 步骤1：下载最新Flutter

```bash
# 进入/opt目录
cd /opt

# 备份旧版本
mv flutter flutter_old

# 下载最新Flutter（使用中国镜像，更快）
wget https://storage.flutter-io.cn/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.0-stable.tar.xz

# 解压
tar xf flutter_linux_3.27.0-stable.tar.xz

# 配置环境变量（如果还没有）
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# 验证安装
flutter --version
```

---

## 🔧 或者：降低项目Dart SDK要求（临时方案）

### 如果不想升级Flutter，可以临时修改pubspec.yaml：

```bash
# 在服务器上编辑pubspec.yaml
cd /root/app
nano pubspec.yaml
```

### 修改Dart SDK要求：
```yaml
environment:
  sdk: ^3.5.0  # 从 ^3.10.0 改为 ^3.5.0
```

### 然后重新执行：
```bash
flutter pub get
flutter build apk
```

---

## 📋 推荐方案

### 推荐：升级Flutter到最新版本

### 在服务器Workbench终端执行：

```bash
# 1. 进入Flutter目录
cd /opt/flutter

# 2. 更新Flutter
flutter upgrade

# 3. 如果flutter upgrade失败，使用git pull
git pull origin stable

# 4. 验证新版本
flutter --version

# 5. 回到项目目录
cd /root/app

# 6. 重新获取依赖
flutter pub get

# 7. 构建APK
flutter build apk
```

---

## 📝 请告诉我

### 执行升级命令后，请告诉我：

1. **flutter upgrade是否成功？**
   - 是否显示升级完成？

2. **新版本是什么？**
   - `flutter --version` 显示什么？

3. **flutter pub get是否成功？**
   - 是否显示 "Got dependencies!"？

4. **是否有错误？**
   - 如果有错误，请告诉我完整的错误信息

---

## 🎯 总结

### 当前问题：
- ❌ Flutter版本太旧（3.24.5，Dart 3.5.4）
- ❌ 项目需要Dart SDK ^3.10.0
- ✅ lib/main.dart文件存在

### 解决方案：
1. **升级Flutter**（推荐）：`flutter upgrade`
2. **或者降低Dart SDK要求**（临时方案）：修改pubspec.yaml

**请先在服务器上执行 `flutter upgrade`，然后告诉我结果！**


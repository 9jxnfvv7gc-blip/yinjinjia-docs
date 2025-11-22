# 手动安装 Flutter 引擎到本地 Maven 仓库

## 问题
Gradle 无法从 Google 服务器下载 Flutter 引擎，需要手动安装到本地 Maven 仓库。

## 解决方案

由于网络限制，我们需要手动将 Flutter 引擎安装到本地 Maven 仓库。

### 步骤 1：检查 Flutter 引擎文件
```bash
ls -lh ~/development/flutter/bin/cache/artifacts/engine/android-arm64/flutter.jar
```

### 步骤 2：安装到本地 Maven 仓库
需要将 `flutter.jar` 安装到本地 Maven 仓库，但这个过程比较复杂。

## 替代方案

### 方案 A：使用已编译的 APK（如果之前成功过）
如果你之前成功构建过，可以找到已编译的 APK 文件。

### 方案 B：等待网络条件改善
在网络条件允许时（如有 VPN/代理），重新构建。

### 方案 C：使用其他设备/网络
在能够访问 Google 服务的网络环境下构建。

## 当前状态
- ✅ Flutter SDK 中已有引擎文件
- ❌ Gradle 无法从网络下载引擎依赖
- ⚠️ 需要手动配置或等待网络条件改善


# Xcode配置指南

## 当前状态
- ✅ Xcode已安装（26.1.1, Build 17B100）
- ✅ 已登录Apple ID
- ⚠️ 无法获取模拟器运行时列表

## 配置步骤

### 步骤1：接受Xcode许可证
打开终端，运行：
```bash
sudo xcodebuild -license accept
```
需要输入你的Mac密码。

### 步骤2：安装命令行工具
运行：
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### 步骤3：安装模拟器运行时
1. 打开Xcode应用程序
2. 菜单：Xcode -> Settings（或Preferences）
3. 选择 Platforms（或 Components）标签
4. 下载并安装iOS模拟器运行时（选择最新的iOS版本，如iOS 18）

### 步骤4：验证配置
运行：
```bash
flutter doctor
xcrun simctl list runtimes
```
应该能看到已安装的模拟器运行时。

### 步骤5：如果还有问题
尝试：
```bash
# 重置Xcode命令行工具路径
sudo xcode-select --reset

# 重启Xcode
killall Xcode

# 重新打开Xcode，等待索引完成
```

## 注意事项
- 模拟器运行时文件很大（约5-10GB），需要确保有足够空间
- 如果网络慢，下载可能需要较长时间
- 第一次打开Xcode可能会要求同意协议


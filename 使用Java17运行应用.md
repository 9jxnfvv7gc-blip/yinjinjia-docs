# 🚀 使用Java 17运行应用

## ✅ 好消息

**Java 17已通过Homebrew安装！**

现在需要配置使用Java 17。

---

## 🎯 现在请这样做

### 在当前终端运行：

```bash
# 1. 设置Java 17环境变量
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

# 2. 确认Java版本
java -version
```

**应该显示**：`openjdk version "17.0.17"`

---

### 然后重新运行应用：

```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905

# 清理之前的构建
flutter clean

# 重新运行
flutter run -d DAR8NRZT8PT4C66P
```

---

## 📋 完整步骤

### 步骤1：设置Java 17

在终端运行：

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
java -version
```

确认显示Java 17。

---

### 步骤2：清理之前的构建

```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter clean
```

---

### 步骤3：重新连接设备

```bash
adb devices
```

确保设备已连接。

---

### 步骤4：重新运行应用

```bash
flutter run -d DAR8NRZT8PT4C66P
```

---

## ⚠️ 重要提示

### 每次新开终端都需要设置：

如果关闭终端后重新打开，需要重新设置环境变量。

### 永久设置（可选）：

添加到 `~/.zshrc`：
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
```

然后：
```bash
source ~/.zshrc
```

---

## 🎯 现在请运行这些命令

在终端按顺序运行：

```bash
# 1. 设置Java 17
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

# 2. 确认Java版本
java -version

# 3. 清理构建
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter clean

# 4. 检查设备连接
adb devices

# 5. 重新运行应用
flutter run -d DAR8NRZT8PT4C66P
```

---

告诉我运行结果！


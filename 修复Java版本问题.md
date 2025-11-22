# 🔧 修复Java版本问题

## ⚠️ 问题：Java版本不兼容

### 错误信息：
```
java.lang.IllegalArgumentException: 25.0.1
```

### 原因：
- **当前Java版本**：Java 25.0.1（太新了）
- **Gradle/Kotlin不支持**：无法正确解析Java 25版本号
- **推荐版本**：Java 17（LTS版本）

---

## 🚀 解决方案

### 方案1：使用Java 17（推荐）

#### 检查是否已安装Java 17：

```bash
/usr/libexec/java_home -V
```

如果看到Java 17，可以切换使用。

#### 如果已安装Java 17：

设置环境变量使用Java 17：

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH=$JAVA_HOME/bin:$PATH
```

然后重新运行：
```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter run -d DAR8NRZT8PT4C66P
```

---

### 方案2：安装Java 17

#### 使用Homebrew安装：

```bash
brew install openjdk@17
```

#### 设置环境变量：

添加到 `~/.zshrc`：
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH=$JAVA_HOME/bin:$PATH
```

然后：
```bash
source ~/.zshrc
```

---

### 方案3：在gradle.properties中指定Java版本

创建或编辑 `android/gradle.properties`：

```properties
org.gradle.java.home=/path/to/java17
```

---

## 🎯 快速修复（如果Java 17已安装）

### 在当前终端运行：

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH=$JAVA_HOME/bin:$PATH
java -version  # 确认是Java 17
```

然后重新运行应用：
```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter run -d DAR8NRZT8PT4C66P
```

---

## 📋 检查清单

### Java版本
- [ ] 检查是否已安装Java 17
- [ ] 设置JAVA_HOME为Java 17
- [ ] 确认java -version显示Java 17

### 重新编译
- [ ] 清理之前的构建
- [ ] 重新运行应用

---

## ❓ 如果Java 17未安装

告诉我，我会指导你安装Java 17。

---

现在让我先检查你是否已安装Java 17。


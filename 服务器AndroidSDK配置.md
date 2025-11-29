# 🔧 服务器Android SDK配置

## ❌ 当前问题

编译时提示：
```
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

## 🔍 查找Android SDK

在服务器上运行：

```bash
# 方法1：查找Android SDK
find /root -type d -name "platforms" 2>/dev/null
find /opt -type d -name "platforms" 2>/dev/null
find /usr -type d -name "platforms" 2>/dev/null

# 方法2：查找android.jar
find /root -name "android.jar" 2>/dev/null
find /opt -name "android.jar" 2>/dev/null

# 方法3：检查常见位置
ls -la ~/Android/Sdk 2>/dev/null
ls -la /opt/android-sdk 2>/dev/null
ls -la /usr/local/android-sdk 2>/dev/null
```

## 🔧 设置Android SDK

找到Android SDK路径后（例如：`/root/Android/Sdk`），设置环境变量：

```bash
# 临时设置（当前会话）
export ANDROID_HOME=/root/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# 永久设置（添加到.bashrc）
echo 'export ANDROID_HOME=/root/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc
```

## 🚀 完整编译命令

设置好环境变量后：

```bash
cd /root/app
export PATH="$PATH:/opt/flutter/bin"
export ANDROID_HOME=/root/Android/Sdk  # 替换为实际路径
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
flutter build apk --debug
```

## 📝 如果找不到Android SDK

如果服务器上没有Android SDK，需要：

1. **安装Android SDK**（需要时间）
2. **或使用本地编译**（等网络恢复）
3. **或使用CI/CD服务**

---

**请先在服务器上查找Android SDK路径，然后设置ANDROID_HOME！**



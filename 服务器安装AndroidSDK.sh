#!/bin/bash
# 在服务器上安装Android SDK

set -e

echo "=========================================="
echo "  安装Android SDK"
echo "=========================================="
echo ""

# 设置Android SDK路径
export ANDROID_HOME=/root/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# 创建目录
mkdir -p $ANDROID_HOME
cd $ANDROID_HOME

# 下载命令行工具
if [ ! -d "cmdline-tools" ]; then
    echo "📦 下载Android SDK命令行工具..."
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    
    echo "解压..."
    unzip -q commandlinetools-linux-11076708_latest.zip
    mkdir -p cmdline-tools
    mv cmdline-tools latest
    mv latest cmdline-tools/
    rm commandlinetools-linux-11076708_latest.zip
    
    echo "✅ 命令行工具安装完成"
else
    echo "✅ 命令行工具已存在"
fi

# 安装必要的SDK组件
echo ""
echo "📦 安装Android SDK组件（这可能需要一些时间）..."
yes | sdkmanager --install \
    "platform-tools" \
    "platforms;android-33" \
    "build-tools;34.0.0" \
    "cmdline-tools;latest" || true

# 接受许可证
echo ""
echo "📝 接受Android许可证..."
yes | sdkmanager --licenses || true

echo ""
echo "=========================================="
echo "  Android SDK安装完成！"
echo "=========================================="
echo ""
echo "环境变量已设置："
echo "  ANDROID_HOME=$ANDROID_HOME"
echo ""
echo "下一步：运行 '服务器编译APK.sh' 编译APK"











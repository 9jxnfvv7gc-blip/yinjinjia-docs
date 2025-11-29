#!/bin/bash
# 在服务器上编译APK

set -e

echo "=========================================="
echo "  编译Flutter APK"
echo "=========================================="
echo ""

# 设置环境变量
export PATH="$PATH:/root/flutter/bin"
export ANDROID_HOME=/root/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# 检查项目目录
PROJECT_DIR="/root/app"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ 项目目录不存在: $PROJECT_DIR"
    echo "请先上传项目文件"
    exit 1
fi

cd $PROJECT_DIR

echo "📦 获取Flutter依赖..."
flutter pub get

echo ""
echo "🔧 运行Flutter doctor检查..."
flutter doctor || true

echo ""
echo "📱 开始编译APK（这可能需要10-30分钟）..."
flutter build apk --release

echo ""
echo "=========================================="
echo "  ✅ APK编译完成！"
echo "=========================================="
echo ""
echo "APK位置: $PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "下载APK到本地："
echo "  scp -i ~/.ssh/id_rsa root@47.243.177.166:$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk ~/Desktop/"











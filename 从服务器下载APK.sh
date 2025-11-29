#!/bin/bash

echo "📥 从服务器下载 APK 文件"
echo ""

SERVER="root@47.243.177.166"
APK_PATH="/root/app/build/app/outputs/flutter-apk/app-release.apk"
LOCAL_PATH="./release/app-release-$(date +%Y%m%d).apk"

echo "1️⃣ 检查服务器上的 APK..."
if ssh $SERVER "test -f $APK_PATH"; then
    echo "✅ 找到 APK 文件"
    echo ""
    echo "2️⃣ 正在下载..."
    scp $SERVER:$APK_PATH $LOCAL_PATH
    if [ $? -eq 0 ]; then
        echo "✅ 下载成功！"
        echo "📁 文件位置: $LOCAL_PATH"
        ls -lh $LOCAL_PATH
    else
        echo "❌ 下载失败"
    fi
else
    echo "❌ 服务器上未找到 APK 文件"
    echo ""
    echo "🔧 需要在服务器上编译 APK"
    echo "   运行以下命令："
    echo "   ssh $SERVER 'cd /root/app && flutter build apk --release'"
fi

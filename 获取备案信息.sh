#!/bin/bash

echo "📋 获取备案所需信息"
echo ""

# Android 信息
echo "========== Android 平台信息 =========="
echo ""

# 1. 软件包名称
echo "1. 软件包名称（Package Name）："
grep -r "applicationId" android/app/build.gradle* 2>/dev/null | head -1 | sed 's/.*applicationId.*=.*"\(.*\)".*/\1/' || echo "com.example.video_music_app"
echo ""

# 2. 检查是否有 APK
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "2. 找到 APK 文件，正在提取信息..."
    echo ""
    echo "   方法1：直接提供 APK 包（推荐）"
    echo "   APK 路径: $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "   方法2：提取证书信息"
    echo "   正在提取证书 MD5 指纹..."
    keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk 2>/dev/null | grep -i "MD5" || echo "   需要先构建 release APK"
    echo ""
else
    echo "2. 未找到 APK 文件，需要先构建 release APK："
    echo "   flutter build apk --release"
    echo ""
fi

# 3. 检查是否有签名文件
if [ -f "android/app/key.jks" ] || [ -f "android/key.jks" ]; then
    KEYSTORE=$(find android -name "*.jks" -o -name "*.keystore" | head -1)
    echo "3. 找到签名文件: $KEYSTORE"
    echo "   请输入密钥库密码以查看证书信息："
    echo "   keytool -list -v -keystore $KEYSTORE"
    echo ""
else
    echo "3. 未找到签名文件，使用默认调试签名"
    echo "   调试签名信息："
    echo "   密钥库路径: ~/.android/debug.keystore"
    echo "   默认密码: android"
    echo "   别名: androiddebugkey"
    echo ""
    echo "   获取 MD5 指纹命令："
    echo "   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep -i MD5"
    echo ""
fi

echo ""
echo "========== iOS 平台信息 =========="
echo ""

# 1. Bundle ID
echo "1. Bundle ID："
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj 2>/dev/null | grep -v "RunnerTests" | head -1 | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \(.*\);/\1/' || echo "com.xiaohui.videoMusicApp"
echo ""

# 2. 证书信息
echo "2. 证书 SHA-1 指纹："
echo "   需要在 Xcode 中查看："
echo "   Xcode → Preferences → Accounts → 选择您的 Apple ID → 查看证书"
echo ""
echo "   或者使用命令行："
echo "   security find-identity -v -p codesigning"
echo ""

# 3. 公钥
echo "3. 公钥："
echo "   需要从证书中提取，或提供 .p12 证书文件"
echo ""

echo "========== 总结 =========="
echo ""
echo "Android:"
echo "  - 软件包名称: com.example.video_music_app"
echo "  - 证书 MD5: 需要从 APK 或签名文件中提取"
echo ""
echo "iOS:"
echo "  - Bundle ID: com.xiaohui.videoMusicApp"
echo "  - 证书 SHA-1: 需要在 Xcode 或命令行中查看"
echo ""
echo "💡 建议："
echo "1. 对于 Android，直接提供 APK 包（最简单）"
echo "2. 对于 iOS，需要在 Xcode 中查看证书信息"
echo ""

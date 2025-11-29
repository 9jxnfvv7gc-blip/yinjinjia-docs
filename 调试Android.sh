#!/bin/bash

# Android 调试脚本
# 用于快速检查和调试 Android 设备

PROJECT_DIR="/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
cd "$PROJECT_DIR"

echo "=========================================="
echo "  Android 调试工具"
echo "=========================================="
echo ""

# 1. 检查 ADB 设备
echo "📱 检查 Android 设备连接..."
adb devices
echo ""

# 2. 检查 Flutter 设备
echo "📱 检查 Flutter 设备..."
flutter devices
echo ""

# 3. 显示当前 Git 状态
echo "📝 当前 Git 状态..."
git log --oneline -1
echo ""

# 4. 显示服务器配置
echo "🌐 服务器配置..."
grep -A 2 "productionApiUrl" lib/config.dart | head -3
echo ""

# 5. 提供选项
echo "=========================================="
echo "  请选择操作："
echo "=========================================="
echo "1. 运行应用 (flutter run)"
echo "2. 安装 APK (app-release-20251124.apk)"
echo "3. 查看日志 (adb logcat)"
echo "4. 重启 ADB"
echo "5. 退出"
echo ""

read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo "🚀 运行应用..."
        flutter run -d android
        ;;
    2)
        echo "📦 安装 APK..."
        if [ -f "release/app-release-20251124.apk" ]; then
            adb install -r release/app-release-20251124.apk
            echo "✅ APK 安装完成"
        else
            echo "❌ 找不到 APK 文件"
        fi
        ;;
    3)
        echo "📋 查看日志 (按 Ctrl+C 退出)..."
        adb logcat | grep -i flutter
        ;;
    4)
        echo "🔄 重启 ADB..."
        adb kill-server
        adb start-server
        adb devices
        ;;
    5)
        echo "👋 退出"
        exit 0
        ;;
    *)
        echo "❌ 无效选项"
        ;;
esac











#!/bin/bash
# 快速运行Flutter应用的脚本

# 进入项目目录
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

# 检查是否在正确的目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：找不到 pubspec.yaml 文件"
    echo "请确保在正确的项目目录中"
    exit 1
fi

# 显示菜单
echo "=========================================="
echo "  影音播放器 - 快速运行"
echo "=========================================="
echo ""
echo "选择运行平台："
echo "1. iOS (模拟器或真机)"
echo "2. Android (模拟器或真机)"
echo "3. 查看可用设备"
echo "4. 退出"
echo ""
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🚀 启动iOS应用..."
        echo "正在检查设备..."
        flutter devices
        echo ""
        flutter run -d ios
        ;;
    2)
        echo ""
        echo "🚀 启动Android应用..."
        echo "正在检查设备..."
        adb devices
        flutter devices
        echo ""
        flutter run -d android
        ;;
    3)
        echo ""
        echo "📱 可用设备列表："
        flutter devices
        echo ""
        echo "Android设备："
        adb devices
        ;;
    4)
        echo "退出"
        exit 0
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac



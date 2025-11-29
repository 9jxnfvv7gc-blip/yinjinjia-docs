#!/bin/bash

echo "=========================================="
echo "视频播放日志查看工具"
echo "=========================================="
echo ""

# 检查设备连接
echo "1. 检查设备连接..."
if ! adb devices | grep -q "device$"; then
    echo "❌ 未检测到设备，请："
    echo "   - 确保手机已通过USB连接到电脑"
    echo "   - 确保已开启USB调试"
    echo "   - 运行: adb devices"
    exit 1
fi

echo "✅ 设备已连接"
echo ""

# 清空旧日志
echo "2. 清空旧日志..."
adb logcat -c
echo "✅ 日志已清空"
echo ""

echo "=========================================="
echo "请在手机上尝试播放一个视频"
echo "播放后，按 Ctrl+C 停止日志收集"
echo "=========================================="
echo ""

# 查看日志
adb logcat | grep -iE "flutter|video|error|exception|failed" --color=always











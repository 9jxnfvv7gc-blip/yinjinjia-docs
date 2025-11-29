#!/bin/bash
# Android应用网络连接测试脚本

echo "🔍 测试Android应用网络连接..."
echo ""

# 1. 检查设备连接
echo "1️⃣ 检查Android设备连接:"
adb devices
echo ""

# 2. 测试服务器连接
echo "2️⃣ 测试服务器连接 (从手机):"
adb shell "curl -s http://47.243.177.166:8081/api/list/原创视频 | head -c 200"
echo ""
echo ""

# 3. 检查应用权限
echo "3️⃣ 检查应用网络权限:"
adb shell dumpsys package com.example.videoMusicApp | grep -A 5 "granted=true" | grep -i "internet\|network" || echo "⚠️ 未找到网络权限，可能需要手动授予"
echo ""

# 4. 查看应用日志
echo "4️⃣ 查看应用最近错误日志:"
echo "（请在手机上打开应用，然后按Ctrl+C停止）"
adb logcat -c
adb logcat | grep -i "flutter\|video\|http\|error\|exception" --line-buffered



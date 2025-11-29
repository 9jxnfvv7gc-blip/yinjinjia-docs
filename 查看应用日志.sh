#!/bin/bash
# 查看Android应用日志脚本

echo "🔍 开始查看应用日志..."
echo "📱 请在手机上打开'影音播放器'应用"
echo "⏹️  查看10秒后自动停止，或按Ctrl+C手动停止"
echo ""

adb logcat -c
sleep 2

echo "开始捕获日志..."
adb logcat | grep -i "error\|exception\|failed\|http\|video\|flutter\|api\|network" --line-buffered &
LOGCAT_PID=$!

sleep 10

kill $LOGCAT_PID 2>/dev/null
echo ""
echo "✅ 日志查看完成"



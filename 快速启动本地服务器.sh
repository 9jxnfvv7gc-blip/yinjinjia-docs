#!/bin/bash
# 快速启动本地视频服务器

cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

# 停止占用 8081 端口的进程
if lsof -i :8081 > /dev/null 2>&1; then
    echo "🛑 停止占用 8081 端口的进程..."
    lsof -ti :8081 | xargs kill -9 2>/dev/null
    sleep 1
fi

# 设置正确的视频根目录
export VIDEO_ROOT="/Volumes/Expansion"

echo "🚀 启动本地视频服务器..."
echo "📁 视频根目录: $VIDEO_ROOT"
echo "📡 Mac 本地 IP: 192.168.10.103"
echo "🌐 服务器地址: http://192.168.10.103:8081"
echo ""
echo "⚠️  保持此终端窗口打开，服务器需要一直运行"
echo "按 Ctrl+C 停止服务器"
echo ""

# 启动服务器
python3 video_server.py



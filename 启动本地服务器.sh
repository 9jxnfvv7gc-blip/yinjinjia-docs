#!/bin/bash
# 启动本地视频服务器

cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

# 检查端口是否被占用
if lsof -i :8081 > /dev/null 2>&1; then
    echo "⚠️  端口 8081 已被占用，正在停止旧进程..."
    lsof -ti :8081 | xargs kill -9 2>/dev/null
    sleep 1
fi

# 启动服务器
echo "🚀 启动本地视频服务器..."
echo "📡 Mac 本地 IP: 192.168.10.103"
echo "🌐 服务器地址: http://192.168.10.103:8081"
echo ""
echo "⚠️  保持此终端窗口打开，服务器需要一直运行"
echo "按 Ctrl+C 停止服务器"
echo ""

python3 video_server.py



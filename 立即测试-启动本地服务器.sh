#!/bin/bash
# 立即测试：启动本地服务器（用于快速调试）

echo "🚀 启动本地视频服务器（用于测试）..."
echo ""

# 设置视频根目录（根据实际情况修改）
VIDEO_ROOT="${VIDEO_ROOT:-/Volumes/Expansion}"
echo "📁 视频根目录: $VIDEO_ROOT"

# 检查目录是否存在
if [ ! -d "$VIDEO_ROOT" ]; then
    echo "⚠️  视频目录不存在: $VIDEO_ROOT"
    echo "请设置正确的 VIDEO_ROOT 环境变量"
    echo "例如: export VIDEO_ROOT=/path/to/videos"
    exit 1
fi

# 获取本地 IP
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
echo "🌐 本地 IP: $LOCAL_IP"
echo "📡 服务器地址: http://$LOCAL_IP:8081"
echo ""

# 检查端口是否被占用
if lsof -Pi :8081 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口 8081 已被占用，正在停止旧进程..."
    pkill -f video_server.py
    sleep 2
fi

# 设置环境变量并启动服务器
export VIDEO_ROOT
echo "▶️  启动服务器..."
echo "⚠️  保持此终端窗口打开，服务器需要一直运行"
echo "按 Ctrl+C 停止服务器"
echo ""

cd "$(dirname "$0")"
python3 video_server.py



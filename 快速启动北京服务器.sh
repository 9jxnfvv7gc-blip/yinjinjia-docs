#!/bin/bash
# 快速启动北京服务器脚本
# 在服务器上执行此脚本

echo "🚀 启动北京视频服务器..."
echo ""

# 设置视频根目录
export VIDEO_ROOT="/root/videos"
echo "📁 视频根目录: $VIDEO_ROOT"

# 检查目录是否存在
if [ ! -d "$VIDEO_ROOT" ]; then
    echo "⚠️  视频目录不存在，正在创建..."
    mkdir -p "$VIDEO_ROOT/原创视频"
    mkdir -p "$VIDEO_ROOT/原创歌曲"
    echo "✅ 目录已创建"
fi

# 检查 video_server.py 是否存在
if [ ! -f "/root/app/video_server.py" ]; then
    echo "⚠️  video_server.py 不存在于 /root/app/"
    echo "请先上传 video_server.py 到服务器"
    exit 1
fi

# 停止旧进程
echo "🛑 停止旧进程..."
pkill -f video_server.py
sleep 2

# 启动服务器
echo "▶️  启动服务器..."
cd /root/app
nohup python3 video_server.py > /root/server.log 2>&1 &

# 等待启动
sleep 3

# 检查是否启动成功
if ps aux | grep -v grep | grep video_server.py > /dev/null; then
    echo "✅ 服务器已启动"
    echo "📋 进程信息:"
    ps aux | grep -v grep | grep video_server.py
    echo ""
    echo "📝 日志文件: /root/server.log"
    echo "🔍 查看日志: tail -f /root/server.log"
    echo ""
    echo "🌐 测试连接:"
    echo "   curl http://localhost:8081/api/categories"
    echo "   curl http://localhost:8081/api/list/原创视频"
else
    echo "❌ 服务器启动失败"
    echo "📋 查看日志:"
    tail -20 /root/server.log
    exit 1
fi



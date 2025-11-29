#!/bin/bash
# 快速部署脚本

SERVER="root@47.243.177.166"
SERVER_DIR="/root/video_server"
LOCAL_FILE="video_server.py"

echo "=========================================="
echo "  服务器部署脚本"
echo "=========================================="
echo ""

# 检查文件是否存在
if [ ! -f "$LOCAL_FILE" ]; then
    echo "❌ 错误: 找不到文件 $LOCAL_FILE"
    exit 1
fi

echo "📤 上传文件到服务器..."
echo "   服务器: $SERVER"
echo "   目标目录: $SERVER_DIR"
echo ""

# 尝试使用SSH密钥上传
if scp -i ~/.ssh/id_rsa "$LOCAL_FILE" "$SERVER:$SERVER_DIR/" 2>/dev/null; then
    echo "✅ 文件上传成功（使用SSH密钥）"
elif scp "$LOCAL_FILE" "$SERVER:$SERVER_DIR/" 2>/dev/null; then
    echo "✅ 文件上传成功（使用密码）"
else
    echo "❌ 文件上传失败"
    echo ""
    echo "请手动上传文件："
    echo "  方法1: 使用Workbench文件管理器"
    echo "  方法2: 使用scp命令: scp $LOCAL_FILE $SERVER:$SERVER_DIR/"
    exit 1
fi

echo ""
echo "🔄 重启服务器..."
echo ""

# 尝试使用SSH密钥执行命令
if ssh -i ~/.ssh/id_rsa "$SERVER" << 'ENDSSH' 2>/dev/null; then
cd /root/video_server
echo "停止现有服务器..."
pkill -f video_server.py || true
systemctl stop video-server 2>/dev/null || true
sleep 1
echo "启动新服务器..."
python3 video_server.py > /tmp/video_server.log 2>&1 &
sleep 2
echo "检查服务器状态..."
if ps aux | grep video_server.py | grep -v grep > /dev/null; then
    echo "✅ 服务器已启动"
    echo "查看日志: tail -f /tmp/video_server.log"
else
    echo "❌ 服务器启动失败，请检查日志"
    tail -20 /tmp/video_server.log
fi
ENDSSH
    echo "✅ 服务器重启完成"
elif ssh "$SERVER" << 'ENDSSH' 2>/dev/null; then
cd /root/video_server
echo "停止现有服务器..."
pkill -f video_server.py || true
systemctl stop video-server 2>/dev/null || true
sleep 1
echo "启动新服务器..."
python3 video_server.py > /tmp/video_server.log 2>&1 &
sleep 2
echo "检查服务器状态..."
if ps aux | grep video_server.py | grep -v grep > /dev/null; then
    echo "✅ 服务器已启动"
    echo "查看日志: tail -f /tmp/video_server.log"
else
    echo "❌ 服务器启动失败，请检查日志"
    tail -20 /tmp/video_server.log
fi
ENDSSH
    echo "✅ 服务器重启完成"
else
    echo "❌ 无法连接到服务器"
    echo ""
    echo "请手动在服务器上执行："
    echo "  cd /root/video_server"
    echo "  pkill -f video_server.py"
    echo "  python3 video_server.py > /tmp/video_server.log 2>&1 &"
fi

echo ""
echo "=========================================="
echo "  部署完成！"
echo "=========================================="

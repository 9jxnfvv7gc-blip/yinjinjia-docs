#!/bin/bash
# 上传 video_server.py 到北京服务器

echo "📤 上传 video_server.py 到北京服务器..."
echo ""

SERVER_IP="39.107.137.136"
SERVER_USER="root"  # 根据实际情况修改
SCRIPT_DIR="/root/app"

# 检查本地文件
if [ ! -f "video_server.py" ]; then
    echo "❌ 找不到 video_server.py 文件"
    exit 1
fi

echo "📋 准备上传:"
echo "   源文件: $(pwd)/video_server.py"
echo "   目标服务器: $SERVER_USER@$SERVER_IP"
echo "   目标目录: $SCRIPT_DIR"
echo ""

# 创建远程目录（如果不存在）
echo "📁 创建远程目录..."
ssh $SERVER_USER@$SERVER_IP "mkdir -p $SCRIPT_DIR"

# 上传文件
echo "📤 上传文件..."
scp video_server.py $SERVER_USER@$SERVER_IP:$SCRIPT_DIR/

if [ $? -eq 0 ]; then
    echo "✅ 上传成功"
    echo ""
    echo "📋 下一步："
    echo "1. 连接到服务器: ssh $SERVER_USER@$SERVER_IP"
    echo "2. 执行启动脚本: bash $SCRIPT_DIR/快速启动北京服务器.sh"
    echo "   或手动启动:"
    echo "   export VIDEO_ROOT=/root/videos"
    echo "   cd $SCRIPT_DIR"
    echo "   nohup python3 video_server.py > /root/server.log 2>&1 &"
else
    echo "❌ 上传失败"
    exit 1
fi



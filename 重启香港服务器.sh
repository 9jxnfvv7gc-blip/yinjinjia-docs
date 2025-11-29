#!/bin/bash
# 重启香港服务器

echo "📋 重启香港服务器..."
echo ""

ssh root@47.243.177.166 << 'SSH_EOF'
# 停止服务器
echo "1. 停止旧进程..."
pkill -f video_server.py
sleep 2

# 检查是否还有进程
if ps aux | grep video_server.py | grep -v grep; then
    echo "⚠️ 仍有进程运行，强制停止..."
    pkill -9 -f video_server.py
    sleep 1
fi

# 重新启动服务器
echo "2. 启动服务器..."
cd /root/video_server
nohup python3 video_server.py > /tmp/video_server.log 2>&1 &
sleep 3

# 检查服务器状态
echo "3. 检查服务器状态..."
if ps aux | grep video_server.py | grep -v grep; then
    echo "✅ 服务器已启动"
else
    echo "❌ 服务器启动失败"
    echo "查看日志："
    tail -20 /tmp/video_server.log
fi

# 测试 API
echo "4. 测试 API..."
sleep 2
curl -s "http://localhost:8081/api/list/原创视频" | python3 -c "import sys, json; data=json.load(sys.stdin); print(f'✅ API 正常，返回 {len(data)} 个视频')" 2>/dev/null || echo "⚠️ API 测试失败"
SSH_EOF

echo ""
echo "✅ 服务器重启完成"

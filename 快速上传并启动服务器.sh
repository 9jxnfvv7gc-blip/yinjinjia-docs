#!/bin/bash
# 快速上传并启动服务器

echo "📤 步骤1：上传文件到服务器..."
echo "请在提示时输入 admin 用户的密码"
echo ""

cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
scp video_server.py admin@39.107.137.136:/tmp/video_server.py

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 文件上传成功！"
    echo ""
    echo "📋 步骤2：在服务器上执行以下命令（复制粘贴）："
    echo ""
    echo "sudo su -"
    echo "mv /tmp/video_server.py /root/app/"
    echo "chmod +x /root/app/video_server.py"
    echo "mkdir -p /root/videos/原创视频 /root/videos/原创歌曲"
    echo "cd /root/app"
    echo "export VIDEO_ROOT=\"/root/videos\""
    echo "nohup python3 video_server.py > /root/server.log 2>&1 &"
    echo "ps aux | grep video_server.py"
    echo "curl http://localhost:8081/api/categories"
else
    echo "❌ 上传失败，请检查网络和密码"
fi



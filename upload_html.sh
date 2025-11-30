#!/bin/bash

# 上传HTML文件到服务器
# 使用方法: ./upload_html.sh

SERVER="root@47.243.177.166"
WEB_DIR="/var/www/html"

echo "开始上传HTML文件到服务器..."
echo "服务器: $SERVER"
echo "目标目录: $WEB_DIR"
echo ""

# 检查文件是否存在
if [ ! -f "terms-of-service.html" ] || [ ! -f "privacy-policy.html" ]; then
    echo "❌ 错误: HTML文件不存在"
    exit 1
fi

# 上传文件
echo "上传用户协议..."
scp terms-of-service.html $SERVER:$WEB_DIR/

echo "上传隐私政策..."
scp privacy-policy.html $SERVER:$WEB_DIR/

echo ""
echo "✅ 上传完成！"
echo ""
echo "访问URL："
echo "用户协议: http://47.243.177.166/terms-of-service.html"
echo "隐私政策: http://47.243.177.166/privacy-policy.html"
echo ""
echo "注意：如果服务器上没有Web服务器，需要先安装Nginx或Apache"


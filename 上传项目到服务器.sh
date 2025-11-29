#!/bin/bash
# 上传项目文件到服务器

set -e

PROJECT_DIR="/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
SERVER="root@47.243.177.166"
SERVER_DIR="/root/app"

echo "=========================================="
echo "  上传项目到服务器"
echo "=========================================="
echo ""

cd "$PROJECT_DIR"

echo "📦 创建项目压缩包（排除不必要的文件）..."
tar -czf project.tar.gz \
  --exclude='build' \
  --exclude='.dart_tool' \
  --exclude='ios/Pods' \
  --exclude='android/.gradle' \
  --exclude='android/app/build' \
  --exclude='node_modules' \
  --exclude='*.tar.gz' \
  --exclude='*.sh' \
  --exclude='*.md' \
  .

echo "📤 上传到服务器..."
scp -i ~/.ssh/id_rsa project.tar.gz $SERVER:/root/

echo "📂 在服务器上解压..."
ssh -i ~/.ssh/id_rsa $SERVER << 'EOF'
cd /root
rm -rf app
mkdir -p app
tar -xzf project.tar.gz -C app
rm project.tar.gz
echo "✅ 项目文件已解压到 /root/app"
EOF

echo ""
echo "✅ 上传完成！"
echo ""
echo "项目位置: $SERVER_DIR"
echo ""
echo "下一步：在服务器上运行编译脚本"











#!/bin/bash
# 在服务器上安装Flutter和Android SDK的自动化脚本

set -e  # 遇到错误立即退出

echo "=========================================="
echo "  服务器Flutter环境安装脚本"
echo "=========================================="
echo ""

# 检查空间
echo "📊 检查磁盘空间..."
AVAILABLE=$(df / | tail -1 | awk '{print $4}')
AVAILABLE_GB=$((AVAILABLE / 1024 / 1024))
echo "可用空间: ${AVAILABLE_GB}GB"
echo ""

if [ $AVAILABLE_GB -lt 5 ]; then
    echo "❌ 空间不足！至少需要5GB，当前只有${AVAILABLE_GB}GB"
    echo "请先清理一些视频文件"
    exit 1
fi

echo "✅ 空间充足，开始安装..."
echo ""

# 步骤1：安装Flutter SDK
echo "📦 步骤1: 安装Flutter SDK..."
cd /root

if [ ! -d "/root/flutter" ]; then
    echo "下载Flutter SDK..."
    # 使用国内镜像（如果外网访问有问题）
    # wget https://storage.flutter-io.cn/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.2-stable.tar.xz
    wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.2-stable.tar.xz
    
    echo "解压Flutter SDK..."
    tar xf flutter_linux_3.38.2-stable.tar.xz
    
    echo "清理安装包..."
    rm flutter_linux_3.38.2-stable.tar.xz
    
    echo "✅ Flutter SDK安装完成"
else
    echo "✅ Flutter SDK已存在，跳过安装"
fi

# 添加到PATH
if ! grep -q "flutter/bin" ~/.bashrc; then
    echo 'export PATH="$PATH:/root/flutter/bin"' >> ~/.bashrc
fi
export PATH="$PATH:/root/flutter/bin"

# 验证Flutter
echo ""
echo "验证Flutter安装..."
flutter --version

echo ""
echo "=========================================="
echo "  Flutter SDK安装完成！"
echo "=========================================="
echo ""
echo "下一步：运行 '服务器安装AndroidSDK.sh' 安装Android SDK"











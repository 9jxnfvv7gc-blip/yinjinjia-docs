#!/bin/bash

# 桌面影音播放器 - 自动化安装脚本
# 适用于 macOS

set -e  # 遇到错误立即退出

echo "=========================================="
echo "  桌面影音播放器 - 安装脚本"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装"
        return 0
    else
        echo -e "${RED}✗${NC} $1 未安装"
        return 1
    fi
}

# 步骤 1: 检查系统
echo "步骤 1: 检查系统环境..."
echo ""

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}错误：此脚本仅适用于 macOS${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} 系统：macOS"
echo ""

# 步骤 2: 检查 Flutter
echo "步骤 2: 检查 Flutter..."
echo ""

if check_command flutter; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo "  $FLUTTER_VERSION"
else
    echo -e "${YELLOW}Flutter 未安装，请按照以下步骤安装：${NC}"
    echo ""
    echo "1. 访问 https://flutter.dev/docs/get-started/install/macos"
    echo "2. 下载 Flutter SDK"
    echo "3. 解压到 ~/development/flutter"
    echo "4. 运行："
    echo "   echo 'export PATH=\"\$PATH:\$HOME/development/flutter/bin\"' >> ~/.zshrc"
    echo "   source ~/.zshrc"
    echo ""
    read -p "按 Enter 继续（安装 Flutter 后重新运行此脚本）..."
    exit 1
fi

# 步骤 3: 检查 Python
echo ""
echo "步骤 3: 检查 Python..."
echo ""

if check_command python3; then
    PYTHON_VERSION=$(python3 --version)
    echo "  $PYTHON_VERSION"
else
    echo -e "${RED}错误：Python 3 未安装${NC}"
    exit 1
fi

# 步骤 4: 检查 Xcode
echo ""
echo "步骤 4: 检查 Xcode..."
echo ""

if check_command xcodebuild; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo "  $XCODE_VERSION"
    
    # 检查 Xcode 路径
    XCODE_PATH=$(xcode-select -p)
    if [[ "$XCODE_PATH" != *"Xcode.app"* ]]; then
        echo -e "${YELLOW}警告：Xcode 路径可能不正确${NC}"
        echo "  当前路径：$XCODE_PATH"
        echo ""
        read -p "是否切换到正确的 Xcode 路径？(y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
            echo -e "${GREEN}✓${NC} Xcode 路径已更新"
        fi
    fi
else
    echo -e "${YELLOW}Xcode 未安装，请从 App Store 安装${NC}"
    exit 1
fi

# 步骤 5: 检查 CocoaPods
echo ""
echo "步骤 5: 检查 CocoaPods..."
echo ""

if check_command pod; then
    POD_VERSION=$(pod --version)
    echo "  CocoaPods $POD_VERSION"
else
    echo -e "${YELLOW}CocoaPods 未安装，正在安装...${NC}"
    if check_command brew; then
        brew install cocoapods
    else
        echo -e "${RED}错误：需要 Homebrew 来安装 CocoaPods${NC}"
        echo "请运行：brew install cocoapods"
        exit 1
    fi
fi

# 步骤 6: 安装 Flutter 依赖
echo ""
echo "步骤 6: 安装 Flutter 依赖..."
echo ""

if [ -f "pubspec.yaml" ]; then
    flutter pub get
    echo -e "${GREEN}✓${NC} Flutter 依赖安装完成"
else
    echo -e "${RED}错误：未找到 pubspec.yaml${NC}"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

# 步骤 7: 运行 Flutter Doctor
echo ""
echo "步骤 7: 检查 Flutter 环境..."
echo ""

flutter doctor

# 完成
echo ""
echo "=========================================="
echo -e "${GREEN}安装完成！${NC}"
echo "=========================================="
echo ""
echo "下一步："
echo ""
echo "1. 启动服务器："
echo "   python3 video_server.py \"/path/to/your/video/root\""
echo ""
echo "2. 运行 App："
echo "   flutter run -d macos"
echo ""
echo "3. 在 App 中连接服务器："
echo "   输入地址：http://localhost:8081"
echo ""
echo "详细说明请查看：README_安装说明.md"
echo ""


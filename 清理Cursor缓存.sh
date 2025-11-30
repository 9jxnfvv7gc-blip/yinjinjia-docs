#!/bin/bash

# Cursor 缓存清理脚本
# 安全清理Cursor的缓存文件，不会删除重要数据

echo "=========================================="
echo "🧹 Cursor 缓存清理工具"
echo "=========================================="
echo ""

# 检查Cursor是否正在运行
if pgrep -x "Cursor" > /dev/null; then
    echo "⚠️  检测到Cursor正在运行"
    echo "   建议先关闭Cursor，然后重新运行此脚本"
    echo ""
    read -p "是否继续清理？(y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消"
        exit 1
    fi
fi

echo "开始清理缓存..."
echo ""

# 1. 清理应用缓存
CACHE_DIR="$HOME/Library/Caches/Cursor"
if [ -d "$CACHE_DIR" ]; then
    echo "📁 清理应用缓存: $CACHE_DIR"
    rm -rf "$CACHE_DIR"/*
    echo "   ✅ 已清理"
else
    echo "   ℹ️  缓存目录不存在: $CACHE_DIR"
fi

# 2. 清理Code缓存（Cursor基于VS Code）
CODE_CACHE_DIR="$HOME/Library/Caches/com.todesktop.230313mzl4w4u92"
if [ -d "$CODE_CACHE_DIR" ]; then
    echo "📁 清理Code缓存: $CODE_CACHE_DIR"
    rm -rf "$CODE_CACHE_DIR"/*
    echo "   ✅ 已清理"
else
    echo "   ℹ️  缓存目录不存在: $CODE_CACHE_DIR"
fi

# 3. 清理日志文件
LOG_DIR="$HOME/Library/Application Support/Cursor/logs"
if [ -d "$LOG_DIR" ]; then
    echo "📁 清理日志文件: $LOG_DIR"
    rm -rf "$LOG_DIR"/*
    echo "   ✅ 已清理"
else
    echo "   ℹ️  日志目录不存在: $LOG_DIR"
fi

# 4. 清理临时文件
TEMP_DIR="$HOME/Library/Application Support/Cursor/CachedData"
if [ -d "$TEMP_DIR" ]; then
    echo "📁 清理临时数据: $TEMP_DIR"
    rm -rf "$TEMP_DIR"/*
    echo "   ✅ 已清理"
else
    echo "   ℹ️  临时目录不存在: $TEMP_DIR"
fi

# 5. 清理GPUCache（图形缓存）
GPU_CACHE="$HOME/Library/Application Support/Cursor/GPUCache"
if [ -d "$GPU_CACHE" ]; then
    echo "📁 清理GPU缓存: $GPU_CACHE"
    rm -rf "$GPU_CACHE"/*
    echo "   ✅ 已清理"
else
    echo "   ℹ️  GPU缓存目录不存在: $GPU_CACHE"
fi

# 6. 清理ShaderCache（着色器缓存）
SHADER_CACHE="$HOME/Library/Application Support/Cursor/ShaderCache"
if [ -d "$SHADER_CACHE" ]; then
    echo "📁 清理着色器缓存: $SHADER_CACHE"
    rm -rf "$SHADER_CACHE"/*
    echo "   ✅ 已清理"
else
    echo "   ℹ️  着色器缓存目录不存在: $SHADER_CACHE"
fi

# 7. 清理工作区缓存（可选，更彻底）
read -p "是否清理工作区缓存？这可能会清除最近打开的文件历史 (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    WORKSPACE_STORAGE="$HOME/Library/Application Support/Cursor/User/workspaceStorage"
    if [ -d "$WORKSPACE_STORAGE" ]; then
        echo "📁 清理工作区缓存: $WORKSPACE_STORAGE"
        rm -rf "$WORKSPACE_STORAGE"/*
        echo "   ✅ 已清理"
    fi
fi

echo ""
echo "=========================================="
echo "✅ 清理完成！"
echo "=========================================="
echo ""
echo "💡 建议："
echo "   1. 重新启动Cursor"
echo "   2. 如果问题仍然存在，可以尝试："
echo "      - 重启Mac"
echo "      - 检查磁盘空间"
echo "      - 检查是否有其他程序占用资源"
echo ""


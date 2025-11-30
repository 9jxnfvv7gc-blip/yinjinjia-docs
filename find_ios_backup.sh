#!/bin/bash

# iOS 备份快速查找脚本
# 使用方法：
#   ./find_ios_backup.sh              # 查找今天的备份
#   ./find_ios_backup.sh 20251130     # 查找指定日期的备份
#   ./find_ios_backup.sh open         # 在 Finder 中打开今天的备份
#   ./find_ios_backup.sh open 20251130 # 在 Finder 中打开指定日期的备份

BASE_DIR="/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

# 获取今天的日期
TODAY=$(date +%Y%m%d)

# 处理参数
ACTION="${1:-find}"
DATE="${2:-$TODAY}"

# 如果是 "open" 作为第一个参数，则使用今天的日期
if [ "$ACTION" = "open" ] && [ -z "$2" ]; then
    DATE="$TODAY"
    ACTION="open"
elif [ "$ACTION" = "open" ] && [ -n "$2" ]; then
    DATE="$2"
    ACTION="open"
elif [ "$ACTION" != "find" ] && [ -z "$2" ]; then
    # 如果第一个参数不是 "open" 也不是 "find"，可能是日期
    DATE="$ACTION"
    ACTION="find"
fi

BACKUP_DIR="$BASE_DIR/今日备份_$DATE"
IOS_CONFIG_DIR="$BACKUP_DIR/iOS配置"

echo "=========================================="
echo "iOS 备份查找工具"
echo "=========================================="

# 检查备份目录是否存在
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ 未找到备份目录: $BACKUP_DIR"
    echo ""
    echo "可用的备份日期："
    ls -d "$BASE_DIR"/今日备份_* 2>/dev/null | sed 's|.*今日备份_||' | sort -r
    exit 1
fi

echo "✅ 找到备份目录: $BACKUP_DIR"
echo "📅 日期: $DATE"
echo ""

# 检查 iOS 配置目录
if [ -d "$IOS_CONFIG_DIR" ]; then
    echo "✅ 找到 iOS 配置目录: $IOS_CONFIG_DIR"
    echo ""
    echo "📁 iOS 配置文件："
    ls -lh "$IOS_CONFIG_DIR" | tail -n +2 | awk '{print "   " $9 " (" $5 ")"}'
    echo ""
    
    if [ "$ACTION" = "open" ]; then
        echo "🔓 正在在 Finder 中打开..."
        open "$IOS_CONFIG_DIR"
        echo "✅ 已在 Finder 中打开 iOS 配置目录"
    else
        echo "💡 提示: 使用 './find_ios_backup.sh open $DATE' 在 Finder 中打开"
    fi
else
    echo "⚠️  备份目录存在，但未找到 iOS配置 子目录"
    echo "📁 备份目录内容："
    ls -lh "$BACKUP_DIR" | tail -n +2 | awk '{print "   " $9 " (" $5 ")"}'
fi

echo ""
echo "=========================================="


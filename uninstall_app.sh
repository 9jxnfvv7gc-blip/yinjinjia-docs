#!/bin/bash
# iOS 应用卸载脚本

echo "📱 开始卸载 iOS 应用..."

# 设备 ID
DEVICE_ID="00008110-00046D203CEBA01E"

# Bundle IDs（可能有不同的版本）
BUNDLE_IDS=(
    "com.xiaohui.videoMusicApp"
    "com.xiaohui.videomusicapp"
    "com.example.videoMusicApp"
    "com.example.video_music_app"
)

# 方法1：使用 xcrun devicectl（iOS 17+）
echo "🔍 方法1：尝试使用 xcrun devicectl 卸载..."
for bundle_id in "${BUNDLE_IDS[@]}"; do
    echo "   尝试卸载: $bundle_id"
    xcrun devicectl device uninstall app --device "$DEVICE_ID" "$bundle_id" 2>/dev/null && {
        echo "   ✅ 成功卸载: $bundle_id"
        exit 0
    }
done

# 方法2：使用 ideviceinstaller（如果已安装）
if command -v ideviceinstaller &> /dev/null; then
    echo "🔍 方法2：尝试使用 ideviceinstaller 卸载..."
    for bundle_id in "${BUNDLE_IDS[@]}"; do
        echo "   尝试卸载: $bundle_id"
        ideviceinstaller -u "$DEVICE_ID" -U "$bundle_id" 2>/dev/null && {
            echo "   ✅ 成功卸载: $bundle_id"
            exit 0
        }
    done
fi

# 方法3：使用 Xcode 命令行工具
echo "🔍 方法3：尝试使用 Xcode 工具卸载..."
for bundle_id in "${BUNDLE_IDS[@]}"; do
    echo "   尝试卸载: $bundle_id"
    xcrun simctl uninstall "$DEVICE_ID" "$bundle_id" 2>/dev/null || \
    xcodebuild -project ios/Runner.xcodeproj -scheme Runner -destination "id=$DEVICE_ID" clean 2>/dev/null
done

echo "⚠️  自动卸载失败，请使用以下方法："
echo ""
echo "方法1：在 iPhone 上手动卸载"
echo "   1. 长按应用图标"
echo "   2. 点击左上角的 'X' 删除"
echo "   3. 如果看不到 'X'，说明应用被锁定"
echo ""
echo "方法2：通过 Xcode 卸载"
echo "   1. 打开 Xcode"
echo "   2. Window → Devices and Simulators"
echo "   3. 选择你的 iPhone"
echo "   4. 在 Installed Apps 中找到应用"
echo "   5. 点击 '-' 卸载"
echo ""
echo "方法3：重启 iPhone 后再尝试卸载"
echo "   1. 重启 iPhone"
echo "   2. 然后再尝试长按图标删除"




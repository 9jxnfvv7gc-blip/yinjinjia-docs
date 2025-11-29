#!/bin/bash

# 彻底修复 iOS 冷启动闪退问题
# 这个脚本会：
# 1. 清理所有构建缓存
# 2. 禁用 PathProviderPlugin
# 3. 重新构建应用

cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

echo "🧹 步骤 1/5: 清理 Flutter 构建缓存..."
flutter clean

echo ""
echo "📦 步骤 2/5: 获取 Flutter 依赖..."
flutter pub get

echo ""
echo "🔧 步骤 3/5: 手动修复 GeneratedPluginRegistrant.m..."
./ios/fix_path_provider.sh

echo ""
echo "🍎 步骤 4/5: 更新 iOS Pods（会自动修复）..."
cd ios
pod install
cd ..

echo ""
echo "✅ 步骤 5/5: 验证修复是否生效..."
if grep -q "// \[PathProviderPlugin registerWithRegistrar" ios/Runner/GeneratedPluginRegistrant.m; then
    echo "✅ PathProviderPlugin 已成功禁用"
else
    echo "⚠️  警告：PathProviderPlugin 可能未完全禁用，手动修复中..."
    ./ios/fix_path_provider.sh
fi

echo ""
echo "🚀 现在可以运行应用了："
echo "   flutter run -d Dianhua"
echo ""
echo "📝 测试步骤："
echo "   1. 应用启动后，在终端按 'q' 退出（应用会留在手机上）"
echo "   2. 重启手机 → 解锁"
echo "   3. 直接点击桌面上的应用图标"
echo "   4. 验证是否不再闪退"


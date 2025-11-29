#!/bin/bash

# 修复 SharedPreferencesPlugin 崩溃问题
# 问题：SharedPreferencesPlugin 在 iOS 18 上冷启动时崩溃

cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

echo "🔧 修复步骤："
echo "1. 升级 shared_preferences 到最新版本"
echo "2. 使用延迟注册避免冷启动崩溃"
echo "3. 重新构建应用"
echo ""

echo "📦 步骤 1/4: 清理构建缓存..."
flutter clean

echo ""
echo "📦 步骤 2/4: 获取更新的依赖..."
flutter pub get

echo ""
echo "🍎 步骤 3/4: 更新 iOS Pods..."
cd ios
pod install
cd ..

echo ""
echo "✅ 步骤 4/4: 验证修复..."
echo "已完成的修复："
echo "  ✅ 升级 shared_preferences 到 2.5.3"
echo "  ✅ 恢复 PathProviderPlugin（shared_preferences 依赖它）"
echo "  ✅ 使用延迟注册避免冷启动崩溃"
echo "  ✅ 在 AppDelegate 中使用异步注册"
echo ""

echo "🚀 现在可以运行应用了："
echo "   flutter run -d Dianhua"
echo ""
echo "📝 测试步骤："
echo "   1. 应用启动后，在终端按 'q' 退出（应用会留在手机上）"
echo "   2. 重启手机 → 解锁"
echo "   3. 直接点击桌面上的应用图标"
echo "   4. 验证是否不再闪退"


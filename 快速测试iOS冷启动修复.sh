#!/bin/bash

# 快速测试 iOS 冷启动闪退修复
# 使用方法：./快速测试iOS冷启动修复.sh

cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

echo "🧹 清理构建缓存..."
flutter clean

echo "📦 获取依赖..."
flutter pub get

echo "🍎 更新 iOS Pods..."
cd ios
pod install
cd ..

echo "✅ 验证 PathProviderPlugin 是否已禁用..."
if grep -q "// \[PathProviderPlugin registerWithRegistrar" ios/Runner/GeneratedPluginRegistrant.m; then
    echo "✅ PathProviderPlugin 已成功禁用"
else
    echo "⚠️  PathProviderPlugin 未禁用，执行手动修复..."
    ./ios/fix_path_provider.sh
fi

echo ""
echo "🚀 开始运行应用..."
echo "   应用启动后，请在终端按 'q' 退出（应用会留在手机上）"
echo "   然后重启手机，直接点击应用图标测试冷启动"
echo ""
flutter run -d Dianhua


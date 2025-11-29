#!/bin/bash

# 临时禁用 SharedPreferencesPlugin 测试
# 目的：确认是否是 SharedPreferencesPlugin 导致崩溃

cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"

echo "🔧 临时禁用 SharedPreferencesPlugin 进行测试..."
echo ""

echo "📦 清理并重新构建..."
flutter clean
flutter pub get
cd ios && pod install && cd ..

echo ""
echo "✅ 已临时禁用 SharedPreferencesPlugin"
echo "⚠️  注意：这会导致以下功能不可用："
echo "   - 用户协议状态保存"
echo "   - 授权状态保存"
echo "   - 主题设置保存"
echo "   - 播放历史保存"
echo ""
echo "🚀 现在可以运行应用了："
echo "   flutter run -d Dianhua"
echo ""
echo "📝 测试步骤："
echo "   1. 应用启动后，在终端按 'q' 退出（应用会留在手机上）"
echo "   2. 重启手机 → 解锁"
echo "   3. 直接点击桌面上的应用图标"
echo "   4. 验证是否不再闪退"
echo ""
echo "💡 如果不再闪退，说明确实是 SharedPreferencesPlugin 的问题"
echo "   我们可以考虑使用其他存储方案或等待插件更新"


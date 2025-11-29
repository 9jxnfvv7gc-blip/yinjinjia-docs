#!/bin/bash

# 自动修复脚本：禁用 PathProviderPlugin 注册以避免 iOS 18 冷启动崩溃
# 使用方法：在每次 flutter build 或 flutter run 前执行此脚本

GENERATED_FILE="ios/Runner/GeneratedPluginRegistrant.m"

if [ ! -f "$GENERATED_FILE" ]; then
    echo "⚠️  GeneratedPluginRegistrant.m 不存在，跳过修复"
    exit 0
fi

# 检查是否已经修复过（避免重复修复）
if grep -q "// \[PathProviderPlugin registerWithRegistrar" "$GENERATED_FILE"; then
    echo "✅ PathProviderPlugin 已禁用，无需重复修复"
    exit 0
fi

# 备份原文件
cp "$GENERATED_FILE" "$GENERATED_FILE.backup"

# 使用 Python 进行更可靠的修复（避免 sed 在不同系统上的差异）
python3 << 'PYTHON_SCRIPT'
import re
import sys

file_path = "ios/Runner/GeneratedPluginRegistrant.m"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 检查是否已经修复过
    if '// [PathProviderPlugin registerWithRegistrar' in content:
        print("✅ PathProviderPlugin 已禁用，无需重复修复")
        sys.exit(0)
    
    # 注释掉 import 部分
    content = re.sub(
        r'#if __has_include\(<path_provider_foundation/PathProviderPlugin.h>\)',
        '// #if __has_include(<path_provider_foundation/PathProviderPlugin.h>)',
        content
    )
    content = re.sub(
        r'#import <path_provider_foundation/PathProviderPlugin.h>',
        '// #import <path_provider_foundation/PathProviderPlugin.h>',
        content
    )
    content = re.sub(
        r'@import path_provider_foundation;',
        '// @import path_provider_foundation;',
        content
    )
    
    # 注释掉注册调用
    content = re.sub(
        r'  \[PathProviderPlugin registerWithRegistrar:\[registry registrarForPlugin:@"PathProviderPlugin"\]\];',
        '  // [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];',
        content
    )
    
    # 添加说明注释
    if '// 临时禁用 path_provider 插件' not in content:
        content = content.replace(
            '#if __has_include(<path_provider_foundation/PathProviderPlugin.h>)',
            '// 临时禁用 path_provider 插件，以避免在 iOS 18 上冷启动时崩溃\n// 应用代码未使用 path_provider，因此可以安全移除\n// #if __has_include(<path_provider_foundation/PathProviderPlugin.h>)'
        )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ 已自动禁用 PathProviderPlugin 注册（避免 iOS 18 冷启动崩溃）")
    print("📝 原文件已备份为: ios/Runner/GeneratedPluginRegistrant.m.backup")
    
except Exception as e:
    print(f"❌ 修复失败: {e}")
    sys.exit(1)
PYTHON_SCRIPT

#!/usr/bin/env python3
"""
生成所有尺寸的应用图标并替换到项目中
"""

from PIL import Image, ImageDraw
import os
import shutil

# 项目路径
project_root = "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
source_icon = "/Users/xiaohuihu/Downloads/app-icon-1024.png"

def create_icon(size):
    """从源图标创建指定尺寸的图标"""
    source = Image.open(source_icon)
    # 高质量缩放
    icon = source.resize((size, size), Image.Resampling.LANCZOS)
    return icon

def generate_ios_icons():
    """生成 iOS 所有尺寸的图标"""
    ios_dir = f"{project_root}/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    
    # iOS 图标尺寸映射（文件名: 尺寸）
    ios_sizes = {
        "Icon-App-1024x1024@1x.png": 1024,
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
    }
    
    print("📱 生成 iOS 图标...")
    for filename, size in ios_sizes.items():
        icon = create_icon(size)
        output_path = os.path.join(ios_dir, filename)
        icon.save(output_path, 'PNG')
        print(f"   ✅ {filename} ({size}x{size})")

def generate_android_icons():
    """生成 Android 所有尺寸的图标"""
    android_res = f"{project_root}/android/app/src/main/res"
    
    # Android 图标尺寸映射（目录: 尺寸）
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    
    print("\n🤖 生成 Android 图标...")
    for mipmap_dir, size in android_sizes.items():
        icon = create_icon(size)
        output_path = os.path.join(android_res, mipmap_dir, "ic_launcher.png")
        icon.save(output_path, 'PNG')
        print(f"   ✅ {mipmap_dir}/ic_launcher.png ({size}x{size})")

def main():
    print("🎨 开始生成所有尺寸的应用图标...\n")
    
    # 检查源图标是否存在
    if not os.path.exists(source_icon):
        print(f"❌ 源图标不存在：{source_icon}")
        return
    
    # 生成 iOS 图标
    generate_ios_icons()
    
    # 生成 Android 图标
    generate_android_icons()
    
    print("\n✅ 所有图标已生成并替换完成！")
    print("\n📋 下一步：")
    print("   1. 重新编译应用：flutter build ios --release")
    print("   2. 重新编译 Android：flutter build apk --release")
    print("   3. 准备上架到 App Store 和 Google Play")

if __name__ == "__main__":
    main()




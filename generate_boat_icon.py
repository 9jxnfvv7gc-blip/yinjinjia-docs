#!/usr/bin/env python3
"""
生成小船图标（多尺寸版本）
用于替换应用图标
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_boat_icon(size, output_path):
    """创建小船图标"""
    # 创建透明背景
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 计算缩放因子（基于1024x1024）
    scale = size / 1024.0
    
    # 定义颜色
    boat_color = (52, 152, 219)  # 蓝色船身
    sail_color = (255, 255, 255)  # 白色船帆
    water_color = (52, 152, 219, 180)  # 半透明蓝色水面
    sun_color = (255, 193, 7)  # 金黄色太阳
    
    # 绘制背景（渐变蓝色天空）
    for y in range(size):
        alpha = int(135 + (y / size) * 40)  # 从浅到深
        color = (135, 206, 235, alpha)
        draw.rectangle([(0, y), (size, y+1)], fill=color)
    
    # 绘制太阳（右上角）
    sun_radius = int(80 * scale)
    sun_x = int(size * 0.8)
    sun_y = int(size * 0.2)
    draw.ellipse(
        [(sun_x - sun_radius, sun_y - sun_radius),
         (sun_x + sun_radius, sun_y + sun_radius)],
        fill=sun_color
    )
    
    # 绘制水面
    water_y = int(size * 0.7)
    draw.rectangle(
        [(0, water_y), (size, size)],
        fill=water_color
    )
    
    # 绘制波浪
    wave_amplitude = int(10 * scale)
    wave_frequency = 0.02
    for x in range(size):
        wave_y = water_y + int(wave_amplitude * (1 + abs(x * wave_frequency % 2 - 1)))
        draw.line([(x, wave_y), (x, size)], fill=(52, 152, 219, 200), width=int(2 * scale))
    
    # 绘制船身（底部）
    boat_width = int(400 * scale)
    boat_height = int(120 * scale)
    boat_x = int((size - boat_width) / 2)
    boat_y = int(size * 0.65)
    
    # 船身（椭圆形）
    boat_points = [
        (boat_x, boat_y + boat_height),
        (boat_x + boat_width, boat_y + boat_height),
        (boat_x + int(boat_width * 0.9), boat_y),
        (boat_x + int(boat_width * 0.1), boat_y),
    ]
    draw.ellipse(
        [(boat_x, boat_y), (boat_x + boat_width, boat_y + boat_height)],
        fill=boat_color,
        outline=(41, 128, 185, 255),
        width=int(3 * scale)
    )
    
    # 绘制船帆（三角形）
    sail_height = int(300 * scale)
    sail_width = int(180 * scale)
    sail_x = int(boat_x + boat_width * 0.4)
    sail_y = int(boat_y - sail_height)
    
    sail_points = [
        (sail_x, sail_y + sail_height),  # 底部左
        (sail_x + sail_width, sail_y + sail_height),  # 底部右
        (sail_x + int(sail_width * 0.3), sail_y),  # 顶部
    ]
    draw.polygon(sail_points, fill=sail_color, outline=(200, 200, 200, 255), width=int(2 * scale))
    
    # 绘制船帆上的线条（装饰）
    draw.line(
        [(sail_x + int(sail_width * 0.15), sail_y + int(sail_height * 0.3)),
         (sail_x + int(sail_width * 0.15), sail_y + sail_height)],
        fill=(220, 220, 220, 255),
        width=int(2 * scale)
    )
    draw.line(
        [(sail_x + int(sail_width * 0.5), sail_y + int(sail_height * 0.2)),
         (sail_x + int(sail_width * 0.5), sail_y + sail_height)],
        fill=(220, 220, 220, 255),
        width=int(2 * scale)
    )
    
    # 绘制桅杆
    mast_x = int(sail_x + sail_width * 0.3)
    mast_width = int(8 * scale)
    draw.rectangle(
        [(mast_x, sail_y), (mast_x + mast_width, boat_y)],
        fill=(139, 69, 19, 255)  # 棕色桅杆
    )
    
    # 保存图标
    img.save(output_path, 'PNG')
    print(f"✅ 已生成: {output_path} ({size}x{size})")

def main():
    """主函数"""
    print("🚤 开始生成小船图标...")
    
    # 创建输出目录
    output_dir = "icons/boat_icon"
    os.makedirs(output_dir, exist_ok=True)
    
    # iOS 图标尺寸
    ios_sizes = [
        (1024, "AppIcon-1024.png"),  # App Store
        (180, "AppIcon-180.png"),    # iPhone 6 Plus
        (120, "AppIcon-120.png"),    # iPhone 6
        (87, "AppIcon-87.png"),     # iPhone 5
        (80, "AppIcon-80.png"),     # iPhone 4
        (76, "AppIcon-76.png"),     # iPad
        (60, "AppIcon-60.png"),     # iPhone 3GS
        (58, "AppIcon-58.png"),     # iPhone Settings
        (40, "AppIcon-40.png"),     # iPhone Spotlight
        (29, "AppIcon-29.png"),     # iPhone Settings (small)
    ]
    
    # Android 图标尺寸
    android_sizes = [
        (1024, "icon-1024.png"),    # Play Store
        (512, "icon-512.png"),      # High-res
        (192, "mipmap-xxxhdpi/ic_launcher.png"),
        (144, "mipmap-xxhdpi/ic_launcher.png"),
        (96, "mipmap-xhdpi/ic_launcher.png"),
        (72, "mipmap-hdpi/ic_launcher.png"),
        (48, "mipmap-mdpi/ic_launcher.png"),
    ]
    
    # 生成 iOS 图标
    print("\n📱 生成 iOS 图标...")
    ios_dir = os.path.join(output_dir, "ios")
    os.makedirs(ios_dir, exist_ok=True)
    for size, filename in ios_sizes:
        output_path = os.path.join(ios_dir, filename)
        create_boat_icon(size, output_path)
    
    # 生成 Android 图标
    print("\n🤖 生成 Android 图标...")
    android_dir = os.path.join(output_dir, "android")
    os.makedirs(android_dir, exist_ok=True)
    for size, filename in android_sizes:
        # 处理 Android 目录结构
        if "/" in filename:
            dir_name = filename.split("/")[0]
            file_name = filename.split("/")[1]
            dir_path = os.path.join(android_dir, dir_name)
            os.makedirs(dir_path, exist_ok=True)
            output_path = os.path.join(dir_path, file_name)
        else:
            output_path = os.path.join(android_dir, filename)
        create_boat_icon(size, output_path)
    
    print(f"\n✅ 所有图标已生成到: {output_dir}/")
    print("\n📋 下一步：")
    print("1. iOS: 将 icons/boat_icon/ios/ 中的图标复制到 ios/Runner/Assets.xcassets/AppIcon.appiconset/")
    print("2. Android: 将 icons/boat_icon/android/ 中的图标复制到对应的 mipmap 目录")

if __name__ == "__main__":
    main()



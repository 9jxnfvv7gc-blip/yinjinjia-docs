#!/usr/bin/env python3
"""
生成应用图标
创建一个 1024x1024 的 PNG 图标，包含播放按钮和音符元素，蓝紫色渐变背景
"""

from PIL import Image, ImageDraw, ImageFont
import math

# 创建 1024x1024 的图像
size = 1024
img = Image.new('RGB', (size, size), color='#3B82F6')

# 创建绘图对象
draw = ImageDraw.Draw(img)

# 创建蓝紫色渐变背景
for y in range(size):
    # 从蓝色 (#3B82F6) 渐变到紫色 (#8B5CF6)
    ratio = y / size
    r1, g1, b1 = 0x3B, 0x82, 0xF6  # 蓝色
    r2, g2, b2 = 0x8B, 0x5C, 0xF6  # 紫色
    
    r = int(r1 + (r2 - r1) * ratio)
    g = int(g1 + (g2 - g1) * ratio)
    b = int(b1 + (b2 - b1) * ratio)
    
    color = (r, g, b)
    draw.line([(0, y), (size, y)], fill=color)

# 绘制圆角矩形背景（可选，让图标更现代）
corner_radius = size // 8  # 128px 圆角
mask = Image.new('L', (size, size), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)

# 绘制播放按钮（三角形）
play_size = size // 2.5  # 约 410px
play_x = size // 2 - play_size // 2
play_y = size // 2 - play_size // 2

# 播放按钮的三角形顶点
play_points = [
    (play_x, play_y),  # 左上
    (play_x, play_y + play_size),  # 左下
    (play_x + play_size * 0.866, play_y + play_size // 2),  # 右侧（等边三角形）
]

# 绘制白色播放按钮
draw.polygon(play_points, fill='#FFFFFF')

# 绘制音符符号（简化版，在播放按钮下方）
note_size = size // 8  # 约 128px
note_x = size // 2
note_y = size // 2 + play_size // 2 + note_size

# 绘制音符（简化版：圆形 + 竖线）
# 音符圆形部分
note_circle_radius = note_size // 3
draw.ellipse([
    note_x - note_circle_radius,
    note_y - note_circle_radius,
    note_x + note_circle_radius,
    note_y + note_circle_radius
], fill='#FFFFFF', outline='#FFFFFF', width=3)

# 音符竖线
draw.line([
    (note_x + note_circle_radius, note_y),
    (note_x + note_circle_radius, note_y + note_size)
], fill='#FFFFFF', width=note_size // 8)

# 保存图标
output_path = '/Users/xiaohuihu/Downloads/app-icon-1024.png'
img.save(output_path, 'PNG')
print(f'✅ 图标已创建：{output_path}')
print(f'   尺寸：{size}x{size} 像素')
print(f'   格式：PNG')




#!/usr/bin/env python3
"""
自动添加调试信息到video_server.py
"""

import sys
import os

# 文件路径
file_path = '/root/video_server/video_server.py'
backup_path = '/root/video_server/video_server.py.bak4'

# 读取文件
print(f"读取文件: {file_path}")
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 备份文件
print(f"备份文件到: {backup_path}")
with open(backup_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

# 查找并添加调试信息
new_lines = []
i = 0
found_643 = False
found_650 = False
found_677 = False

while i < len(lines):
    line = lines[i]
    new_lines.append(line)
    
    # 在第643行左右：if os.path.exists(category_path): 之后添加
    if 'if os.path.exists(category_path):' in line and not found_643:
        # 检查下一行是否已经有调试信息
        if i + 1 < len(lines) and '目录存在，开始扫描文件' in lines[i + 1]:
            print("第643行：调试信息已存在，跳过")
        else:
            # 添加调试信息（缩进16个空格）
            new_lines.append('                print(f"目录存在，开始扫描文件...")\n')
            print("第643行：已添加调试信息")
        found_643 = True
    
    # 在第650行左右：if ext in all_media_extensions: 之前添加
    if 'if ext in all_media_extensions:' in line and not found_650:
        # 检查上一行是否已经有调试信息
        if i > 0 and '文件: {f}, 扩展名:' in lines[i - 1]:
            print("第650行：调试信息已存在，跳过")
        else:
            # 在这一行之前添加调试信息（缩进24个空格）
            new_lines.insert(-1, '                        print(f"文件: {f}, 扩展名: {ext}, 在列表中: {ext in all_media_extensions}")\n')
            print("第650行：已添加调试信息")
            i += 1
            continue
        found_650 = True
    
    # 在第677行左右：file_list.append循环结束后添加
    if '})' in line and i > 0 and 'file_list.append' in ''.join(lines[max(0, i-10):i]):
        # 检查下一行是否已经有调试信息
        if i + 1 < len(lines) and '找到 {len(file_list)}' in lines[i + 1]:
            print("第677行：调试信息已存在，跳过")
        elif not found_677:
            # 检查是否在file_list.append的循环内
            # 查找最近的file_list.append
            for j in range(i, max(0, i-20), -1):
                if 'file_list.append' in lines[j]:
                    # 添加调试信息（缩进16个空格）
                    new_lines.append('                print(f"找到 {len(file_list)} 个文件")\n')
                    print("第677行：已添加调试信息")
                    found_677 = True
                    break
    
    i += 1

# 写入文件
print(f"写入文件: {file_path}")
with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("完成！调试信息已添加。")
print("请检查语法: python3 -m py_compile /root/video_server/video_server.py")


#!/usr/bin/env python3
"""
修复video_server.py，添加调试信息
"""

import sys

# 读取文件
with open('/root/video_server/video_server.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 备份
with open('/root/video_server/video_server.py.bak2', 'w', encoding='utf-8') as f:
    f.writelines(lines)

# 找到需要修改的位置并添加代码
new_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    new_lines.append(line)
    
    # 在第626行之后添加调试信息（在category_path = os.path.join(VIDEO_ROOT, category)之后）
    if i == 625 and 'category_path = os.path.join(VIDEO_ROOT, category)' in line:
        new_lines.append('            # 调试信息\n')
        new_lines.append('            print(f"API列表请求: category={category}, category_path={category_path}")\n')
        new_lines.append('            print(f"VIDEO_ROOT: {VIDEO_ROOT}")\n')
        new_lines.append('            print(f"路径存在: {os.path.exists(category_path)}")\n')
    
    # 在第638行之后添加（在if os.path.exists(category_path):之后）
    if i == 637 and 'if os.path.exists(category_path):' in line:
        new_lines.append('                print(f"目录存在，开始扫描文件...")\n')
    
    # 在第644行之后添加（在if ext in all_media_extensions:之前）
    if i == 643 and 'if ext in all_media_extensions:' in line:
        new_lines.insert(-1, '                        print(f"文件: {f}, 扩展名: {ext}, 在列表中: {ext in all_media_extensions}")\n')
        i += 1
        continue
    
    # 在第676行之后添加（在file_list.append循环结束后）
    if i == 675 and '})' in line and 'file_list.append' in lines[i-6:i]:
        # 检查是否是file_list.append的结束
        new_lines.append('                print(f"找到 {len(file_list)} 个文件")\n')
    
    i += 1

# 写入文件
with open('/root/video_server/video_server.py', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("修复完成！")


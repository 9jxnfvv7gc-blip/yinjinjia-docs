#!/usr/bin/env python3
"""
修复video_server.py的调试输出，使用sys.stderr.write确保输出到日志
"""
import sys
import os

file_path = '/root/video_server/video_server.py'

if not os.path.exists(file_path):
    print(f"错误: 文件不存在: {file_path}")
    sys.exit(1)

# 读取文件
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 检查是否已有import sys
has_import_sys = any('import sys' in line for line in lines)

# 修改内容
new_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # 在文件开头添加import sys（如果还没有）
    if i == 0 and not has_import_sys:
        # 找到第一个import语句的位置
        import_idx = 0
        for j, l in enumerate(lines):
            if l.strip().startswith('import '):
                import_idx = j
                break
        if i == import_idx:
            new_lines.append('import sys\n')
            has_import_sys = True
    
    # 修改print为sys.stderr.write
    if 'print(f"API列表请求:' in line:
        new_lines.append('            # 调试信息（使用sys.stderr确保输出到日志）\n')
        new_lines.append('            import sys\n')
        new_lines.append('            sys.stderr.write(f"API列表请求: category={category}, category_path={category_path}\\n")\n')
        # 跳过原来的3行print
        i += 3
        continue
    elif 'print(f"VIDEO_ROOT:' in line:
        # 已在上一步处理
        i += 1
        continue
    elif 'print(f"路径存在:' in line:
        # 已在上一步处理
        i += 1
        continue
    elif 'print(f"目录存在，开始扫描文件...")' in line:
        new_lines.append('                sys.stderr.write(f"目录存在，开始扫描文件...\\n")\n')
        new_lines.append('                sys.stderr.flush()\n')
        i += 1
        continue
    elif 'print(f"文件: {f}, 扩展名:' in line:
        new_lines.append('                        sys.stderr.write(f"文件: {f}, 扩展名: {ext}, 在列表中: {ext in all_media_extensions}\\n")\n')
        new_lines.append('                        sys.stderr.flush()\n')
        i += 1
        continue
    elif 'print(f"找到 {len(file_list)} 个文件")' in line:
        new_lines.append('                sys.stderr.write(f"找到 {len(file_list)} 个文件\\n")\n')
        new_lines.append('                sys.stderr.write(f"file_list内容: {file_list}\\n")\n')
        new_lines.append('                sys.stderr.write(f"videos长度（添加前）: {len(videos)}\\n")\n')
        new_lines.append('                sys.stderr.flush()\n')
        i += 1
        continue
    elif 'self.wfile.write(json.dumps(videos' in line and '最终返回videos长度' not in ''.join(new_lines[-5:]):
        # 在返回前添加调试信息
        new_lines.append('                sys.stderr.write(f"videos长度（添加后）: {len(videos)}\\n")\n')
        new_lines.append('                sys.stderr.write(f"videos内容: {videos}\\n")\n')
        new_lines.append('                sys.stderr.flush()\n')
        new_lines.append('            else:\n')
        new_lines.append('                sys.stderr.write(f"目录不存在: {category_path}\\n")\n')
        new_lines.append('                sys.stderr.flush()\n')
        new_lines.append('            \n')
        new_lines.append('            sys.stderr.write(f"最终返回videos长度: {len(videos)}\\n")\n')
        new_lines.append('            sys.stderr.flush()\n')
        new_lines.append(line)
        i += 1
        continue
    else:
        new_lines.append(line)
        i += 1

# 写入文件
with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f"✅ 已修改文件: {file_path}")
print("现在可以重新启动服务器测试了")


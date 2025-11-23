#!/usr/bin/env python3
"""
在服务器上修复video_server.py的返回格式
"""
import os
import re

file_path = '/root/video_server/video_server.py'

if not os.path.exists(file_path):
    print(f"错误: 文件不存在: {file_path}")
    exit(1)

# 备份文件
backup_path = file_path + '.bak10'
os.system(f'cp {file_path} {backup_path}')
print(f"✅ 已备份文件到: {backup_path}")

# 读取文件
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 查找并替换title和url的构建逻辑
# 查找: title = os.path.splitext(f)[0]
# 替换为: title = f

old_title_line = r"title = os\.path\.splitext\(f\)\[0\]"
new_title_line = "# 使用完整文件名作为title\ntitle = f"

if re.search(old_title_line, content):
    content = re.sub(old_title_line, new_title_line, content)
    print("✅ 已修复title")
else:
    print("⚠️  未找到title行，可能已经修改过")

# 查找并替换url构建逻辑
# 查找: url = f'{url_prefix}{relative_path}'
# 替换为完整的URL构建逻辑

old_url_pattern = r"url = f'\{url_prefix\}\{relative_path\}'"
new_url_code = """# 构建完整的URL（使用服务器IP）
                            # 获取服务器IP（从请求头或使用默认值）
                            server_host = self.headers.get('Host', '47.243.177.166:8081')
                            if ':' not in server_host:
                                server_host = f"{server_host}:8081"
                            full_url = f"http://{server_host}/{relative_path.replace(os.sep, '/')}"
                            url = full_url"""

if re.search(old_url_pattern, content):
    content = re.sub(old_url_pattern, new_url_code, content)
    print("✅ 已修复url")
else:
    # 尝试查找其他可能的url模式
    if "url_prefix" in content and "relative_path" in content:
        # 查找包含url_prefix和relative_path的行
        lines = content.split('\n')
        new_lines = []
        i = 0
        while i < len(lines):
            line = lines[i]
            if "'url': f'{url_prefix}{relative_path}'" in line or '"url": f\'{url_prefix}{relative_path}\'' in line:
                # 替换这一行
                indent = len(line) - len(line.lstrip())
                new_lines.append(' ' * indent + "'url': full_url,")
                # 在这之前插入URL构建代码
                url_build_code = [
                    ' ' * indent + "# 构建完整的URL（使用服务器IP）",
                    ' ' * indent + "# 获取服务器IP（从请求头或使用默认值）",
                    ' ' * indent + "server_host = self.headers.get('Host', '47.243.177.166:8081')",
                    ' ' * indent + "if ':' not in server_host:",
                    ' ' * indent + "    server_host = f\"{server_host}:8081\"",
                    ' ' * indent + "full_url = f\"http://{server_host}/{relative_path.replace(os.sep, '/')}\""
                ]
                # 找到file_list.append的位置，在url行之前插入
                for j in range(len(new_lines) - 1, -1, -1):
                    if "'url':" in new_lines[j] or '"url":' in new_lines[j]:
                        # 在这之前插入
                        new_lines.insert(j, '\n'.join(url_build_code))
                        break
                i += 1
                continue
            new_lines.append(line)
            i += 1
        content = '\n'.join(new_lines)
        print("✅ 已修复url（使用备用方法）")
    else:
        print("⚠️  未找到url行，可能已经修改过")

# 查找并替换id
# 查找: 'id': file_path,
# 替换为: 'id': f,  # 使用文件名作为id

old_id_pattern = r"'id': file_path,"
new_id_line = "'id': f,  # 使用文件名作为id"

if re.search(old_id_pattern, content):
    content = re.sub(old_id_pattern, new_id_line, content)
    print("✅ 已修复id")
else:
    # 尝试查找其他可能的id模式
    if '"id": file_path,' in content:
        content = content.replace('"id": file_path,', '"id": f,  # 使用文件名作为id')
        print("✅ 已修复id（使用备用方法）")
    else:
        print("⚠️  未找到id行，可能已经修改过")

# 写回文件
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# 检查语法
import subprocess
result = subprocess.run(['python3', '-m', 'py_compile', file_path], 
                       capture_output=True, text=True)
if result.returncode == 0:
    print("✅ 语法检查通过")
else:
    print(f"❌ 语法错误:\n{result.stderr}")
    print("正在恢复备份...")
    os.system(f'cp {backup_path} {file_path}')
    exit(1)

print("✅ 代码修改完成！")


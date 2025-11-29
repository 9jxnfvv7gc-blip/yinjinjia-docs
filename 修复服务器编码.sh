#!/bin/bash
# 修复服务器 JSON 响应的编码问题

echo "📋 修复服务器 JSON 响应的 Content-Type..."

ssh root@47.243.177.166 << 'SSH_EOF'
# 备份文件
cp /root/video_server/video_server.py /root/video_server/video_server.py.bak_encoding

# 查找并修复 JSON 响应的 Content-Type
# 在 json.dumps 之前添加 Content-Type header
python3 << 'PYTHON_EOF'
import re

file_path = '/root/video_server/video_server.py'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 查找 json.dumps 行，并在之前添加 Content-Type header
pattern = r'(self\.wfile\.write\(json\.dumps\([^)]+\)\.encode\(\'utf-8\'\)\))'
replacement = r"self.send_header('Content-Type', 'application/json; charset=utf-8')\n            self.end_headers()\n            \1"

new_content = re.sub(pattern, replacement, content)

if new_content != content:
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("✅ 已修复 JSON 响应的 Content-Type")
else:
    print("⚠️ 未找到需要修复的代码，可能已经修复过了")

# 检查语法
import py_compile
try:
    py_compile.compile(file_path, doraise=True)
    print("✅ 语法检查通过")
except py_compile.PyCompileError as e:
    print(f"❌ 语法错误: {e}")
PYTHON_EOF

# 重启服务器
pkill -f video_server.py
sleep 2
cd /root/video_server
python3 video_server.py > /tmp/video_server.log 2>&1 &
sleep 3
echo "✅ 服务器已重启"

# 测试
curl -s "http://localhost:8081/api/list/原创视频" | python3 -m json.tool | head -5
SSH_EOF

echo "✅ 修复完成"

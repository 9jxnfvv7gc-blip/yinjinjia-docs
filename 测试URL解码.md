# 测试URL解码

## 🔍 问题分析

测试脚本显示代码逻辑正确，但API返回空数组。问题可能是：
1. **URL编码问题**：中文字符没有被正确编码/解码
2. **HTTP请求处理问题**：category参数没有被正确解析

---

## 🧪 测试URL解码

在Workbench终端执行：

```bash
# 测试URL解码
python3 << 'EOF'
from urllib.parse import unquote, quote

# 测试1：原始category
category = '原创视频'
print(f"原始category: {category}")

# 测试2：URL编码
encoded = quote(category)
print(f"URL编码后: {encoded}")

# 测试3：URL解码
decoded = unquote(encoded)
print(f"URL解码后: {decoded}")

# 测试4：模拟HTTP请求路径
path = '/api/list/原创视频'
print(f"\n原始路径: {path}")

# 测试5：从路径提取category
category_from_path = path.replace('/api/list/', '')
print(f"提取的category（未解码）: {category_from_path}")
print(f"提取的category（解码后）: {unquote(category_from_path)}")

# 测试6：模拟curl请求的路径（可能包含编码）
path_encoded = '/api/list/' + encoded
print(f"\n编码后的路径: {path_encoded}")
category_from_encoded = path_encoded.replace('/api/list/', '')
print(f"提取的category（未解码）: {category_from_encoded}")
print(f"提取的category（解码后）: {unquote(category_from_encoded)}")
EOF
```

---

## 🚀 测试实际API请求

```bash
# 方法1：使用URL编码访问API
curl "http://localhost:8081/api/list/$(python3 -c "from urllib.parse import quote; print(quote('原创视频'))")"

# 方法2：直接访问（不编码）
curl "http://localhost:8081/api/list/原创视频"

# 方法3：查看服务器日志（如果有systemd服务）
journalctl -u video-server -n 20 --no-pager
```

---

## 📋 执行后

把输出结果发给我，我会根据结果判断问题在哪里。

---

**先执行URL解码测试，把结果发给我！** 🔍


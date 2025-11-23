# 修复VIDEO_ROOT路径

## ❌ 问题

从日志看到：
```
VIDEO_ROOT: /Volumes/Expansion
路径存在: False
目录不存在: /Volumes/Expansion/原创视频
```

**问题**：`VIDEO_ROOT`还是`/Volumes/Expansion`，应该改为`/root/videos`。

---

## 🔧 修复方法

### 在Workbench终端执行：

```bash
# 停止服务器
pkill -f video_server.py
systemctl stop video-server

# 修改VIDEO_ROOT（第20行）
sed -i '20s|VIDEO_ROOT = "/Volumes/Expansion"|VIDEO_ROOT = "/root/videos"|g' /root/video_server/video_server.py

# 确认修改
grep -n "VIDEO_ROOT" /root/video_server/video_server.py

# 检查语法
python3 -m py_compile /root/video_server/video_server.py && echo "✅ 语法检查通过" || echo "❌ 语法错误"

# 重新启动服务器
cd /root/video_server
python3 video_server.py > /tmp/video_server.log 2>&1 &
sleep 3

# 测试API
curl "http://localhost:8081/api/list/$(python3 -c "from urllib.parse import quote; print(quote('原创视频'))")"

# 查看日志
cat /tmp/video_server.log
```

---

## 📋 执行后

应该看到：
- `VIDEO_ROOT: /root/videos`
- `路径存在: True`
- API返回正确的JSON格式（title是"1.mp4"，url是完整URL）

---

**先执行上面的命令，把结果发给我！** 🔧


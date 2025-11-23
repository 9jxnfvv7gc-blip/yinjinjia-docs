# 修复视频URL问题

## ❌ 问题

1. **URL缺少`/video/`前缀**：API返回的URL是`/原创视频/1.mp4`，但实际访问路径应该是`/video/原创视频/1.mp4`
2. **URL使用了localhost**：从外部访问时应该使用服务器IP `47.243.177.166`

---

## ✅ 已修复

1. ✅ 在URL构建时添加了`url_prefix`（`/video/`或`/music/`）
2. ✅ 如果Host是localhost，强制使用服务器IP `47.243.177.166:8081`

---

## 📤 上传修改后的文件

### 在你的Mac终端执行：

```bash
scp "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py" root@47.243.177.166:/root/video_server/
```

---

## 🚀 在服务器上重启并测试

### 在Workbench终端执行：

```bash
# 停止服务器
pkill -f video_server.py
systemctl stop video-server

# 重新启动服务器
cd /root/video_server
python3 video_server.py > /tmp/video_server.log 2>&1 &
sleep 3

# 测试API
curl "http://localhost:8081/api/list/$(python3 -c "from urllib.parse import quote; print(quote('原创视频'))")"

# 查看返回的URL（应该包含/video/前缀和正确的IP）
curl "http://localhost:8081/api/list/$(python3 -c "from urllib.parse import quote; print(quote('原创视频'))")" | python3 -m json.tool
```

---

## 📋 执行后

应该看到URL格式为：
```json
{
  "title": "1.mp4",
  "url": "http://47.243.177.166:8081/video/原创视频/1.mp4",
  "id": "1.mp4"
}
```

---

**先上传文件，然后重启服务器测试！** 📤


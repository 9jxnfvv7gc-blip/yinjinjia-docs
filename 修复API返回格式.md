# 修复API返回格式

## ✅ 当前状态

- ✅ API返回了数据（9个视频）
- ❌ 格式不正确：
  - `title`: "1" 应该是 "1.mp4"
  - `url`: "/video/原创视频/1.mp4" 应该是 "http://47.243.177.166:8081/原创视频/1.mp4"
  - `id`: "/root/videos/原创视频/1.mp4" 应该是 "1.mp4"

---

## 🔧 已修复

已修改代码，使其返回正确的格式：
- `title`: 完整文件名（如 "1.mp4"）
- `url`: 完整URL（如 "http://47.243.177.166:8081/原创视频/1.mp4"）
- `id`: 文件名（如 "1.mp4"）

---

## 📤 上传修改后的文件

### 方法1：使用Workbench文件管理器

1. 打开Workbench文件管理器
2. 导航到 `/root/video_server/`
3. 上传本地的 `video_server.py` 文件（覆盖现有文件）

---

### 方法2：使用scp（如果SSH可用）

在你的Mac终端执行：

```bash
scp "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py" root@47.243.177.166:/root/video_server/
```

---

## 🧪 测试步骤

### 步骤1：停止服务器

```bash
# 停止后台服务器
pkill -f video_server.py

# 停止systemd服务
systemctl stop video-server
```

---

### 步骤2：上传文件

使用Workbench文件管理器或scp上传修改后的 `video_server.py`。

---

### 步骤3：重新启动服务器

```bash
cd /root/video_server
python3 video_server.py > /tmp/video_server.log 2>&1 &
sleep 2
```

---

### 步骤4：测试API

```bash
curl "http://localhost:8081/api/list/$(python3 -c "from urllib.parse import quote; print(quote('原创视频'))")"
```

**应该返回**：
```json
[
  {"title": "1.mp4", "url": "http://47.243.177.166:8081/原创视频/1.mp4", "id": "1.mp4"},
  {"title": "2.mp4", "url": "http://47.243.177.166:8081/原创视频/2.mp4", "id": "2.mp4"},
  ...
]
```

---

## 🎯 现在可以执行

1. **上传修改后的文件**（使用Workbench文件管理器或scp）
2. **停止服务器**（`pkill -f video_server.py`）
3. **重新启动服务器**（`python3 video_server.py > /tmp/video_server.log 2>&1 &`）
4. **测试API**（`curl ...`）

---

**先上传文件，然后重新测试！** 📤


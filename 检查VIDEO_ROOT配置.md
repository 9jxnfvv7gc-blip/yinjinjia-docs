# 检查VIDEO_ROOT配置

## 🔍 检查配置

### 步骤1：查看VIDEO_ROOT的初始定义

在Workbench终端执行：

```bash
# 查看文件开头的VIDEO_ROOT定义（前20行）
head -20 /root/video_server/video_server.py | grep -A 2 -B 2 "VIDEO_ROOT"
```

或者：

```bash
# 查看第19-21行（VIDEO_ROOT定义的位置）
sed -n '19,21p' /root/video_server/video_server.py
```

**应该看到**：
```python
VIDEO_ROOT = "/root/videos"
```

**如果看到**：
```python
VIDEO_ROOT = "/Volumes/Expansion"
```

**需要修改**。

---

### 步骤2：如果配置不正确，修改配置

在Workbench终端执行：

```bash
cd /root/video_server

# 修改配置
sed -i 's|VIDEO_ROOT = "/Volumes/Expansion"|VIDEO_ROOT = "/root/videos"|g' video_server.py

# 验证修改
sed -n '19,21p' video_server.py
```

**应该显示**：`VIDEO_ROOT = "/root/videos"`

---

### 步骤3：重启服务

在Workbench终端执行：

```bash
# 重启服务使配置生效
systemctl restart video-server

# 检查服务状态
systemctl status video-server

# 查看服务日志（确认VIDEO_ROOT）
journalctl -u video-server -n 10
```

**日志中应该显示**：`视频根目录: /root/videos`

---

### 步骤4：测试服务器

在Workbench终端执行：

```bash
# 测试API
curl http://localhost:8081/api/list/原创视频
curl http://localhost:8081/api/list/原创歌曲
```

**应该返回**：`[]`（空数组）

---

## 📋 完整操作流程

### 在Workbench终端执行：

```bash
# 1. 检查配置
sed -n '19,21p' /root/video_server/video_server.py

# 2. 如果配置不正确，修改
cd /root/video_server
sed -i 's|VIDEO_ROOT = "/Volumes/Expansion"|VIDEO_ROOT = "/root/videos"|g' video_server.py
sed -n '19,21p' video_server.py

# 3. 重启服务
systemctl restart video-server
systemctl status video-server

# 4. 查看日志确认
journalctl -u video-server -n 10

# 5. 测试API
curl http://localhost:8081/api/list/原创视频
```

---

## 🎯 现在可以执行

1. **检查配置**：`sed -n '19,21p' /root/video_server/video_server.py`
2. **如果配置不正确，修改并重启服务**
3. **测试API**

---

**先执行检查配置的命令，告诉我结果！** 🔍


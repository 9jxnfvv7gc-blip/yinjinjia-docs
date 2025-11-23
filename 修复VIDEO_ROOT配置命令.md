# 修复VIDEO_ROOT配置命令

## 🔧 修复步骤

### 步骤1：停止服务器

在Workbench终端执行：

```bash
# 停止服务器
systemctl stop video-server
```

---

### 步骤2：修复VIDEO_ROOT配置（第20行）

在Workbench终端执行：

```bash
cd /root/video_server

# 备份文件
cp video_server.py video_server.py.bak6

# 修改第20行的VIDEO_ROOT
sed -i '20s|VIDEO_ROOT = "/Volumes/Expansion"|VIDEO_ROOT = "/root/videos"|g' video_server.py

# 验证修改
sed -n '20p' video_server.py
```

**应该显示**：`VIDEO_ROOT = "/root/videos"  # 改成你的视频根目录路径`

---

### 步骤3：检查语法

```bash
python3 -m py_compile /root/video_server/video_server.py
```

**如果没有错误**，说明语法正确。

---

### 步骤4：测试运行

```bash
# 手动运行服务器，查看VIDEO_ROOT
python3 video_server.py
```

**应该显示**：`视频根目录: /root/videos`

按 `Ctrl+C` 停止测试。

---

### 步骤5：启动服务器

```bash
# 启动服务器
systemctl start video-server

# 检查状态
systemctl status video-server
```

**应该显示**：`active (running)`

---

### 步骤6：测试API

```bash
# 测试API
curl http://localhost:8081/api/list/原创视频
```

**应该返回**：文件列表（不再是空数组 `[]`）

---

### 步骤7：查看日志

```bash
# 查看实时日志
journalctl -u video-server -f
```

然后访问API（在另一个终端）：
```bash
curl http://localhost:8081/api/list/原创视频
```

**应该看到调试信息**：
- `VIDEO_ROOT: /root/videos`
- `路径存在: True`
- `目录存在，开始扫描文件...`
- `文件: 1.mp4, 扩展名: .mp4, 在列表中: True`
- `找到 X 个文件`

---

## 🎯 现在可以执行

1. **停止服务器**（`systemctl stop video-server`）
2. **修复VIDEO_ROOT配置**（`sed -i '20s|VIDEO_ROOT = "/Volumes/Expansion"|VIDEO_ROOT = "/root/videos"|g' video_server.py`）
3. **验证修改**（`sed -n '20p' video_server.py`）
4. **启动服务器**（`systemctl start video-server`）
5. **测试API**（`curl http://localhost:8081/api/list/原创视频`）

---

**先停止服务器，然后修复VIDEO_ROOT配置！** 🔧


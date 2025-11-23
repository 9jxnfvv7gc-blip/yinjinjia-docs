# 使用Workbench上传文件到北京服务器

## 📤 上传步骤

### 方法1：使用Workbench文件管理器（最简单）

1. **在Workbench中**，点击左侧工具栏的"文件管理器"图标
   - 图标通常是一个文件夹图标
   - 或者点击"文件"菜单 -> "文件管理器"

2. **导航到目标目录**：
   - 在地址栏输入：`/home/admin/`
   - 或者直接输入：`/root/video_server/`

3. **上传文件**：
   - 点击"上传"按钮（通常在上方工具栏）
   - 选择本地的 `video_server.py` 文件
   - 等待上传完成

4. **如果上传到/home/admin，移动文件**：
   ```bash
   sudo mv /home/admin/video_server.py /root/video_server/
   sudo chown root:root /root/video_server/video_server.py
   ```

---

### 方法2：使用scp（需要密码）

在你的Mac终端执行：

```bash
scp "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py" admin@39.107.137.136:/tmp/
```

**如果提示输入密码**，输入admin用户的密码。

然后在服务器上：

```bash
sudo mv /tmp/video_server.py /root/video_server/
sudo chown root:root /root/video_server/video_server.py
```

---

### 方法3：检查文件是否已上传

在服务器上检查：

```bash
# 检查/tmp目录
ls -la /tmp/video_server.py

# 检查/home/admin目录
ls -la /home/admin/video_server.py

# 检查/root/video_server目录
sudo ls -la /root/video_server/
```

---

## 🔧 上传后配置

文件上传后，在服务器上执行：

```bash
# 1. 确认文件存在
sudo ls -la /root/video_server/video_server.py

# 2. 修改VIDEO_ROOT
sudo sed -i '20s|VIDEO_ROOT = "/Volumes/Expansion"|VIDEO_ROOT = "/root/videos"|g' /root/video_server/video_server.py

# 3. 确认配置
sudo grep -n "VIDEO_ROOT" /root/video_server/video_server.py | head -1

# 4. 重启服务
sudo systemctl restart video-server-beijing

# 5. 检查服务状态
sudo systemctl status video-server-beijing

# 6. 查看日志（检查是否有错误）
sudo tail -30 /var/log/video-server-beijing-error.log
```

---

## 📋 推荐方法

**使用Workbench文件管理器**：
1. 点击"文件管理器"图标
2. 上传文件到 `/home/admin/`
3. 在终端执行 `sudo mv` 移动文件

---

**先使用Workbench文件管理器上传文件，然后告诉我结果！** 📤


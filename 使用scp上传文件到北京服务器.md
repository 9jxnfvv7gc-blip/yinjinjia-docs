# 使用scp上传文件到北京服务器

## 📤 方法：使用scp命令

### 在你的Mac终端执行：

```bash
scp "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py" admin@39.107.137.136:/tmp/
```

**如果提示输入密码**，输入admin用户的密码。

---

## 🔍 如果scp命令找不到文件

### 检查文件是否存在

在你的Mac终端执行：

```bash
ls -la "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py"
```

如果文件存在，应该能看到文件信息。

---

## 📋 上传后操作

### 在服务器终端执行：

```bash
# 1. 检查文件是否上传成功
ls -la /tmp/video_server.py

# 2. 如果文件存在，移动文件
sudo mv /tmp/video_server.py /root/video_server/
sudo chown root:root /root/video_server/video_server.py

# 3. 确认文件存在
sudo ls -la /root/video_server/video_server.py

# 4. 修改VIDEO_ROOT
sudo sed -i '20s|VIDEO_ROOT = "/Volumes/Expansion"|VIDEO_ROOT = "/root/videos"|g' /root/video_server/video_server.py

# 5. 确认配置
sudo grep -n "VIDEO_ROOT" /root/video_server/video_server.py | head -1

# 6. 重启服务
sudo systemctl restart video-server-beijing

# 7. 检查服务状态
sudo systemctl status video-server-beijing
```

---

## 🎯 现在可以执行

1. **在你的Mac终端执行scp命令**（上传文件）
2. **在服务器终端检查文件**（`ls -la /tmp/video_server.py`）
3. **移动文件并配置**

---

**先在你的Mac终端执行scp命令，把结果发给我！** 📤


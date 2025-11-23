# 北京服务器配置（使用sudo）

## ⚠️ 权限问题

当前用户是 `admin`，需要使用 `sudo` 执行系统命令。

---

## 🚀 配置步骤（使用sudo）

### 步骤1：创建目录

在服务器终端执行：

```bash
# 创建目录（使用sudo）
sudo mkdir -p /root/video_server
sudo mkdir -p /root/videos/原创视频
sudo mkdir -p /root/videos/原创歌曲

# 确认创建成功
sudo ls -la /root/video_server
sudo ls -la /root/videos
```

---

### 步骤2：上传video_server.py

#### 方法1：使用scp（推荐）

在你的Mac终端执行：

```bash
scp "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py" admin@39.107.137.136:/tmp/
```

然后在服务器上移动文件：

```bash
sudo mv /tmp/video_server.py /root/video_server/
sudo chown root:root /root/video_server/video_server.py
```

#### 方法2：使用Workbench文件管理器

1. **在Workbench中**，点击"文件管理器"图标
2. **导航到** `/root/video_server/`（可能需要sudo权限）
3. **上传** `video_server.py` 文件

---

### 步骤3：配置VIDEO_ROOT

在服务器终端执行：

```bash
# 修改VIDEO_ROOT（使用sudo）
sudo sed -i '20s|VIDEO_ROOT = "/Volumes/Expansion"|VIDEO_ROOT = "/root/videos"|g' /root/video_server/video_server.py

# 确认配置
sudo grep -n "VIDEO_ROOT" /root/video_server/video_server.py | head -1
```

---

### 步骤4：配置自动启动（使用sudo）

在服务器终端执行：

```bash
# 1. 创建systemd服务文件（使用sudo）
sudo tee /etc/systemd/system/video-server-beijing.service > /dev/null << 'EOF'
[Unit]
Description=Video Server (Beijing)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/video_server
ExecStart=/usr/bin/python3 /root/video_server/video_server.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/video-server-beijing.log
StandardError=append:/var/log/video-server-beijing-error.log

[Install]
WantedBy=multi-user.target
EOF

# 2. 重新加载systemd配置
sudo systemctl daemon-reload

# 3. 启用服务（开机自启）
sudo systemctl enable video-server-beijing

# 4. 启动服务
sudo systemctl start video-server-beijing

# 5. 检查服务状态
sudo systemctl status video-server-beijing
```

---

### 步骤5：配置防火墙（使用sudo）

在服务器终端执行：

```bash
# 检查防火墙状态
sudo ufw status

# 开放8081端口
sudo ufw allow 8081/tcp

# 如果防火墙未启用，先启用
sudo ufw enable

# 重新加载
sudo ufw reload
```

---

### 步骤6：配置安全组（在阿里云控制台）

1. **打开阿里云ECS控制台**
2. **找到北京服务器（39.107.137.136）**
3. **点击"安全组"**
4. **添加规则**：
   - 端口：8081
   - 协议：TCP
   - 授权对象：0.0.0.0/0（允许所有IP访问）

---

### 步骤7：测试服务器

在服务器终端执行：

```bash
# 等待几秒让服务器启动
sleep 3

# 测试API
curl "http://localhost:8081/api/list/$(python3 -c "from urllib.parse import quote; print(quote('原创视频'))")"

# 查看日志
sudo tail -20 /var/log/video-server-beijing.log
```

---

## 📋 执行顺序

1. **创建目录**（步骤1，使用sudo）
2. **上传video_server.py**（步骤2）
3. **配置VIDEO_ROOT**（步骤3，使用sudo）
4. **配置自动启动**（步骤4，使用sudo）
5. **配置防火墙**（步骤5，使用sudo）
6. **配置安全组**（步骤6，在阿里云控制台）
7. **测试服务器**（步骤7）

---

**先执行步骤1（创建目录，使用sudo），然后告诉我结果！** 🚀


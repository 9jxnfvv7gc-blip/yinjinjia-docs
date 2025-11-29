# 📝 在服务器上创建 video_server.py 的步骤

## 方法1：使用 scp（需要手动输入密码）

在本地 Mac 终端执行：

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
scp video_server.py admin@39.107.137.136:/tmp/video_server.py
```

然后输入密码（admin 用户的密码）。

然后在服务器上执行：

```bash
sudo mv /tmp/video_server.py /root/app/
sudo chmod +x /root/app/video_server.py
```

## 方法2：使用阿里云控制台上传（最简单）

1. 登录阿里云控制台：https://ecs.console.aliyun.com
2. 找到服务器实例
3. 点击"远程连接" → "文件管理"
4. 上传 `video_server.py` 到 `/root/app/` 目录

## 方法3：在服务器上直接下载（如果有网络）

如果服务器可以访问 GitHub 或其他地方，可以：

```bash
# 如果文件在某个可访问的 URL
wget https://文件地址/video_server.py -O /root/app/video_server.py
chmod +x /root/app/video_server.py
```

## 方法4：使用 cat 和 heredoc（如果文件不太大）

在服务器上执行：

```bash
cat > /root/app/video_server.py << 'EOF'
# 然后粘贴文件内容
# 最后输入 EOF 结束
EOF

chmod +x /root/app/video_server.py
```

## ✅ 上传后的步骤

文件上传后，在服务器上执行：

```bash
# 1. 确认文件存在
ls -la /root/app/video_server.py

# 2. 设置权限
chmod +x /root/app/video_server.py

# 3. 检查视频目录
ls -la /root/videos/原创视频/

# 4. 启动服务器
cd /root/app
export VIDEO_ROOT="/root/videos"
nohup python3 video_server.py > /root/server.log 2>&1 &

# 5. 检查进程
ps aux | grep video_server.py

# 6. 查看日志
tail -30 /root/server.log

# 7. 测试 API
curl http://localhost:8081/api/categories
```



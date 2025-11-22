# 桌面影音播放器 - 安装和使用说明

## 📦 分享方式说明

由于无法直接分享 `.app` 或 `.dmg` 文件，本安装包包含：
- 完整的源代码
- 详细的安装步骤
- 自动化安装脚本

接收者需要按照以下步骤安装和运行。

---

## 🚀 快速开始

### 第一步：安装 Flutter

1. **下载 Flutter SDK**
   - 访问：https://flutter.dev/docs/get-started/install/macos
   - 下载 macOS 版本（ARM64 或 Intel）
   - 解压到：`~/development/flutter`（或任意位置）

2. **配置环境变量**
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **验证安装**
   ```bash
   flutter --version
   flutter doctor
   ```

4. **安装依赖**
   - 安装 Xcode（从 App Store）
   - 运行：`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
   - 运行：`sudo xcodebuild -runFirstLaunch`
   - 安装 CocoaPods：`brew install cocoapods`

### 第二步：运行项目

1. **进入项目目录**
   ```bash
   cd /path/to/video_music_app
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **启动服务器**
   ```bash
   # 在项目根目录运行
   python3 video_server.py "/path/to/your/video/root/directory"
   ```
   
   例如：
   ```bash
   python3 video_server.py "/Volumes/Expansion/MV【1.62GB】"
   ```
   
   服务器启动后，你会看到：
   ```
   启动视频服务器...
   端口: 8081
   视频根目录: /path/to/your/video/root/directory
   
   访问 http://localhost:8081 查看服务器状态
   在 Flutter App 中输入服务器地址: http://192.168.x.x:8081
   ```

4. **运行 Flutter App**
   ```bash
   flutter run -d macos
   ```

### 第三步：使用 App

1. **连接服务器**
   - 打开 App
   - 点击"连接服务器"按钮
   - 输入：`http://localhost:8081`
   - 点击确认

2. **上传视频/音乐**
   - 选择分类
   - 点击"上传"按钮
   - 选择文件（支持批量选择）

3. **播放媒体**
   - 点击视频/音乐卡片即可播放

---

## 📁 项目结构

```
video_music_app/
├── lib/
│   ├── main.dart              # 主入口
│   ├── models.dart             # 数据模型
│   ├── video_page.dart        # 视频页面
│   ├── music_page.dart        # 音乐页面
│   ├── video_player_page.dart # 视频播放器
│   └── music_player_page.dart # 音乐播放器
├── video_server.py            # Python 服务器
├── pubspec.yaml               # Flutter 依赖配置
└── README_安装说明.md         # 本文件
```

---

## 🛠️ 系统要求

- **操作系统**：macOS 10.14 或更高版本
- **Python**：3.7 或更高版本（系统自带）
- **Flutter**：3.0 或更高版本
- **Xcode**：最新版本（从 App Store 安装）
- **CocoaPods**：用于 iOS/macOS 依赖管理

---

## ⚙️ 配置说明

### 修改视频根目录

编辑 `video_server.py`，修改 `VIDEO_ROOT` 变量，或通过命令行参数指定：

```bash
python3 video_server.py "/your/custom/path"
```

### 修改服务器端口

编辑 `video_server.py`，修改 `PORT` 变量（默认：8081）

### 修改分类

编辑 `lib/models.dart`，修改 `videoCategories` 和 `musicCategories` 列表

---

## 🐛 常见问题

### 1. Flutter 命令未找到

**解决方法**：
```bash
# 检查 PATH 配置
echo $PATH

# 重新配置
export PATH="$PATH:$HOME/development/flutter/bin"
source ~/.zshrc
```

### 2. Xcode 相关错误

**解决方法**：
```bash
# 切换到正确的 Xcode 路径
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# 运行首次启动配置
sudo xcodebuild -runFirstLaunch
```

### 3. 服务器连接失败

**检查清单**：
- ✅ 服务器是否正在运行？
- ✅ 端口是否正确（默认 8081）？
- ✅ 地址是否正确（`http://localhost:8081`）？
- ✅ 防火墙是否阻止连接？

**解决方法**：
```bash
# 检查端口是否被占用
lsof -i :8081

# 如果被占用，停止占用进程
kill -9 <PID>
```

### 4. 文件上传失败

**可能原因**：
- 服务器未连接
- 文件格式不支持
- 文件路径包含特殊字符

**解决方法**：
- 确保已连接服务器
- 检查文件格式是否在支持列表中
- 重命名文件，避免特殊字符

### 5. 视频/音乐无法播放

**可能原因**：
- 文件路径错误
- 文件格式不支持
- 网络连接问题

**解决方法**：
- 检查文件是否存在
- 确认文件格式在支持列表中
- 检查网络连接

---

## 📝 支持的文件格式

### 视频格式
- MP4, MOV, MKV, AVI
- RMVB, RM, WMV, FLV, F4V, M4V
- MPG, MPEG, 3GP, WEBM
- TS, MTS, VOB, DIVX, XVID

### 音乐格式
- MP3, M4A, FLAC, WAV
- AAC, OGG, WMA

---

## 🔒 权限设置

macOS 可能需要以下权限：
- **网络客户端**：允许 App 连接服务器
- **文件访问**：允许选择文件上传

这些权限已在 `macos/Runner/DebugProfile.entitlements` 和 `macos/Runner/Release.entitlements` 中配置。

---

## 📞 获取帮助

如果遇到问题：
1. 检查终端错误信息
2. 查看 Flutter 日志：`flutter run -d macos -v`
3. 检查服务器日志
4. 参考本文档的"常见问题"部分

---

## 🎉 开始使用

现在你可以：
1. 启动服务器
2. 运行 Flutter App
3. 连接服务器
4. 上传和播放你的视频/音乐！

祝你使用愉快！🎬🎵


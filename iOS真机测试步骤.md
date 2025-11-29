# 📱 iOS真机测试步骤

## 🔌 步骤1：连接iPhone

1. **用USB线连接iPhone和Mac**
2. **在iPhone上**：
   - 如果弹出"信任此电脑"，点击"信任"
   - 输入iPhone密码确认

## 🔧 步骤2：在Xcode中配置

1. **打开Xcode项目**（已自动打开）：
   - `ios/Runner.xcworkspace`

2. **选择设备**：
   - 在Xcode顶部工具栏，点击设备选择器
   - 选择你的iPhone（应该会显示设备名称）

3. **配置签名**：
   - 在左侧选择 `Runner` 项目
   - 选择 `Runner` target
   - 点击 `Signing & Capabilities` 标签
   - **Team**：选择 "Xiaohui Hu"（你的Apple ID）
   - **Bundle Identifier**：应该是 `com.example.videoMusicApp`
   - 确保 "Automatically manage signing" 已勾选

4. **如果签名失败**：
   - 可能需要修改Bundle ID为唯一ID
   - 或确保Apple ID已登录

## 🚀 步骤3：运行应用

### 方法1：在Xcode中运行
- 点击Xcode左上角的运行按钮（▶️）
- 或按 `Cmd+R`

### 方法2：使用Flutter命令
```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter devices
flutter run -d ios
```

## ✅ 步骤4：测试功能

应用安装后，测试：

- [ ] 应用正常启动
- [ ] 标题显示"我的原创内容"
- [ ] 视频列表正常显示
- [ ] 能看到你上传的视频
- [ ] 点击视频能正常播放
- [ ] 横竖屏切换正常
- [ ] 上传功能正常
- [ ] 删除功能正常

## ⚠️ 常见问题

### 问题1：设备未显示
- **解决**：检查USB连接
- 在iPhone上确认"信任此电脑"
- 重启Xcode

### 问题2：签名失败
- **解决**：在Xcode中选择你的Team
- 确保Bundle ID唯一
- 可能需要修改为：`com.yourname.videomusicapp`

### 问题3：应用无法安装
- **解决**：检查iPhone设置 → 通用 → VPN与设备管理
- 信任开发者证书

---

**Xcode已打开，请按照步骤配置签名并运行！**



# 📱 iOS 应用卸载指南

## ❌ 问题
应用无法在 iPhone 上手动卸载。

---

## ✅ 解决方案

### 方法1：在 iPhone 上手动卸载（推荐）

#### 步骤1：检查应用是否被锁定
1. 长按应用图标
2. 如果看到图标抖动，说明可以删除
3. 点击左上角的 **"X"** 删除

#### 步骤2：如果看不到 "X" 按钮
可能原因：
- 应用正在运行
- 应用被锁定（受限制模式）
- 应用是系统应用（不太可能）

**解决方法**：
1. **关闭应用**：
   - 双击 Home 键（或从底部向上滑动）
   - 找到应用，向上滑动关闭

2. **检查限制模式**：
   - 设置 → 屏幕使用时间 → 内容和隐私访问限制
   - 检查是否启用了"不允许删除应用"

3. **重启 iPhone**：
   - 重启后再尝试删除

---

### 方法2：通过 Xcode 卸载（最可靠）

#### 步骤1：打开 Xcode
1. 打开 Xcode
2. 菜单栏：**Window** → **Devices and Simulators**
   - 或按快捷键：`Shift + Cmd + 2`

#### 步骤2：选择设备
1. 在左侧选择你的 iPhone（Dianhua）
2. 确保设备已连接并信任

#### 步骤3：卸载应用
1. 在右侧找到 **"Installed Apps"** 部分
2. 找到应用（可能是 "影音家" 或 "影音播放器"）
3. 点击应用名称
4. 点击下方的 **"-"** 按钮
5. 确认卸载

---

### 方法3：使用命令行卸载

#### 运行卸载脚本
```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
./uninstall_app.sh
```

#### 或手动执行命令
```bash
# 方法1：使用 xcrun devicectl（iOS 17+）
xcrun devicectl device uninstall app \
  --device 00008110-00046D203CEBA01E \
  com.xiaohui.videoMusicApp

# 方法2：使用 ideviceinstaller（需要先安装）
brew install libimobiledevice
ideviceinstaller -u 00008110-00046D203CEBA01E -U com.xiaohui.videoMusicApp
```

---

### 方法4：重新安装覆盖（如果无法卸载）

如果以上方法都不行，可以：
1. **直接重新安装新版本**：
   ```bash
   cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
   flutter run -d Dianhua
   ```
   - 新版本会覆盖旧版本
   - 应用名称会更新为"影音家"

2. **或者先清理再安装**：
   ```bash
   flutter clean
   flutter pub get
   flutter run -d Dianhua
   ```

---

## 🔍 检查应用是否已卸载

### 在 iPhone 上检查
1. 在主屏幕上查找应用图标
2. 在 App Library 中搜索
3. 在设置 → 通用 → iPhone 存储空间中查找

### 通过命令行检查
```bash
xcrun devicectl device list apps --device 00008110-00046D203CEBA01E | grep -i "video\|影音"
```

---

## ⚠️ 常见问题

### 问题1：应用图标还在，但无法打开
**原因**：应用已部分卸载，但图标残留
**解决**：
1. 重启 iPhone
2. 图标会自动消失

### 问题2：Xcode 中看不到应用
**原因**：应用可能不是通过 Xcode 安装的
**解决**：
1. 使用方法1（手动删除）
2. 或使用方法4（重新安装覆盖）

### 问题3：提示"无法删除应用"
**原因**：应用被锁定或正在使用
**解决**：
1. 关闭应用
2. 重启 iPhone
3. 检查限制模式设置

---

## 🎯 推荐流程

1. **首先尝试**：在 iPhone 上长按图标删除
2. **如果不行**：通过 Xcode 卸载（方法2）
3. **如果还不行**：运行卸载脚本（方法3）
4. **最后选择**：重新安装覆盖（方法4）

---

## ✅ 卸载成功后

卸载成功后，可以：
1. 重新编译安装新版本：
   ```bash
   flutter clean
   flutter pub get
   flutter run -d Dianhua
   ```

2. 新版本会显示为 **"影音家"**

---

**如果以上方法都不行，请告诉我具体的错误信息！**




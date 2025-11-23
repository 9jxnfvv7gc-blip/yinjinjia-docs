# macOS应用窗口未显示解决方案

## ❌ 问题描述

运行 `flutter run -d macos` 后，应用没有弹出窗口。

---

## ✅ 解决方案

### 方法1：检查应用是否在运行

#### 在终端中查看输出：

如果看到类似这样的输出，说明应用已经启动：
```
Launching lib/main.dart on macOS in debug mode...
Building macOS application...
```

#### 检查应用进程：

```bash
# 检查是否有应用进程在运行
ps aux | grep -i "video_music_app\|Runner" | grep -v grep
```

---

### 方法2：激活应用窗口

#### 方法2.1：使用 Dock

1. **查看 Dock**（屏幕底部的应用栏）
2. **找到应用图标**（可能是 "Runner" 或应用名称）
3. **点击图标**激活窗口

---

#### 方法2.2：使用 Command+Tab

1. **按住 Command 键**
2. **按 Tab 键**切换应用
3. **找到应用**并释放按键

---

#### 方法2.3：使用 Mission Control

1. **向上滑动**（触控板）或按 **F3** 键
2. **查看所有窗口**
3. **点击应用窗口**

---

#### 方法2.4：使用命令行激活

在终端中执行：

```bash
# 激活应用窗口
osascript -e 'tell application "System Events" to set frontmost of process "Runner" to true'
```

或者：

```bash
# 使用 open 命令
open -a Runner
```

---

### 方法3：检查应用是否真的在运行

#### 查看终端输出：

如果应用正在运行，终端会显示：
- `Flutter run key commands.`
- `r Hot reload. 🔥🔥🔥`
- `R Hot restart.`

如果看到错误信息，请告诉我具体的错误内容。

---

### 方法4：重新运行应用

如果应用没有启动，重新运行：

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
flutter run -d macos
```

**注意**：
- 等待编译完成（可能需要1-2分钟）
- 看到 "Launching..." 后，应用应该会启动

---

### 方法5：检查应用是否在后台

#### 使用 Activity Monitor：

1. **打开 Activity Monitor**（活动监视器）
2. **搜索 "Runner"** 或应用名称
3. **如果看到进程**，说明应用在运行，只是窗口没有显示

---

## 🔍 常见原因

### 1. 应用窗口在屏幕外

**解决方法**：
- 使用 Mission Control 查看所有窗口
- 或者重置窗口位置（关闭并重新打开应用）

---

### 2. 应用窗口被最小化

**解决方法**：
- 在 Dock 中点击应用图标
- 或使用 Command+Tab 切换

---

### 3. 应用启动失败但终端没有显示错误

**解决方法**：
- 检查终端是否有错误信息
- 重新运行 `flutter run -d macos`
- 查看是否有编译错误

---

### 4. 多个显示器导致窗口在另一个屏幕上

**解决方法**：
- 检查所有连接的显示器
- 使用 Mission Control 查看所有窗口

---

## 📝 快速检查清单

1. ✅ **终端是否显示 "Launching..."？**
   - 是 → 应用正在启动，等待几秒
   - 否 → 重新运行 `flutter run -d macos`

2. ✅ **Dock 中是否有应用图标？**
   - 是 → 点击图标激活窗口
   - 否 → 应用可能没有启动

3. ✅ **Command+Tab 中是否能看到应用？**
   - 是 → 切换到应用
   - 否 → 应用可能没有启动

4. ✅ **终端是否有错误信息？**
   - 是 → 告诉我错误内容
   - 否 → 尝试激活窗口的方法

---

## 🎯 推荐操作步骤

### 步骤1：检查终端输出

查看运行 `flutter run -d macos` 后的终端输出：
- 是否显示 "Launching..."？
- 是否有错误信息？
- 是否显示 "Flutter run key commands"？

### 步骤2：尝试激活窗口

1. **查看 Dock**：找到应用图标并点击
2. **使用 Command+Tab**：切换到应用
3. **使用 Mission Control**：查看所有窗口

### 步骤3：如果还是看不到

1. **检查应用进程**：
   ```bash
   ps aux | grep Runner | grep -v grep
   ```

2. **重新运行应用**：
   ```bash
   flutter run -d macos
   ```

3. **告诉我终端显示的内容**

---

## 💡 提示

- **第一次运行**可能需要较长时间编译
- **应用窗口**可能在屏幕外或另一个显示器上
- **Dock 图标**可能显示为 "Runner" 而不是应用名称

---

**请告诉我：**
1. 终端显示了什么内容？
2. Dock 中是否有应用图标？
3. Command+Tab 中是否能看到应用？


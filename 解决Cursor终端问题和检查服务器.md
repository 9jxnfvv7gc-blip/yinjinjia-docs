# 解决Cursor终端问题和检查服务器

## ❌ Cursor终端问题

### 问题1：Agent terminals are read-only

**原因**：Cursor的Agent终端是只读的，用于显示命令执行结果。

**解决方法**：使用系统终端（Terminal.app）而不是Cursor的终端。

---

### 问题2：启动目录不存在

**错误**：`启动目录(cwd)"/Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905/macos"不存在`

**原因**：Cursor尝试在错误的目录启动终端。

**解决方法**：使用系统终端，手动切换到正确目录。

---

## ✅ 推荐解决方案：使用系统终端

### 打开系统终端（Terminal.app）

1. **打开Finder**
2. **应用程序 → 实用工具 → 终端**
3. **或者使用Spotlight搜索**：按 `Command+Space`，输入"终端"

---

## 🔍 检查服务器是否运行

### 方法1：检查进程（最简单）

在系统终端执行：

```bash
ps aux | grep video_server.py | grep -v grep
```

**如果看到进程信息**：
- ✅ 服务器正在运行
- 不需要做什么

**如果没有输出**：
- ❌ 服务器没有运行
- 需要启动服务器

---

### 方法2：测试服务器连接

在系统终端执行：

```bash
curl http://localhost:8081
```

**如果看到HTML内容**：
- ✅ 服务器正在运行

**如果看到 "Connection refused"**：
- ❌ 服务器没有运行

---

## 🚀 如果服务器没有运行

### 启动服务器

在系统终端执行：

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
python3 video_server.py
```

**应该看到**：
```
启动视频服务器...
端口: 8081
视频根目录: /Volumes/Expansion
Serving at port 8081
```

**保持这个终端窗口打开**，不要关闭。

---

## 📋 完整操作流程

### 步骤1：打开系统终端

- 打开 **Terminal.app**（系统终端）

### 步骤2：检查服务器

```bash
# 检查进程
ps aux | grep video_server.py | grep -v grep

# 或者测试连接
curl http://localhost:8081
```

### 步骤3：根据结果操作

- **如果服务器运行**：✅ 直接使用应用
- **如果服务器没有运行**：启动服务器（见上面）

### 步骤4：运行应用（如果需要）

在新的系统终端窗口：

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
flutter run -d macos
```

---

## 💡 关于后台运行（&）

你看到的命令：
```bash
python3 video_server.py &
```

**`&` 表示后台运行**：
- 服务器在后台运行
- 终端可以继续使用
- 但看不到服务器输出

**检查后台进程**：
```bash
ps aux | grep video_server.py | grep -v grep
```

**停止后台进程**（如果需要）：
```bash
# 找到进程ID
ps aux | grep video_server.py | grep -v grep

# 停止进程（替换PID为实际进程ID）
kill PID
```

---

## 🎯 推荐操作

### 1. 使用系统终端（Terminal.app）

**不要使用Cursor的终端**，使用系统终端：
- 更稳定
- 功能完整
- 没有目录问题

### 2. 检查服务器状态

```bash
# 在系统终端执行
ps aux | grep video_server.py | grep -v grep
```

### 3. 如果服务器没有运行

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
python3 video_server.py
```

---

## 📝 快速命令

### 检查服务器：
```bash
ps aux | grep video_server.py | grep -v grep
```

### 测试连接：
```bash
curl http://localhost:8081
```

### 启动服务器：
```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
python3 video_server.py
```

---

## ✅ 总结

1. **不要使用Cursor终端**：使用系统终端（Terminal.app）
2. **检查服务器**：使用 `ps aux | grep video_server.py`
3. **如果没运行**：启动服务器
4. **保持终端打开**：服务器需要一直运行

---

**现在打开系统终端，检查服务器状态！** 🚀


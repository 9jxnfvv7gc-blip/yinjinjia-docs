# Workbench文件管理器详细操作步骤

## 📁 方法1：使用Workbench文件管理器

### 步骤1：打开文件管理器

1. 在阿里云控制台，进入你的服务器
2. 点击 **远程连接** → **Workbench远程连接**
3. 点击顶部的 **文件** 菜单
4. 选择 **打开新文件管理**

---

### 步骤2：导航到目标目录

#### 如果看到地址栏：

1. 在文件管理器顶部找到**地址栏**（显示当前路径的文本框）
2. 点击地址栏，清空当前路径
3. 输入：`/root/video_server`
4. 按回车键

#### 如果看不到地址栏，使用目录树：

1. 在文件管理器**左侧**找到**目录树**（文件夹列表）
2. 依次展开：
   - 点击 **/** 或 **根目录**
   - 找到 `root` 文件夹，点击它
   - 找到 `video_server` 文件夹，点击它

#### 如果都看不到，使用搜索：

1. 在文件管理器中找到**搜索**功能
2. 搜索：`video_server`
3. 应该能找到 `/root/video_server` 目录

---

### 步骤3：上传文件

1. 在 `/root/video_server/` 目录中，点击**上传**按钮（通常在顶部工具栏）
2. 选择本地的 `video_server.py` 文件：
   - 路径：`/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py`
3. 等待上传完成
4. 会提示是否覆盖，选择 **是** 或 **覆盖**

---

## 📁 方法2：使用终端命令（更简单）

### 如果文件管理器无法使用，使用终端：

#### 步骤1：退出nano（如果还在nano中）

按 `Ctrl+X`，然后按 `N`（不保存）

---

#### 步骤2：使用cat命令创建文件

在Workbench终端执行：

```bash
# 先停止服务器
systemctl stop video-server

# 备份原文件
cp /root/video_server/video_server.py /root/video_server/video_server.py.bak3
```

然后我会提供一个命令，让你可以直接复制粘贴文件内容。

---

#### 步骤3：使用scp从Mac上传（如果SSH可用）

在你的Mac终端执行：

```bash
scp "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py" root@47.243.177.166:/root/video_server/
```

---

## 📁 方法3：直接使用cat命令（最简单）

### 在Workbench终端执行：

```bash
# 停止服务器
systemctl stop video-server

# 备份原文件
cp /root/video_server/video_server.py /root/video_server/video_server.py.bak3

# 打开编辑器
nano /root/video_server/video_server.py
```

然后我会提供完整的文件内容，你可以直接替换。

---

## 🎯 推荐操作

**如果文件管理器找不到导航**，使用**方法3**（直接编辑）：
1. 停止服务器
2. 备份文件
3. 打开nano编辑器
4. 我会提供需要修改的内容

---

**告诉我你选择哪种方法，或者告诉我文件管理器中看到了什么！** 📂


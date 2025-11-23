# 上传video_server.py到服务器步骤

## 方法1：使用Workbench文件管理器（推荐）

### 步骤1：打开Workbench文件管理器

1. 登录阿里云控制台
2. 进入 **ECS实例** → 选择你的服务器（IP: 47.243.177.166）
3. 点击 **远程连接** → **Workbench远程连接**
4. 点击顶部的 **文件** 菜单
5. 选择 **打开新文件管理**

---

### 步骤2：导航到目标目录

在文件管理器中：

1. 在地址栏输入：`/root/video_server`
2. 按回车键
3. 应该看到 `video_server.py` 文件

---

### 步骤3：上传文件

1. 点击 **上传** 按钮（通常在顶部工具栏）
2. 选择本地的 `video_server.py` 文件：
   - 路径：`/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py`
3. 等待上传完成
4. 会提示是否覆盖，选择 **是** 或 **覆盖**

---

## 方法2：使用scp命令（如果SSH可用）

### 在你的Mac终端执行：

```bash
# 上传文件到服务器
scp "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/video_server.py" root@47.243.177.166:/root/video_server/
```

**如果SSH密码登录失败**，使用Workbench文件管理器。

---

## 方法3：直接编辑服务器上的文件（最简单）

### 在Workbench终端执行：

1. **备份原文件**：
```bash
cp /root/video_server/video_server.py /root/video_server/video_server.py.bak
```

2. **使用nano编辑器打开文件**：
```bash
nano /root/video_server/video_server.py
```

3. **找到需要修改的位置**（大约第622-680行）

4. **添加调试信息**（我已经在本地文件添加了，你可以直接复制）

5. **保存文件**：
   - 按 `Ctrl+O` 保存
   - 按 `Enter` 确认
   - 按 `Ctrl+X` 退出

---

## 方法4：使用sed命令直接修改（最快）

### 在Workbench终端执行：

```bash
cd /root/video_server

# 备份原文件
cp video_server.py video_server.py.bak

# 添加调试信息（在elif self.path.startswith('/api/list/'):之后）
sed -i '622a\            # 调试信息\n            print(f"API列表请求: category={category}, category_path={category_path}")\n            print(f"VIDEO_ROOT: {VIDEO_ROOT}")\n            print(f"路径存在: {os.path.exists(category_path)}")' video_server.py

# 在if os.path.exists(category_path):之后添加
sed -i '638a\                print(f"目录存在，开始扫描文件...")' video_server.py

# 在for f in os.listdir(category_path):循环中添加
sed -i '642a\                        print(f"文件: {f}, 扩展名: {ext}, 在列表中: {ext in all_media_extensions}")' video_server.py

# 在file_list.append之后添加
sed -i '675a\                print(f"找到 {len(file_list)} 个文件")' video_server.py
```

**注意**：sed命令可能比较复杂，建议使用方法1或方法3。

---

## 推荐操作流程

### 最简单的方法：直接编辑服务器文件

1. **在Workbench终端执行**：
```bash
# 备份原文件
cp /root/video_server/video_server.py /root/video_server/video_server.py.bak

# 打开编辑器
nano /root/video_server/video_server.py
```

2. **找到第622行左右**（`elif self.path.startswith('/api/list/'):`）

3. **在 `category_path = os.path.join(VIDEO_ROOT, category)` 之后添加**：
```python
            # 调试信息
            print(f"API列表请求: category={category}, category_path={category_path}")
            print(f"VIDEO_ROOT: {VIDEO_ROOT}")
            print(f"路径存在: {os.path.exists(category_path)}")
```

4. **在 `if os.path.exists(category_path):` 之后添加**：
```python
                print(f"目录存在，开始扫描文件...")
```

5. **在 `if ext in all_media_extensions:` 之前添加**：
```python
                        print(f"文件: {f}, 扩展名: {ext}, 在列表中: {ext in all_media_extensions}")
```

6. **在 `file_list.append` 循环结束后添加**：
```python
                print(f"找到 {len(file_list)} 个文件")
```

7. **保存并退出**（`Ctrl+O`, `Enter`, `Ctrl+X`）

---

## 🎯 现在可以执行

**推荐使用方法1（Workbench文件管理器）**：
1. 打开Workbench文件管理器
2. 导航到 `/root/video_server/`
3. 上传本地的 `video_server.py` 文件

**或者使用方法3（直接编辑）**：
1. 在Workbench终端执行 `nano /root/video_server/video_server.py`
2. 添加调试信息
3. 保存文件

---

**选择一种方法，告诉我你使用哪种方法！** 📤


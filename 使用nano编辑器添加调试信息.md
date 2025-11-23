# 使用nano编辑器添加调试信息

## 📝 当前状态

你已经打开了nano编辑器，正在编辑 `video_server.py` 文件。

---

## 🎯 操作步骤

### 步骤1：确认你在nano编辑器中

你应该看到：
- 文件内容显示在屏幕上
- 底部有提示：`^G Help  ^O Write Out  ^X Exit` 等

如果看不到内容，可能是终端窗口太小，尝试：
- 滚动查看
- 或者按 `Ctrl+L` 刷新屏幕

---

### 步骤2：找到需要修改的位置

#### 位置1：找到第638行左右

使用 `Ctrl+W` 搜索：`if os.path.exists(category_path):`

找到这一行后，按 `Enter`，然后在这一行下面添加：
```python
                print(f"目录存在，开始扫描文件...")
```

**注意**：缩进要与下面的 `file_list = []` 对齐（16个空格）

---

#### 位置2：找到第644行左右

使用 `Ctrl+W` 搜索：`if ext in all_media_extensions:`

找到这一行后，按 `Enter`，然后在这一行上面添加：
```python
                        print(f"文件: {f}, 扩展名: {ext}, 在列表中: {ext in all_media_extensions}")
```

**注意**：缩进要与上面的 `ext = os.path.splitext(f)[1].lower()` 对齐（24个空格）

---

#### 位置3：找到第676行左右

使用 `Ctrl+W` 搜索：`file_list.append`

找到 `file_list.append` 循环结束的地方（看到 `})` 后），添加：
```python
                print(f"找到 {len(file_list)} 个文件")
```

**注意**：缩进要与 `file_list.append` 对齐（16个空格）

---

### 步骤3：保存文件

- 按 `Ctrl+O` 保存（Write Out）
- 按 `Enter` 确认文件名
- 按 `Ctrl+X` 退出编辑器

---

## 🔧 如果终端没有反应

### 方法1：强制退出nano

1. 按 `Ctrl+X` 退出
2. 如果提示保存，按 `N`（不保存）
3. 然后重新打开：`nano video_server.py`

---

### 方法2：打开新终端

1. 在Workbench中打开新的终端窗口
2. 在新终端中执行命令

---

## 📋 简化操作：只添加一行调试信息

如果添加多行代码有困难，可以先只添加一行：

### 在 `if os.path.exists(category_path):` 下面添加：

```python
                print(f"目录存在，开始扫描文件...")
```

保存后测试，如果能看到这行输出，说明调试信息添加成功。

---

## 🎯 现在可以执行

1. **确认你在nano编辑器中**（应该看到文件内容）
2. **使用 `Ctrl+W` 搜索**：`if os.path.exists(category_path):`
3. **在这一行下面添加**：`print(f"目录存在，开始扫描文件...")`
4. **保存文件**（`Ctrl+O`, `Enter`, `Ctrl+X`）

---

## 💡 提示

- **如果看不到文件内容**，尝试滚动或按 `Ctrl+L` 刷新
- **如果不知道缩进多少**，看上下行的缩进，保持一致
- **如果添加代码有困难**，先只添加一行，测试成功后再添加其他

---

**先确认你在nano编辑器中，然后添加调试信息！** 📝


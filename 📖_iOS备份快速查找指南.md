# iOS 备份快速查找指南

## 🚀 在 Cursor 中快速查找

### 方法一：使用脚本（推荐）

在终端中运行：

```bash
# 查找今天的 iOS 备份
./find_ios_backup.sh

# 查找指定日期的备份（例如：2025年11月30日）
./find_ios_backup.sh 20251130

# 在 Finder 中打开今天的备份
./find_ios_backup.sh open

# 在 Finder 中打开指定日期的备份
./find_ios_backup.sh open 20251130
```

### 方法二：直接说给 Cursor

在 Cursor 中直接说：

- **"帮我找到今天的iOS备份"**
- **"打开今日备份的iOS配置"**
- **"查看iOS设置备份"**
- **"找到2025年11月30日的iOS配置"**

Cursor 会自动找到对应的目录。

### 方法三：使用 Cursor 的文件搜索

1. 按 `Cmd+P` (Mac) 或 `Ctrl+P` (Windows/Linux) 打开快速文件搜索
2. 输入：`今日备份_20251130/iOS配置`
3. 选择要打开的文件

## 📁 目录结构

```
桌面影音播放器_安装包_20251121_165905/
└── 今日备份_YYYYMMDD/          # YYYYMMDD 是日期，如 20251130
    └── iOS配置/
        ├── AppDelegate.swift
        ├── auth_service.dart
        ├── config.dart
        ├── Contents.json
        ├── Info.plist
        └── simple_home_page_safe.dart
```

## 🔍 在 Finder 中查找

### 步骤：

1. 打开 Finder
2. 导航到：`/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/`
3. 找到 `今日备份_YYYYMMDD` 文件夹（例如：`今日备份_20251130`）
4. 打开 `iOS配置` 子文件夹

### 快速路径：

```bash
# 在终端中打开今天的备份
open "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/今日备份_$(date +%Y%m%d)/iOS配置"

# 打开指定日期的备份（例如：2025年11月30日）
open "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/今日备份_20251130/iOS配置"
```

## 📱 iOS 图标位置

### 在 Finder 中：

1. 导航到：`桌面影音播放器_安装包_20251121_165905/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
2. 可以看到所有29个图标文件（.png格式）

### 在 Xcode 中：

1. 打开 `ios/Runner.xcworkspace`
2. 在左侧导航栏找到 `Assets.xcassets`
3. 点击 `AppIcon`
4. 可以看到所有图标的预览

## 📝 可用备份列表

要查看所有可用的备份日期，运行：

```bash
ls -d 今日备份_* | sed 's|今日备份_||' | sort -r
```

## 💡 提示

- 备份文件夹命名格式：`今日备份_YYYYMMDD`
- iOS 配置文件夹始终在备份文件夹内的 `iOS配置` 子目录
- 使用脚本可以快速查找和打开，无需记住完整路径


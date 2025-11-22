# 迁移项目到Expansion移动硬盘的步骤

## 准备工作
1. 等待当前构建完成或取消构建
2. 确保Expansion移动硬盘已连接（/Volumes/Expansion）

## 迁移步骤

### 步骤1：初始化Git仓库（可选但推荐）
```bash
cd /Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905
git init
git add .
git commit -m "初始提交：移动前备份"
```

### 步骤2：创建项目目录
```bash
mkdir -p /Volumes/Expansion/FlutterProjects
```

### 步骤3：移动项目
```bash
# 取消构建（如果还在运行）
# Ctrl+C 或 kill相关进程

# 移动项目
mv "/Users/xiaohuihu/Desktop/桌面影音播放器_安装包_20251121_165905" /Volumes/Expansion/FlutterProjects/
```

### 步骤4：在新的位置打开项目
在Cursor中：
1. File -> Open Folder
2. 选择：/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905

### 步骤5：更新Flutter配置（如果需要）
项目路径改变后，通常不需要特殊配置，但可能需要：
```bash
cd /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905
flutter clean
flutter pub get
```

## 关于Flutter SDK位置
Flutter SDK可以保留在~/development/flutter，不需要移动。
只有项目需要移动到Expansion。


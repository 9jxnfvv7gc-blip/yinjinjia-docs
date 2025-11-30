# Cursor 缓存清理说明

## 🧹 清理脚本

**文件位置**: `清理Cursor缓存.sh`

## 📋 使用方法

### 方法1：在终端运行（推荐）

```bash
cd "/Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905"
./清理Cursor缓存.sh
```

### 方法2：双击运行

1. 在Finder中找到 `清理Cursor缓存.sh`
2. 右键点击 → **"打开方式"** → **"终端"**
3. 如果提示权限问题，在终端运行：
   ```bash
   chmod +x 清理Cursor缓存.sh
   ```

## ⚠️ 注意事项

1. **建议先关闭Cursor** - 清理时最好关闭Cursor应用
2. **不会删除重要数据** - 脚本只清理缓存，不会删除：
   - 你的代码文件
   - 项目设置
   - 扩展配置
   - 用户设置

3. **会清理的内容**：
   - 应用缓存
   - 日志文件
   - 临时文件
   - GPU缓存
   - 着色器缓存
   - （可选）工作区缓存

## 🔧 如果脚本无法运行

如果遇到权限问题，运行：

```bash
chmod +x 清理Cursor缓存.sh
```

## 📝 手动清理（如果脚本不工作）

如果脚本无法运行，可以手动清理：

```bash
# 1. 关闭Cursor

# 2. 清理缓存
rm -rf ~/Library/Caches/Cursor/*
rm -rf ~/Library/Caches/com.todesktop.230313mzl4w4u92/*

# 3. 清理日志
rm -rf ~/Library/Application\ Support/Cursor/logs/*

# 4. 清理临时文件
rm -rf ~/Library/Application\ Support/Cursor/CachedData/*
rm -rf ~/Library/Application\ Support/Cursor/GPUCache/*
rm -rf ~/Library/Application\ Support/Cursor/ShaderCache/*

# 5. 重新启动Cursor
```

## ✅ 清理后

清理完成后：
1. 重新启动Cursor
2. 如果问题仍然存在，可以尝试重启Mac
3. 检查磁盘空间是否充足


# 🔧 iOS 18 冷启动崩溃问题 - 最终修复方案

## 📋 问题确认

**崩溃位置**：`SharedPreferencesPlugin.register(with:)`  
**错误类型**：`EXC_BAD_ACCESS`，`KERN_INVALID_ADDRESS at 0x0000000000000000`  
**根本原因**：`swift_getObjectType` 访问空指针，这是 iOS 18.5 与 `shared_preferences_foundation` 插件的兼容性问题

## ✅ 已实施的修复

### 1. 临时禁用 SharedPreferencesPlugin 注册

**位置**：`ios/Runner/GeneratedPluginRegistrant.m`

```objective-c
// 临时禁用 SharedPreferencesPlugin 注册，避免 iOS 18 冷启动崩溃
// 注意：这会导致 SharedPreferences 功能不可用，但应用可以启动
// [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
```

### 2. Podfile 自动修复机制

**位置**：`ios/Podfile` 的 `post_install` hook

每次执行 `pod install` 后，会自动检查并禁用 `SharedPreferencesPlugin` 注册，确保即使文件被重新生成，修复也会自动应用。

## ⚠️ 功能影响

禁用 `SharedPreferencesPlugin` 后，以下功能会暂时不可用：

- ❌ **用户协议状态保存**：每次启动都会弹出协议弹窗
- ❌ **授权状态保存**：授权状态无法持久化
- ❌ **主题设置保存**：主题设置无法保存
- ❌ **播放历史保存**：播放历史无法保存

但应用可以正常启动和运行其他功能。

## 🔄 长期解决方案

### 方案 1：使用其他存储方案（推荐）

替换 `shared_preferences` 为其他存储方案：

#### 选项 A：使用 `hive`（推荐）
- 高性能键值存储
- 支持复杂数据类型
- iOS 18 兼容性好

#### 选项 B：使用 `sqflite`
- SQLite 数据库
- 功能强大
- 但可能过于复杂

#### 选项 C：使用 `flutter_secure_storage`
- 更安全的存储
- 但可能也有兼容性问题

### 方案 2：等待插件更新

等待 `shared_preferences` 插件作者修复 iOS 18 兼容性问题。

### 方案 3：实现延迟初始化

尝试延迟初始化 SharedPreferences，避免在冷启动时崩溃。

## 📝 当前状态

- ✅ `SharedPreferencesPlugin` 已禁用
- ✅ Podfile 自动修复机制已配置
- ⏳ 等待测试验证

## 🧪 测试步骤

1. 等待应用构建完成并启动
2. 应用启动后，在终端按 `q` 退出（应用会留在手机上）
3. **重启手机** → 解锁
4. 直接点击桌面上的应用图标
5. 验证是否不再闪退

## 📌 如果仍然闪退

请提供最新的崩溃日志：
- 手机：`设置 → 隐私与安全性 → 分析与改进 → 分析数据`
- 找到最新时间的日志
- 把完整内容发给我

---

**最后更新**：2025-11-29  
**修复版本**：v2.0（禁用 SharedPreferencesPlugin）


# ⚠️ 重要提示：不要手动修改 GeneratedPluginRegistrant.m

## 🚨 为什么不能手动修改？

`GeneratedPluginRegistrant.m` 是 Flutter 自动生成的文件。手动修改会导致：

1. **语法错误**：注释掉 `#else` 和 `#endif` 会导致 "Unterminated conditional directive" 错误
2. **构建失败**：应用无法编译
3. **修复被覆盖**：每次 `pod install` 或 `flutter run` 可能会重新生成文件

## ✅ 正确的做法

### 1. 使用 Podfile 自动修复（已配置）

`ios/Podfile` 中的 `post_install` hook 会在每次 `pod install` 后自动禁用有问题的插件：

- `PathProviderPlugin`
- `SharedPreferencesPlugin`

### 2. 如果必须手动修改

**只修改注册部分**，不要修改 import 部分：

```objective-c
// ✅ 正确：只注释注册
// [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];

// ❌ 错误：注释掉 #else 和 #endif
// #else
// #endif
```

## 🔧 当前修复状态

- ✅ `PathProviderPlugin` 已禁用（避免 iOS 18 冷启动崩溃）
- ✅ `SharedPreferencesPlugin` 已禁用（避免 iOS 18 冷启动崩溃）
- ✅ Podfile 自动修复机制已配置

## 📝 如果遇到构建错误

如果看到 "Unterminated conditional directive" 错误：

1. **不要手动修复**：让我来修复
2. **运行**：`cd ios && pod install`（会自动修复）
3. **或者**：告诉我，我会帮你修复

## 🎯 总结

- **不要手动修改** `GeneratedPluginRegistrant.m`
- **使用 Podfile 自动修复**机制
- **如果必须修改**，只修改注册部分，不要修改 import 部分

---

**最后更新**：2025-11-29  
**修复版本**：v3.0（Podfile 自动修复）


import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// 授权管理服务
class AuthService {
  static const String _authKey = 'is_authorized_user';
  static const String _authCodeKey = 'auth_code';
  
  // 默认授权码（生产环境应该从服务器获取或使用更安全的方式）
  static const String _defaultAuthCode = 'YINGYINGJIA2025';

  /// 检查用户是否已授权
  static Future<bool> isAuthorized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_authKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('检查授权状态失败: $e');
      }
      return false;
    }
  }

  /// 验证授权码并设置授权状态
  static Future<bool> verifyAuthCode(String code) async {
    try {
      // 验证授权码（这里使用简单的字符串比较，生产环境应该使用更安全的方式）
      if (code.trim() == _defaultAuthCode) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_authKey, true);
        await prefs.setString(_authCodeKey, code.trim());
        if (kDebugMode) {
          print('✅ 授权成功');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ 授权码错误');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('验证授权码失败: $e');
      }
      return false;
    }
  }

  /// 取消授权
  static Future<void> revokeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, false);
      await prefs.remove(_authCodeKey);
      if (kDebugMode) {
        print('已取消授权');
      }
    } catch (e) {
      if (kDebugMode) {
        print('取消授权失败: $e');
      }
    }
  }

  /// 获取当前授权状态（同步方法，用于快速检查）
  static bool getCachedAuthStatus() {
    // 注意：这是一个同步方法，可能返回过期的状态
    // 应该使用 isAuthorized() 获取最新状态
    return false; // 默认返回 false，强制使用异步方法
  }
}



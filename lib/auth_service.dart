import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 授权管理服务
class AuthService {
  static const String _authKey = 'is_authorized_user';
  static const String _authCodeKey = 'auth_code';
  
  // 默认授权码（生产环境应该从服务器获取或使用更安全的方式）
  static const String _defaultAuthCode = 'yingyinjia2025';
  
  // 使用自定义 MethodChannel 替代 SharedPreferences（避免冷启动崩溃）
  static const MethodChannel _channel = MethodChannel('auth_prefs');

  /// 检查用户是否已授权
  static Future<bool> isAuthorized() async {
    try {
      final result = await _channel.invokeMethod<bool>('getBool', {'key': _authKey});
      return result ?? false;
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
      // 去除所有空白字符（包括空格、换行、制表符等）
      final cleanedCode = code.replaceAll(RegExp(r'\s+'), '');
      
      // 强制输出调试信息（无论是否是 debug 模式）
      print('🔍 验证授权码:');
      print('   原始输入: "$code" (长度=${code.length})');
      print('   清理后: "$cleanedCode" (长度=${cleanedCode.length})');
      print('   期望值: "$_defaultAuthCode" (长度=${_defaultAuthCode.length})');
      print('   直接比较: ${cleanedCode == _defaultAuthCode}');
      print('   不区分大小写: ${cleanedCode.toLowerCase() == _defaultAuthCode.toLowerCase()}');
      
      // 验证授权码（这里使用简单的字符串比较，生产环境应该使用更安全的方式）
      // 也支持不区分大小写的比较（以防万一）
      final isMatch = cleanedCode == _defaultAuthCode || 
                     cleanedCode.toLowerCase() == _defaultAuthCode.toLowerCase();
      
      print('   最终匹配结果: $isMatch');
      
      if (isMatch) {
        // 使用自定义 MethodChannel 保存授权状态
        await _channel.invokeMethod('setBool', {'key': _authKey, 'value': true});
        await _channel.invokeMethod('setString', {'key': _authCodeKey, 'value': cleanedCode});
        print('✅ 授权成功');
        return true;
      } else {
        if (kDebugMode) {
          print('❌ 授权码错误:');
          print('   清理后的输入: "$cleanedCode" (长度=${cleanedCode.length})');
          print('   期望值: "$_defaultAuthCode" (长度=${_defaultAuthCode.length})');
          print('   字符对比:');
          for (int i = 0; i < cleanedCode.length; i++) {
            if (i < _defaultAuthCode.length) {
              print('      [$i]: "${cleanedCode[i]}" (${cleanedCode.codeUnitAt(i)}) vs "${_defaultAuthCode[i]}" (${_defaultAuthCode.codeUnitAt(i)})');
            } else {
              print('      [$i]: "${cleanedCode[i]}" (${cleanedCode.codeUnitAt(i)}) vs (超出范围)');
            }
          }
        }
        return false;
      }
    } catch (e, stackTrace) {
      print('验证授权码失败: $e');
      print('堆栈跟踪: $stackTrace');
      return false;
    }
  }

  /// 取消授权
  static Future<void> revokeAuth() async {
    try {
      await _channel.invokeMethod('setBool', {'key': _authKey, 'value': false});
      await _channel.invokeMethod('remove', {'key': _authCodeKey});
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



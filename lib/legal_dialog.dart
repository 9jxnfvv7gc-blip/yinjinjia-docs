import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'legal_view_page.dart';

/// 首次登录用户协议和隐私政策弹窗
class LegalAgreementDialog extends StatelessWidget {
  const LegalAgreementDialog({super.key});

  /// iOS 上使用原生 UserDefaults，避免依赖有问题的 SharedPreferencesPlugin
  static const MethodChannel _iosChannel = MethodChannel('legal_prefs');

  /// 检查用户是否已同意协议
  static Future<bool> hasAgreed() async {
    // iOS 上优先通过原生 UserDefaults 读取，避免使用有兼容性问题的插件注册
    if (Platform.isIOS) {
      try {
        final result = await _iosChannel.invokeMethod<bool>('getLegalAgreed');
        return result ?? false;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('⚠️ iOS 读取协议状态失败，回退到 SharedPreferences: $e');
          print('📋 堆栈: $stackTrace');
        }
        // 失败时回退到 SharedPreferences 逻辑
      }
    }

    // 其他平台（Android、桌面等）继续使用 SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('legal_agreed') ?? false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('⚠️ SharedPreferences 读取协议状态失败: $e');
        print('📋 堆栈: $stackTrace');
      }
      return false;
    }
  }

  /// 标记用户已同意协议
  static Future<void> setAgreed(bool agreed) async {
    // iOS 上优先通过原生 UserDefaults 写入
    if (Platform.isIOS) {
      try {
        await _iosChannel.invokeMethod('setLegalAgreed', {'value': agreed});
        return;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('⚠️ iOS 写入协议状态失败，回退到 SharedPreferences: $e');
          print('📋 堆栈: $stackTrace');
        }
        // 失败时回退到 SharedPreferences 逻辑
      }
    }

    // 其他平台继续使用 SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('legal_agreed', agreed);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('⚠️ SharedPreferences 写入协议状态失败: $e');
        print('📋 堆栈: $stackTrace');
      }
      // 忽略错误
    }
  }

  /// 打开用户协议（应用内显示）
  static void openTerms(BuildContext context) {
    LegalViewPage.showTerms(context);
  }

  /// 打开隐私政策（应用内显示）
  static void openPrivacy(BuildContext context) {
    LegalViewPage.showPrivacy(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('欢迎使用小船'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '为了更好地保障您的合法权益，请您在使用前仔细阅读并充分理解《用户协议》和《隐私政策》。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    try {
                      // 不关闭弹窗，直接打开协议页面
                      // 使用 Future.microtask 确保在下一个事件循环中执行
                      Future.microtask(() {
                        if (context.mounted) {
                          LegalViewPage.showTerms(context);
                        }
                      });
                    } catch (e, stackTrace) {
                      if (kDebugMode) {
                        print('❌ 打开用户协议失败: $e');
                        print('📋 堆栈: $stackTrace');
                      }
                    }
                  },
                  child: const Text(
                    '《用户协议》',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const Text('和'),
                TextButton(
                  onPressed: () {
                    try {
                      // 不关闭弹窗，直接打开隐私政策页面
                      // 使用 Future.microtask 确保在下一个事件循环中执行
                      Future.microtask(() {
                        if (context.mounted) {
                          LegalViewPage.showPrivacy(context);
                        }
                      });
                    } catch (e, stackTrace) {
                      if (kDebugMode) {
                        print('❌ 打开隐私政策失败: $e');
                        print('📋 堆栈: $stackTrace');
                      }
                    }
                  },
                  child: const Text(
                    '《隐私政策》',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '如果您同意以上内容，请点击"同意并继续"开始使用；若不同意，请点击"退出应用"并停止使用本服务。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 退出应用
            Navigator.of(context).pop(false);
          },
          child: const Text('退出应用'),
        ),
        ElevatedButton(
          onPressed: () async {
            await setAgreed(true);
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: const Text('同意并继续'),
        ),
      ],
    );
  }
}

/// 显示首次登录协议弹窗
Future<bool> showLegalAgreementDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 不允许点击外部关闭
    builder: (context) => const LegalAgreementDialog(),
  );
  return result ?? false;
}


import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

// 条件导入：Web平台使用stub，其他平台使用完整版本
// 注意：video_page.dart 和 music_page.dart 只在备用的 HomePage 中使用
// Android版本使用 SimpleHomePageLinks，不需要这些导入
// import 'video_page.dart' if (dart.library.html) 'video_page_stub.dart';
// import 'music_page.dart' if (dart.library.html) 'music_page_stub.dart';
import 'simple_home_page.dart'; // 简化版界面
import 'simple_home_page_safe.dart'; // 安全版本（带视频播放和上传功能，用于 Google Play）
import 'simple_home_page_links.dart'; // 链接版本（只显示链接，用于国内上架）
import 'legal_dialog.dart'; // 法律协议弹窗

void main() {
  // 设置全局错误处理，防止应用闪退
  _setupErrorHandling();
  
  // 使用 runZonedGuarded 捕获所有异步错误
  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stackTrace) {
      // 捕获所有未处理的错误
      _handleError(error, stackTrace, '未捕获的异步错误');
    },
  );
}

/// 设置全局错误处理
void _setupErrorHandling() {
  // 处理 Flutter 框架错误
  FlutterError.onError = (FlutterErrorDetails details) {
    // 在调试模式下打印到控制台
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
    
    // 记录错误（防止应用闪退）
    _logError(details.exception, details.stack, 'Flutter框架错误');
    
    // 在生产模式下，可以发送错误到错误追踪服务
    if (kReleaseMode) {
      // TODO: 集成错误追踪服务（Sentry, Firebase Crashlytics等）
    }
  };
  
  // 处理平台通道错误（iOS/Android原生代码错误）
  PlatformDispatcher.instance.onError = (error, stack) {
    _handleError(error, stack, '平台通道错误');
    return true; // 表示错误已处理，防止应用闪退
  };
}

/// 处理错误
void _handleError(dynamic error, StackTrace? stackTrace, String context) {
  // 记录错误信息
  _logError(error, stackTrace, context);
  
  // 在调试模式下打印详细信息
  if (kDebugMode) {
    print('❌ [$context] 错误: $error');
    if (stackTrace != null) {
      print('📋 堆栈跟踪:');
      print(stackTrace);
    }
  }
  
  // 在生产模式下，可以发送错误到错误追踪服务（如 Sentry, Firebase Crashlytics）
  // TODO: 集成错误追踪服务
  
  // 重要：不抛出异常，防止应用闪退
  // 错误已经被记录，应用可以继续运行
}

/// 记录错误（可以扩展为发送到服务器或错误追踪服务）
void _logError(dynamic error, StackTrace? stackTrace, String context) {
  // 这里可以添加错误日志记录
  // 例如：写入本地文件、发送到服务器等
  final errorInfo = '''
时间: ${DateTime.now()}
上下文: $context
错误: $error
堆栈: ${stackTrace ?? '无堆栈信息'}
---
''';
  
  // 在调试模式下打印
  if (kDebugMode) {
    print(errorInfo);
  }
  
  // TODO: 在生产模式下，可以：
  // 1. 写入本地日志文件
  // 2. 发送到错误追踪服务（Sentry, Firebase Crashlytics等）
  // 3. 发送到自己的服务器
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小船',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // 使用安全版本的 SimpleHomePage
      home: const _SafeStartupPage(),  // 使用启动屏幕加载安全版本
      // home: const TestSimplePage(),  // 测试用
      // 设置自定义错误页面，防止应用闪退
      builder: (context, widget) {
        Widget errorWidget = widget ?? const SizedBox();
        
        // 如果构建过程中出现错误，显示友好的错误页面
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _ErrorPage(error: details.exception, stackTrace: details.stack);
        };
        
        return errorWidget;
      },
    );
  }
}

/// 安全的启动页面，延迟加载主页面
class _SafeStartupPage extends StatefulWidget {
  const _SafeStartupPage();

  @override
  State<_SafeStartupPage> createState() => _SafeStartupPageState();
}

class _SafeStartupPageState extends State<_SafeStartupPage> {
  bool _isReady = false;
  bool _hasAgreed = false;
  String? _error;
  String? _packageName; // 存储包名，用于判断使用哪个版本

  @override
  void initState() {
    super.initState();
    // 获取包名（用于判断Android版本）
    _getPackageName();
    // 简化初始化：先直接进入主页，延迟显示弹窗
    // 这样可以确保应用不会因为弹窗问题而闪退
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
        // 延迟检查协议，避免阻塞启动
        _checkAndShowDialog();
      }
    });
  }

  /// 获取包名
  Future<void> _getPackageName() async {
    try {
      if (Platform.isAndroid) {
        final packageInfo = await PackageInfo.fromPlatform();
        if (mounted) {
          setState(() {
            _packageName = packageInfo.packageName;
          });
          if (kDebugMode) {
            print('📦 包名: $_packageName');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 获取包名失败: $e');
      }
    }
  }

  /// 检查并显示协议弹窗（分离为独立方法，避免在回调中使用 async）
  Future<void> _checkAndShowDialog() async {
    // 延迟确保界面完全渲染
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;
    
    try {
      // 检查用户是否已同意协议（加强错误处理）
      bool agreed = false;
      try {
        agreed = await LegalAgreementDialog.hasAgreed();
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('⚠️ 检查协议状态失败: $e');
          print('📋 堆栈: $stackTrace');
        }
        // 如果检查失败，假设未同意，避免崩溃
        agreed = false;
      }
      
      if (kDebugMode) {
        print('📋 检查协议状态: agreed=$agreed');
      }
      
      if (!mounted) return;
      
      setState(() {
        _hasAgreed = agreed;
      });
      
      // 如果未同意，显示协议弹窗
      if (!agreed && mounted) {
        if (kDebugMode) {
          print('📋 用户未同意协议，准备显示弹窗');
        }
        
        // 再次延迟，确保界面完全渲染
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        if (kDebugMode) {
          print('📋 开始显示协议弹窗');
        }
        try {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black54, // 确保有遮罩
            builder: (context) {
              if (kDebugMode) {
                print('📋 弹窗 builder 被调用（首次启动）');
              }
              return const LegalAgreementDialog();
            },
          );
          
          if (!mounted) return;
          
          if (kDebugMode) {
            print('📋 协议弹窗返回结果: $result');
          }
          if (result == true) {
            // 用户同意了协议
            await LegalAgreementDialog.setAgreed(true);
            if (mounted) {
              setState(() {
                _hasAgreed = true;
              });
            }
          } else {
            // 用户选择退出应用
            if (Platform.isIOS || Platform.isAndroid) {
              exit(0);
            }
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('❌ 显示协议弹窗失败: $e');
            print('📋 堆栈: $stackTrace');
          }
          // 如果弹窗显示失败，继续使用应用（不退出）
          if (mounted) {
            setState(() {
              _hasAgreed = true;
            });
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ 检查协议状态错误: $e');
        print('📋 堆栈: $stackTrace');
      }
      // 如果检查失败，继续使用应用（不退出）
      if (mounted) {
        setState(() {
          _hasAgreed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorPage(error: _error, stackTrace: null);
    }
    
    // 如果未准备好，显示启动屏幕
    if (!_isReady) {
      return Scaffold(
        backgroundColor: Colors.blue.shade700,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_filled,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                '小船',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    
    // 已准备好，显示主页面（弹窗会在后台显示）
    
    // 主页面已准备好，安全加载
    // 使用更安全的方式构建，避免在构建时抛出异常
    return Builder(
      builder: (context) {
        try {
          // 根据平台和包名选择版本：
          // - iOS：始终使用安全版本（带视频播放和上传功能）
          // - Android Google Play版本（包名包含googleplay）：使用安全版本（完整功能）
          // - Android 中国商店版本（包名包含domestic）：使用链接版本（只转发链接）
          if (Platform.isAndroid) {
            // 根据包名判断使用哪个版本
            if (_packageName != null && _packageName!.contains('googleplay')) {
              // Google Play版本：完整功能（上传视频）
              if (kDebugMode) {
                print('📱 使用Google Play版本（完整功能）');
              }
              return const SimpleHomePageSafe();
            } else {
              // 中国商店版本：链接版本（只转发链接）
              if (kDebugMode) {
                print('📱 使用中国商店版本（链接版本）');
              }
              return const SimpleHomePageLinks();
            }
          } else {
            // iOS 和其他平台使用安全版本（带视频播放和上传功能）
            return const SimpleHomePageSafe();
          }
        } catch (e, stackTrace) {
          // 记录错误
          if (kDebugMode) {
            print('❌ 加载主页面错误: $e');
            print('📋 堆栈跟踪: $stackTrace');
          }
          return _ErrorPage(error: e, stackTrace: stackTrace);
        }
      },
    );
  }
}

// 保留原来的分类界面代码（备用）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade700,
                Colors.purple.shade700,
                Colors.pink.shade700,
              ],
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              '影音播放器',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.video_library),
              text: '视频',
            ),
            Tab(
              icon: Icon(Icons.music_note),
              text: '音乐',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // VideoPage(),  // 已注释：Android版本不需要
          // MusicPage(),  // 已注释：Android版本不需要
          const Center(child: Text('此页面已停用')),
          const Center(child: Text('此页面已停用')),
        ],
      ),
    );
  }
}

/// 自定义错误页面（防止应用闪退）
class _ErrorPage extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;

  const _ErrorPage({
    required this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  '应用遇到了问题',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '错误信息: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // 尝试重新加载应用
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SimpleHomePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新加载'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // 退出应用（仅在必要时使用）
                    if (Platform.isIOS || Platform.isAndroid) {
                      exit(0);
                    }
                  },
                  child: const Text('退出应用'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

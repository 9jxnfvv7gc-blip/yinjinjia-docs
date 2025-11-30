import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'config.dart';
import 'video_player_page.dart';
import 'music_player_page.dart';
import 'models.dart';
import 'legal_dialog.dart';
import 'services/auth_service.dart';

/// 安全的简化主页 - 逐步添加功能，防止闪退
class SimpleHomePageSafe extends StatefulWidget {
  const SimpleHomePageSafe({super.key});

  @override
  State<SimpleHomePageSafe> createState() => _SimpleHomePageSafeState();
}

class _SimpleHomePageSafeState extends State<SimpleHomePageSafe> {
  final Map<String, List<SimpleMediaItem>> _items = {
    'video': [], // 原创视频
    'music': [], // 原创歌曲
  };
  
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;
  String? _loadingStatus; // 加载状态信息（包括重试信息）
  bool _isAuthorized = false; // 是否已授权
  bool _showAllVideos = false;
  bool _showAllMusics = false;

  // 创建自定义 HTTP 客户端（用于 iOS）
  http.Client? _httpClient;
  
  @override
  void initState() {
    super.initState();
    // iOS网络配置：尝试使用默认客户端，让系统自动处理网络
    // 如果自定义客户端有问题，系统默认客户端可能更稳定
    if (Platform.isIOS) {
      // 暂时不使用自定义客户端，使用系统默认的http.Client
      // 这样可以避免自定义配置导致的网络问题
      _httpClient = null; // 使用默认客户端
      
      // 如果需要自定义客户端，可以取消下面的注释
      /*
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 30);
      httpClient.idleTimeout = const Duration(seconds: 30);
      httpClient.badCertificateCallback = (cert, host, port) => true;
      httpClient.userAgent = 'VideoMusicApp/1.0 (iOS)';
      _httpClient = IOClient(httpClient);
      */
    }
    
    // 延迟初始化，确保组件完全初始化
    // 使用 Future.microtask 确保在 build 完成后执行
    Future.microtask(() async {
      try {
        // 先检查用户是否已同意协议，如果未同意，不加载内容
        bool hasAgreed = false;
        try {
          hasAgreed = await LegalAgreementDialog.hasAgreed();
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('⚠️ 检查协议状态失败: $e');
            print('📋 堆栈: $stackTrace');
          }
          // 如果检查失败，假设未同意，避免崩溃
          hasAgreed = false;
        }
        
        if (!hasAgreed) {
          // 未同意协议，不加载内容，等待首次登录弹窗处理
          if (kDebugMode) {
            print('⚠️ 用户未同意协议，跳过内容加载');
          }
          return;
        }
        
        // 检查授权状态
        try {
          _isAuthorized = await AuthService.isAuthorized();
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('⚠️ 检查授权状态失败: $e');
            print('📋 堆栈: $stackTrace');
          }
          // 如果检查失败，假设未授权，避免崩溃
          _isAuthorized = false;
        }
        
        if (mounted) {
          setState(() {});
        }
        
        if (mounted && !kIsWeb) {
          try {
            if (AppConfig.autoConnectServer) {
              _tryLoadContent();
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('❌ SimpleHomePageSafe initState 错误: $e');
              print('📋 堆栈: $stackTrace');
            }
            // 即使出错也不闪退，只显示错误状态
            if (mounted) {
              _safeSetState(() {
                _errorMessage = '初始化失败，请重试';
              });
            }
          }
        }
      } catch (e, stackTrace) {
        // 捕获所有未处理的异常，防止崩溃
        if (kDebugMode) {
          print('❌ SimpleHomePageSafe initState 严重错误: $e');
          print('📋 堆栈: $stackTrace');
        }
        // 即使出错也不闪退，只显示错误状态
        if (mounted) {
          _safeSetState(() {
            _errorMessage = '初始化失败，请重试';
            _isLoading = false;
          });
        }
      }
    });
  }

  /// 安全的 setState 包装
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      try {
        setState(fn);
      } catch (e) {
        if (kDebugMode) {
          print('setState 错误（已忽略）: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _httpClient?.close();
    super.dispose();
  }

  /// 尝试加载内容（带错误捕获）
  Future<void> _tryLoadContent() async {
    if (_isLoading || !mounted) return;

    if (kDebugMode) {
      print('开始加载内容...');
    }
    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingStatus = '正在连接服务器...';
    });

    try {
      // 加载视频
      if (!mounted) return;
      if (kDebugMode) {
        print('正在加载视频...');
      }
      _safeSetState(() {
        _loadingStatus = '正在加载视频...';
      });
      final videos = await _loadVideos();
      if (kDebugMode) {
        print('视频加载完成，数量: ${videos.length}');
      }
      
      // 加载音乐
      if (!mounted) return;
      if (kDebugMode) {
        print('正在加载音乐...');
      }
      _safeSetState(() {
        _loadingStatus = '正在加载音乐...';
      });
      final musics = await _loadMusics();
      if (kDebugMode) {
        print('音乐加载完成，数量: ${musics.length}');
      }

      if (!mounted) return;
      
      // 检查是否成功加载到内容
      final hasContent = videos.isNotEmpty || musics.isNotEmpty;
      
      if (hasContent) {
        // 有真实内容
        _safeSetState(() {
          _items['video'] = videos;
          _items['music'] = musics;
          _isConnected = true;
          _isLoading = false;
          _loadingStatus = null;
        });
        if (kDebugMode) {
          print('✅ 内容加载完成: 视频 ${videos.length} 个, 音乐 ${musics.length} 个');
          if (videos.isNotEmpty) {
            print('📹 视频列表:');
            for (var video in videos) {
              print('  - ${video.title}');
            }
          }
          if (musics.isNotEmpty) {
            print('🎵 音乐列表:');
            for (var music in musics) {
              print('  - ${music.title}');
            }
          }
        }
      } else {
        // 没有内容，显示空状态
        _safeSetState(() {
          _items['video'] = [];
          _items['music'] = [];
          _isConnected = false;
          _isLoading = false;
          _loadingStatus = null;
          _errorMessage = null;
          _showAllVideos = false;
          _showAllMusics = false;
        });
        
        if (kDebugMode) {
          print('当前暂无内容');
        }
        
        // 显示友好的空状态提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('当前暂无内容。您可以点击"刷新内容"按钮重新加载。'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('加载内容失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      if (mounted) {
        // 连接失败时，显示空状态，不显示错误页面
        _safeSetState(() {
          _isConnected = false;
          _isLoading = false;
          _loadingStatus = null;
          _errorMessage = null; // 不显示错误，显示空状态
          // 清空内容，显示空状态
          _items.clear();
          _items['video'] = <SimpleMediaItem>[];
          _items['music'] = <SimpleMediaItem>[];
        });
        
        if (kDebugMode) {
          print('✅ 已切换到空状态模式');
        }
        
        // 显示友好的提示信息（不阻止使用应用）
        if (mounted) {
          String errorMsg = '无法连接到服务器';
          if (e.toString().contains('SocketException') || e.toString().contains('No route to host')) {
            errorMsg = '网络连接失败，请检查网络设置或稍后重试';
          } else if (e.toString().contains('TimeoutException') || e.toString().contains('超时')) {
            errorMsg = '连接超时，请检查网络连接';
          } else if (e.toString().contains('Connection refused')) {
            errorMsg = '服务器拒绝连接，请稍后重试';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$errorMsg\n当前暂无内容。您可以继续使用其他功能。'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: '重试',
                textColor: Colors.white,
                onPressed: _tryLoadContent,
              ),
            ),
          );
        }
      }
    }
  }

  /// 带重试的HTTP请求
  Future<http.Response> _getWithRetry(String url, {int maxRetries = 3, Duration? delay, String? type}) async {
    delay ??= const Duration(seconds: 2);
    // 增加超时时间，iOS设备和移动网络可能需要更长时间
    final timeoutDuration = const Duration(seconds: 30);
    for (int i = 0; i < maxRetries; i++) {
      try {
        // 强制输出调试信息（无论是否是debug模式）
        print('🔍 [${DateTime.now()}] 准备发送HTTP请求: $url');
        print('🔍 使用客户端: ${_httpClient != null ? "自定义IOClient" : "默认http客户端"}');
        print('🔍 超时时间: ${timeoutDuration.inSeconds}秒');
        
        // 先测试基本连接
        try {
          final testUri = Uri.parse(AppConfig.apiBaseUrl);
          print('🔍 测试连接到: ${testUri.host}:${testUri.port}');
          print('🔍 完整URL: $url');
        } catch (e) {
          print('❌ URI解析失败: $e');
        }
        
        // 使用自定义客户端（iOS）或默认客户端
        final client = _httpClient ?? http.Client();
        
        print('🔍 开始发送请求...');
        final response = await client.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json; charset=utf-8',
            'User-Agent': 'VideoMusicApp/1.0 (iOS)',
            'Connection': 'keep-alive',
            'Accept-Charset': 'utf-8',
          },
        ).timeout(timeoutDuration);
        
        print('✅ [${DateTime.now()}] HTTP请求已发送，状态码: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('⚠️ 响应状态码不是200: ${response.statusCode}');
          final bodyPreview = response.body.length > 200 
              ? '${response.body.substring(0, 200)}...' 
              : response.body;
          print('⚠️ 响应体: $bodyPreview');
        } else {
          print('✅ 请求成功！响应长度: ${response.bodyBytes.length} 字节');
        }
        
        if (kDebugMode) {
          print('✅ HTTP请求已发送，状态码: ${response.statusCode}');
          print('✅ 响应头: ${response.headers}');
        }
        
        if (response.statusCode == 200) {
          // 成功时清除重试信息
          if (mounted && _loadingStatus != null && _loadingStatus!.contains('重试')) {
            _safeSetState(() {
              _loadingStatus = type != null ? '正在加载$type...' : '正在加载...';
            });
          }
          return response;
        } else if (i < maxRetries - 1) {
          final retryInfo = '请求失败，正在重试 (${i + 1}/$maxRetries)...';
          if (kDebugMode) {
            print('请求失败，状态码: ${response.statusCode}，$retryInfo');
          }
          if (mounted) {
            _safeSetState(() {
              _loadingStatus = retryInfo;
            });
          }
          await Future.delayed(delay);
        }
      } catch (e, stackTrace) {
        // 强制输出错误信息（无论是否是debug模式）
        print('❌ HTTP 请求异常详情: $e');
        print('❌ 错误类型: ${e.runtimeType}');
        print('❌ 请求URL: $url');
        print('❌ 堆栈跟踪: $stackTrace');
        // 详细错误信息
        if (e.toString().contains('SocketException') || e.toString().contains('No route to host')) {
          print('❌ Socket异常：网络连接失败，请求可能未到达服务器');
          print('   提示：请检查：');
          print('   1. iPhone是否已连接WiFi或移动网络');
          print('   2. iPhone和服务器是否在同一网络');
          print('   3. 服务器防火墙是否允许iPhone的IP访问');
          print('   4. 在Safari中测试：http://47.243.177.166:8081/api/categories');
        } else if (e.toString().contains('TimeoutException') || e.toString().contains('超时')) {
          print('❌ 超时异常：请求超时，可能服务器未响应');
        } else if (e.toString().contains('HandshakeException')) {
          print('❌ 握手异常：SSL/TLS握手失败');
        } else if (e.toString().contains('FormatException')) {
          print('❌ 格式异常：URL格式错误');
        }
        if (i < maxRetries - 1) {
          final retryInfo = '网络异常，正在重试 (${i + 1}/$maxRetries)...';
          if (kDebugMode) {
            print('请求异常: $e，$retryInfo');
          }
          if (mounted) {
            _safeSetState(() {
              _loadingStatus = retryInfo;
            });
          }
          await Future.delayed(delay);
        } else {
          // 最后一次重试失败，抛出详细错误
          if (kDebugMode) {
            print('所有重试失败，最终错误: $e');
          }
          rethrow;
        }
      }
    }
    throw Exception('请求失败，已重试 $maxRetries 次');
  }

  /// 加载视频列表
  Future<List<SimpleMediaItem>> _loadVideos() async {
    try {
      // 使用正确的URL编码
      final url = AppConfig.listVideosUrl('原创视频');
      if (kDebugMode) {
        print('请求视频列表: $url');
      }
      final response = await _getWithRetry(url, type: '视频');

      if (kDebugMode) {
        print('视频列表响应状态: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('解析到 ${data.length} 个视频');
        }
        final videos = data.map((item) {
          final url = item['url'] as String;
          if (kDebugMode) {
            print('原始URL: $url');
          }
          
          // 构建完整URL
          String fullUrl;
          if (url.startsWith('http://') || url.startsWith('https://')) {
            // 已经是完整URL，直接使用
            fullUrl = url;
          } else {
            // 相对路径，需要拼接
            // 确保URL以/开头
            final normalizedUrl = url.startsWith('/') ? url : '/$url';
            fullUrl = '${AppConfig.apiBaseUrl}$normalizedUrl';
          }
          
          if (kDebugMode) {
            print('构建后的完整URL: $fullUrl');
          }
          
          return SimpleMediaItem(
            id: item['id'] ?? fullUrl,
            title: item['title'] as String? ?? '未命名视频',
            url: fullUrl,
            type: 'video',
          );
        }).toList();
        if (kDebugMode) {
          print('成功解析 ${videos.length} 个视频');
        }
        return videos;
      } else {
        if (kDebugMode) {
          print('视频列表请求失败，状态码: ${response.statusCode}');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('加载视频失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
    }
    return [];
  }

  /// 加载音乐列表
  Future<List<SimpleMediaItem>> _loadMusics() async {
    try {
      // 使用正确的URL编码
      final url = AppConfig.listVideosUrl('原创歌曲');
      if (kDebugMode) {
        print('请求音乐列表: $url');
      }
      final response = await _getWithRetry(url, type: '音乐');

      if (kDebugMode) {
        print('音乐列表响应状态: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('解析到 ${data.length} 首歌曲');
        }
        final musics = data.map((item) {
          final url = item['url'] as String;
          if (kDebugMode) {
            print('原始音乐URL: $url');
          }
          
          // 构建完整URL
          String fullUrl;
          if (url.startsWith('http://') || url.startsWith('https://')) {
            // 已经是完整URL，直接使用
            fullUrl = url;
          } else {
            // 相对路径，需要拼接
            // 确保URL以/开头
            final normalizedUrl = url.startsWith('/') ? url : '/$url';
            fullUrl = '${AppConfig.apiBaseUrl}$normalizedUrl';
          }
          
          if (kDebugMode) {
            print('构建后的完整音乐URL: $fullUrl');
          }
          
          return SimpleMediaItem(
            id: item['id'] ?? fullUrl,
            title: item['title'] as String? ?? '未命名音乐',
            url: fullUrl,
            type: 'music',
          );
        }).toList();
        if (kDebugMode) {
          print('成功解析 ${musics.length} 首歌曲');
        }
        return musics;
      } else {
        if (kDebugMode) {
          print('音乐列表请求失败，状态码: ${response.statusCode}');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('加载音乐失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
    }
    return [];
  }

  /// 显示授权对话框
  void _showAuthDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(_isAuthorized ? '授权管理' : '输入授权码'),
          content: _isAuthorized
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text('您已经是授权用户', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        setDialogState(() {
                          isLoading = true;
                        });
                        await AuthService.revokeAuth();
                        final newAuthStatus = await AuthService.isAuthorized();
                        setDialogState(() {
                          isLoading = false;
                          _isAuthorized = newAuthStatus;
                        });
                        if (mounted) {
                          setState(() {
                            _isAuthorized = newAuthStatus;
                          });
                        }
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已取消授权')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('取消授权'),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('请输入授权码以使用上传功能'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: '授权码',
                        hintText: '请输入授权码',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      enabled: !isLoading,
                    ),
                  ],
                ),
          actions: _isAuthorized
              ? [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                          final code = codeController.text.trim();
                          if (code.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入授权码')),
                            );
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                          });

                          final success = await AuthService.verifyAuthCode(code);
                          final newAuthStatus = await AuthService.isAuthorized();

                          setDialogState(() {
                            isLoading = false;
                            _isAuthorized = newAuthStatus;
                          });

                          if (mounted) {
                            setState(() {
                              _isAuthorized = newAuthStatus;
                            });
                          }

                          if (mounted) {
                            Navigator.of(context).pop();

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('授权成功！您现在可以使用上传功能'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              if (kDebugMode) {
                                print('❌ 授权失败，success=false');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('授权码错误\n请检查 Xcode 控制台的调试日志'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('验证'),
                  ),
                ],
        ),
      ),
    );
  }

  /// 显示上传对话框
  void _showUploadDialog(BuildContext context) {
    if (!_isAuthorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('您需要先授权才能使用上传功能')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('上传内容'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.blue),
              title: const Text('上传视频'),
              subtitle: const Text('上传原创视频内容'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                _uploadContent('video');
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.purple),
              title: const Text('上传音乐'),
              subtitle: const Text('上传原创歌曲内容'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                _uploadContent('music');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 显示设置对话框
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text('用户协议'),
              subtitle: const Text('查看用户协议'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (kDebugMode) {
                  print('📄 点击用户协议');
                }
                Navigator.of(context).pop();
                try {
                  LegalAgreementDialog.openTerms(context);
                  if (kDebugMode) {
                    print('✅ 已打开用户协议页面');
                  }
                } catch (e, stackTrace) {
                  if (kDebugMode) {
                    print('❌ 打开用户协议失败: $e');
                    print('堆栈: $stackTrace');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('打开用户协议失败: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.purple),
              title: const Text('隐私政策'),
              subtitle: const Text('查看隐私政策'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (kDebugMode) {
                  print('🔒 点击隐私政策');
                }
                Navigator.of(context).pop();
                try {
                  LegalAgreementDialog.openPrivacy(context);
                  if (kDebugMode) {
                    print('✅ 已打开隐私政策页面');
                  }
                } catch (e, stackTrace) {
                  if (kDebugMode) {
                    print('❌ 打开隐私政策失败: $e');
                    print('堆栈: $stackTrace');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('打开隐私政策失败: $e')),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(_isAuthorized ? Icons.verified_user : Icons.lock_outline, 
                color: _isAuthorized ? Colors.green : Colors.grey),
              title: Text(_isAuthorized ? '已授权用户' : '授权管理'),
              subtitle: Text(_isAuthorized ? '您可以使用上传功能' : '输入授权码以使用上传功能'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                _showAuthDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于'),
              subtitle: const Text('小船 v1.0.0'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 上传内容（视频或音乐）
  Future<void> _uploadContent(String type) async {
    if (!mounted) return;
    
    try {
      if (kDebugMode) {
        print('开始上传流程: $type');
      }
      
      // 根据平台和类型选择文件选择器配置
      FilePickerResult? result;
      
      try {
        if (kIsWeb) {
          // Web平台
          result = await FilePicker.platform.pickFiles(
            type: type == 'video' ? FileType.video : FileType.audio,
            allowMultiple: true,
          );
        } else if (Platform.isIOS) {
          // iOS平台：根据类型选择文件选择器
          if (kDebugMode) {
            print('iOS 文件选择器：类型=$type');
          }
          
          // 先显示提示，告诉用户如何选择文件
          final typeText = type == 'video' ? '视频' : '音乐';
          final formatHint = type == 'video' 
              ? '支持mp4、mov、avi等格式\n提示：可在"文件"应用中查找视频'
              : '支持mp3、m4a、wav等格式\n提示：可在"文件"应用中查找音乐';
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '正在打开文件选择器...\n$formatHint',
                ),
                duration: const Duration(seconds: 4),
                backgroundColor: type == 'video' ? Colors.blue : Colors.purple,
              ),
            );
            // 给一点时间让提示显示
            await Future.delayed(const Duration(milliseconds: 500));
          }
          
          // iOS 上根据类型选择最佳的文件选择器配置
          if (type == 'video') {
            // 视频：优先尝试 FileType.video（iOS原生支持，能直接显示视频）
            try {
              if (kDebugMode) {
                print('iOS 尝试使用 FileType.video');
              }
              result = await FilePicker.platform.pickFiles(
                type: FileType.video,
                allowMultiple: true,
              );
              if (kDebugMode) {
                print('iOS 文件选择器（video）成功');
              }
            } catch (e) {
              if (kDebugMode) {
                print('iOS 文件选择器（video）失败，尝试 custom: $e');
              }
              // 如果 FileType.video 失败，尝试 FileType.custom
              try {
                result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'm4v', 'm4a'],
                  allowMultiple: true,
                );
                if (kDebugMode) {
                  print('iOS 文件选择器（custom）成功');
                }
              } catch (e2) {
                if (kDebugMode) {
                  print('iOS 文件选择器（custom）失败，回退到 any: $e2');
                }
                // 最后回退到 FileType.any
                result = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                  allowMultiple: true,
                );
              }
            }
          } else {
            // 音乐：尝试 FileType.custom，如果失败回退到 FileType.any
            // iOS 上 FileType.audio 可能导致崩溃，所以不使用
            try {
              result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg'],
                allowMultiple: true,
              );
              if (kDebugMode) {
                print('iOS 文件选择器（custom）成功');
              }
            } catch (e) {
              if (kDebugMode) {
                print('iOS 文件选择器（custom）失败，回退到 any: $e');
              }
              // 回退到 FileType.any
              result = await FilePicker.platform.pickFiles(
                type: FileType.any,
                allowMultiple: true,
              );
            }
          }
        } else {
          // Android和其他平台：使用custom类型
          result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: type == 'video' 
                ? ['mp4', 'mov', 'avi', 'mkv', 'm4v', 'wmv', 'flv', 'webm'] 
                : ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg', 'wma', 'opus'],
            allowMultiple: true,
          );
        }
      } catch (pickerError) {
        if (kDebugMode) {
          print('文件选择器错误: $pickerError');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('文件选择器错误: ${pickerError.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (result == null || result.files.isEmpty) {
        // 用户取消了选择
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已取消选择文件'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // 支持批量上传
      final files = result.files;
      final totalFiles = files.length;
      
      if (totalFiles == 0) {
        return;
      }

      // 显示批量上传进度对话框
      if (!mounted) return;
      BuildContext? dialogContext;
      int uploadedCount = 0;
      int failedCount = 0;
      List<String> failedFiles = [];
      StateSetter? dialogSetState;
      
      // 获取类型显示文本
      final typeText = type == 'video' ? '视频' : '音乐';
      final typeIcon = type == 'video' ? Icons.video_library : Icons.music_note;
      final typeColor = type == 'video' ? Colors.blue : Colors.purple;
      
      showDialog(
        context: context,
        barrierDismissible: true, // 允许点击外部关闭
        builder: (context) {
          dialogContext = context;
          return StatefulBuilder(
            builder: (context, setState) {
              dialogSetState = setState;
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(typeIcon, color: typeColor, size: 24),
                    const SizedBox(width: 8),
                    Text('上传$typeText'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      '正在上传$typeText: ${uploadedCount + failedCount} / $totalFiles',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    if (uploadedCount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 4),
                          Text('成功: $uploadedCount', style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                    if (failedCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 20),
                            const SizedBox(width: 4),
                            Text('失败: $failedCount', style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 取消上传（关闭对话框）
                      if (dialogContext != null) {
                        Navigator.of(dialogContext!).pop();
                      }
                    },
                    child: const Text('取消'),
                  ),
                ],
              );
            },
          );
        },
      );

      // 批量上传文件
      for (int i = 0; i < files.length; i++) {
        final pickedFile = files[i];
        final filePath = pickedFile.path;
        
        if (filePath == null) {
          // iOS上可能需要使用bytes（暂时跳过）
          failedCount++;
          failedFiles.add(pickedFile.name);
          if (mounted && dialogSetState != null) {
            try {
              dialogSetState!(() {});
            } catch (_) {}
          }
          continue;
        }
      
        final file = File(filePath);
        
        // 检查文件是否存在
        if (!await file.exists()) {
          failedCount++;
          failedFiles.add(pickedFile.name);
          if (mounted && dialogSetState != null) {
            try {
              dialogSetState!(() {});
            } catch (_) {}
          }
          continue;
        }

        try {
          // 上传文件（添加超时控制）
          final request = http.MultipartRequest(
            'POST',
            Uri.parse(AppConfig.uploadVideoUrl),
          );
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              file.path,
            ),
          );
          request.fields['category'] = type == 'video' ? '原创视频' : '原创歌曲';

          final streamedResponse = await request.send().timeout(
            Duration(seconds: AppConfig.uploadTimeoutSeconds),
            onTimeout: () {
              throw TimeoutException('上传超时，请检查网络连接');
            },
          );

          if (streamedResponse.statusCode == 200) {
            uploadedCount++;
          } else {
            failedCount++;
            failedFiles.add(pickedFile.name);
          }
          
          // 更新进度
          if (mounted && dialogSetState != null) {
            try {
              dialogSetState!(() {});
            } catch (_) {}
          }
        } catch (e) {
          if (kDebugMode) {
            print('上传文件失败: ${pickedFile.name}, 错误: $e');
          }
          failedCount++;
          failedFiles.add(pickedFile.name);
          if (mounted && dialogSetState != null) {
            try {
              dialogSetState!(() {});
            } catch (_) {}
          }
        }
      }
      
      // 关闭进度对话框
      if (mounted && dialogContext != null) {
        try {
          Navigator.of(dialogContext!).pop();
        } catch (_) {}
      }

      // 显示上传结果
      if (mounted) {
        if (uploadedCount > 0) {
          // 重新加载内容
          await _tryLoadContent();
          
          String message = '成功上传 $uploadedCount 个文件';
          if (failedCount > 0) {
            message += '，失败 $failedCount 个';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: failedCount > 0 ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          if (failedCount > 0 && failedFiles.isNotEmpty) {
            // 显示失败的文件列表
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('失败的文件: ${failedFiles.join(", ")}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('所有文件上传失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // 尝试关闭进度对话框（如果存在）
        try {
          Navigator.of(context).pop();
        } catch (_) {}
        
        String errorMessage = '上传失败';
        if (e is TimeoutException || e.toString().contains('Timeout') || e.toString().contains('超时')) {
          errorMessage = '上传超时，请检查网络连接或稍后重试';
        } else if (e.toString().contains('Permission denied') || e.toString().contains('权限')) {
          errorMessage = '没有文件访问权限，请在设置中允许应用访问文件';
        } else if (e.toString().contains('No such file') || e.toString().contains('文件不存在')) {
          errorMessage = '文件不存在或已被删除，请重新选择';
        } else if (e.toString().contains('Connection') || e.toString().contains('连接')) {
          errorMessage = '无法连接到服务器，请检查网络连接';
        } else {
          errorMessage = '上传失败: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// 播放内容
  void _playItem(SimpleMediaItem item) {
    // 创建MediaItem对象（适配播放器页面）
    final mediaItem = MediaItem(
      id: item.id,
      title: item.title,
      filePath: item.url,
      categoryId: item.type == 'video' ? 'video' : 'music',
    );
    
    if (item.type == 'video') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerPage(item: mediaItem),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MusicPlayerPage(item: mediaItem),
        ),
      );
    }
  }

  Future<void> _shareItem(SimpleMediaItem item) async {
    try {
      final shareText = '${item.type == 'video' ? '视频' : '音乐'}：${item.title}\n\n${item.url}';
      await Share.share(
        shareText,
        subject: item.title,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分享失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyLink(SimpleMediaItem item) async {
    try {
      await Clipboard.setData(ClipboardData(text: item.url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('链接已复制到剪贴板'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('复制失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteItem(SimpleMediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.title}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      String filePath = item.url;
      if (filePath.startsWith('http')) {
        try {
          int pathStart = filePath.indexOf('/', filePath.indexOf('://') + 3);
          if (pathStart > 0) {
            int queryStart = filePath.indexOf('?', pathStart);
            int endPos = queryStart > 0 ? queryStart : filePath.length;
            filePath = filePath.substring(pathStart, endPos);
          } else {
            final uri = Uri.parse(filePath);
            filePath = uri.path;
          }
        } catch (e) {
          final uri = Uri.parse(filePath);
          filePath = uri.path;
        }
      }

      final response = await http
          .post(
            Uri.parse(AppConfig.deleteVideoUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'file_path': filePath}),
          )
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      // 确保关闭进度对话框
      if (mounted && dialogContext != null) {
        try {
          Navigator.of(dialogContext!).pop();
        } catch (e) {
          if (kDebugMode) {
            print('关闭对话框失败: $e');
          }
        }
      }

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _tryLoadContent();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('删除成功！'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 确保关闭进度对话框
      if (mounted && dialogContext != null) {
        try {
          Navigator.of(dialogContext!).pop();
        } catch (e) {
          if (kDebugMode) {
            print('关闭对话框失败: $e');
          }
        }
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showItemMenu(SimpleMediaItem item) {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('分享链接'),
              subtitle: const Text('通过其他应用分享'),
              onTap: () {
                Navigator.pop(context);
                _shareItem(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.green),
              title: const Text('复制链接'),
              subtitle: const Text('复制到剪贴板'),
              onTap: () {
                Navigator.pop(context);
                _copyLink(item);
              },
            ),
            if (_isAuthorized) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除'),
                subtitle: const Text('删除此内容'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteItem(item);
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 确定要显示的视频和音乐列表
    final displayVideos = _items['video'] ?? [];
    final displayMusics = _items['music'] ?? [];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('小船'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          // 上传按钮（仅授权用户可见）
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              onPressed: () => _showUploadDialog(context),
              tooltip: '上传内容',
            ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              if (kDebugMode) {
                print('⚙️ 点击设置按钮');
              }
              _showSettingsDialog(context);
            },
            tooltip: '设置',
          ),
        ],
      ),
      body: _isLoading
          ? SafeArea(
              top: true,
              bottom: true,
              child: _LoadingSection(status: _loadingStatus),
            )
          : _errorMessage != null
              ? SafeArea(
                  top: true,
                  bottom: true,
                  child: _ErrorSection(
                    message: _errorMessage!,
                    onRetry: _tryLoadContent,
                  ),
                )
              : _ContentSection(
                  videos: displayVideos,
                  musics: displayMusics,
                  onRefresh: _tryLoadContent,
                  onPlayItem: _playItem,
                  onShowMenu: _showItemMenu,
                  isConnected: _isConnected,
                  errorMessage: _errorMessage,
                  enableActions: true,
                  showAllVideos: _showAllVideos,
                  showAllMusics: _showAllMusics,
                  onToggleVideos: (expand) {
                    _safeSetState(() {
                      _showAllVideos = expand;
                    });
                  },
                  onToggleMusics: (expand) {
                    _safeSetState(() {
                      _showAllMusics = expand;
                    });
                  },
                ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  final String? status;
  const _LoadingSection({this.status});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(status ?? '正在加载...'),
        ],
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorSection({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  final List<SimpleMediaItem> videos;
  final List<SimpleMediaItem> musics;
  final Future<void> Function() onRefresh;
  final void Function(SimpleMediaItem) onPlayItem;
  final void Function(SimpleMediaItem) onShowMenu;
  final bool isConnected;
  final String? errorMessage;
  final bool enableActions;
  final bool showAllVideos;
  final bool showAllMusics;
  final void Function(bool expand)? onToggleVideos;
  final void Function(bool expand)? onToggleMusics;

  const _ContentSection({
    required this.videos,
    required this.musics,
    required this.onRefresh,
    required this.onPlayItem,
    required this.onShowMenu,
    required this.isConnected,
    this.errorMessage,
    this.enableActions = true,
    this.showAllVideos = false,
    this.showAllMusics = false,
    this.onToggleVideos,
    this.onToggleMusics,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
              _HeroCard(
                onRefresh: onRefresh,
                isConnected: isConnected,
                videoCount: videos.length,
                musicCount: musics.length,
              ),
              const SizedBox(height: 24),
              // 调试信息（仅在开发模式显示）
              if (kDebugMode && videos.isEmpty && musics.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '调试信息',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                      ),
                      const SizedBox(height: 8),
                      Text('videos.length: ${videos.length}'),
                      Text('musics.length: ${musics.length}'),
                      if (videos.isNotEmpty) Text('第一个视频：${videos.first.title}'),
                      if (musics.isNotEmpty) Text('第一首音乐：${musics.first.title}'),
                    ],
                  ),
                ),
              if (videos.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      showAllVideos ? Icons.folder_open : Icons.folder,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                      Text(
                      showAllVideos
                          ? '全部视频 (${videos.length})'
                          : videos.length > 5
                              ? '最新视频'
                              : '视频 (${videos.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      const Spacer(),
                      if (videos.length > 5 && !showAllVideos)
                        TextButton.icon(
                          onPressed: () => onToggleVideos?.call(true),
                          icon: const Icon(Icons.expand_more, size: 20),
                          label: const Text('查看全部'),
                          style: TextButton.styleFrom(foregroundColor: Colors.blue),
                        ),
                      if (videos.length > 5 && showAllVideos)
                      TextButton.icon(
                        onPressed: () => onToggleVideos?.call(false),
                        icon: const Icon(Icons.expand_less, size: 20),
                        label: const Text('收起'),
                        style: TextButton.styleFrom(foregroundColor: Colors.blue),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._buildMediaList(
                  items: videos,
                  showAll: showAllVideos || videos.length <= 5,
                  onPlayItem: onPlayItem,
                  onShowMenu: onShowMenu,
                  enableActions: enableActions,
                  isVideo: true,
                ),
              ],
              if (musics.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(
                      showAllMusics ? Icons.folder_open : Icons.folder,
                      color: Colors.purple.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      showAllMusics
                              ? '全部音乐 (${musics.length})'
                              : musics.length > 5
                                  ? '最新音乐'
                                  : '音乐 (${musics.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (musics.length > 5 && !showAllMusics)
                      TextButton.icon(
                        onPressed: () => onToggleMusics?.call(true),
                        icon: const Icon(Icons.expand_more, size: 20),
                        label: const Text('查看全部'),
                        style: TextButton.styleFrom(foregroundColor: Colors.purple),
                      ),
                    if (musics.length > 5 && showAllMusics)
                      TextButton.icon(
                        onPressed: () => onToggleMusics?.call(false),
                        icon: const Icon(Icons.expand_less, size: 20),
                        label: const Text('收起'),
                        style: TextButton.styleFrom(foregroundColor: Colors.purple),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._buildMediaList(
                  items: musics,
                  showAll: showAllMusics || musics.length <= 5,
                  onPlayItem: onPlayItem,
                  onShowMenu: onShowMenu,
                  enableActions: enableActions,
                  isVideo: false,
                ),
              ],
              // 空状态提示
              if (videos.isEmpty && musics.isEmpty) ...[
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        isConnected ? Icons.inbox_outlined : Icons.cloud_off_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isConnected 
                            ? '当前暂无内容' 
                            : '无法连接到服务器',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      if (!isConnected) ...[
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            '请检查网络连接，确保已连接WiFi或移动网络',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('刷新内容'),
                      ),
                    ],
                  ),
                ),
              ],
              // 确保有足够的内容可以滚动
              const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildMediaList({
    required List<SimpleMediaItem> items,
    required bool showAll,
    required void Function(SimpleMediaItem) onPlayItem,
    required void Function(SimpleMediaItem) onShowMenu,
    required bool enableActions,
    required bool isVideo,
  }) {
    final displayItems = showAll ? items : items.take(5).toList();

    return displayItems
        .map(
          (item) => _MediaCard(
            icon: isVideo ? Icons.play_circle_fill : Icons.library_music,
            title: item.title,
            subtitle: '点击播放',
            onTap: () => onPlayItem(item),
            onMenuTap: enableActions ? () => onShowMenu(item) : null,
          ),
        )
        .toList();
  }
}

class _HeroCard extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final bool isConnected;
  final int videoCount;
  final int musicCount;
  const _HeroCard({
    required this.onRefresh,
    required this.isConnected,
    required this.videoCount,
    required this.musicCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '小船',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isConnected
                ? '已连接服务器 · 视频 $videoCount 个 · 音乐 $musicCount 首'
                : videoCount == 0 && musicCount == 0
                    ? '当前暂无内容'
                    : '正在连接服务器...',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('刷新内容'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            '$title ($count)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const _MediaCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onMenuTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.blue.shade100, // 添加点击反馈
          highlightColor: Colors.blue.shade50, // 添加高亮反馈
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // 增加触摸区域
            constraints: const BoxConstraints(minHeight: 64), // 确保最小触摸区域
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(icon, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onMenuTap != null)
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: onMenuTap,
                  )
                else
                  const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


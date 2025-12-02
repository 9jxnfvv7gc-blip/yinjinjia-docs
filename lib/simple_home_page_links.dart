import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';
// 链接版本：如果URL是视频文件，可以使用播放器直接播放（无广告）
import 'video_player_page.dart';
import 'music_player_page.dart';
import 'models.dart';
import 'legal_dialog.dart';
// Android版本：不需要授权服务（只读模式）

/// 链接版本主页 - Android版本（用于国内上架）
/// 只显示链接，点击链接跳转到外部浏览器，不包含上传、添加、删除功能
class SimpleHomePageLinks extends StatefulWidget {
  const SimpleHomePageLinks({super.key});

  @override
  State<SimpleHomePageLinks> createState() => _SimpleHomePageLinksState();
}

class _SimpleHomePageLinksState extends State<SimpleHomePageLinks> {
  final Map<String, List<SimpleMediaItem>> _items = {
    'video': [], // 原创视频
    'music': [], // 原创歌曲
  };
  
  // 示例链接内容（当无法连接服务器时显示）
  final List<SimpleMediaItem> _sampleVideos = [
    const SimpleMediaItem(
      id: 'sample_link_1',
      title: '精选内容 · 示例链接一',
      url: 'https://example.com/link1',
      type: 'video',
    ),
    const SimpleMediaItem(
      id: 'sample_link_2',
      title: '精选内容 · 示例链接二',
      url: 'https://example.com/link2',
      type: 'video',
    ),
    const SimpleMediaItem(
      id: 'sample_link_3',
      title: '精选内容 · 示例链接三',
      url: 'https://example.com/link3',
      type: 'video',
    ),
  ];
  
  final List<SimpleMediaItem> _sampleMusics = [
    const SimpleMediaItem(
      id: 'sample_link_4',
      title: '精选内容 · 示例链接四',
      url: 'https://example.com/link4',
      type: 'music',
    ),
    const SimpleMediaItem(
      id: 'sample_link_5',
      title: '精选内容 · 示例链接五',
      url: 'https://example.com/link5',
      type: 'music',
    ),
    const SimpleMediaItem(
      id: 'sample_link_6',
      title: '精选内容 · 示例链接六',
      url: 'https://example.com/link6',
      type: 'music',
    ),
  ];
  
  bool _isLoading = false;
  bool _isConnected = false;
  bool _showSampleContent = false; // 是否显示示例内容
  String? _errorMessage;
  String? _loadingStatus; // 加载状态信息（包括重试信息）
  // Android版本：不需要授权状态（只读模式）
  bool _showAllVideos = false;
  bool _showAllMusics = false;

  @override
  void initState() {
    super.initState();
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
        
        // Android版本：不需要检查授权状态（只读模式）
        
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
          _showSampleContent = false; // 有真实内容时，不显示示例内容
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
        // 没有内容，可能是连接失败，显示示例内容
        _safeSetState(() {
          _items['video'] = [];
          _items['music'] = [];
          _isConnected = false;
          _isLoading = false;
          _loadingStatus = null;
          _errorMessage = null;
          _showSampleContent = true; // 显示示例内容
          _showAllVideos = false;
          _showAllMusics = false;
        });
        
        if (kDebugMode) {
          print('无法连接到服务器，显示示例内容');
        }
        
        // 显示友好的提示信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('无法连接到服务器，显示示例内容。您可以继续使用其他功能。'),
              duration: const Duration(seconds: 4),
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('加载内容失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      if (mounted) {
        // 连接失败时，使用示例内容，不显示错误页面
        // 这样用户至少可以看到应用界面和功能
        _safeSetState(() {
          _isConnected = false;
          _isLoading = false;
          _loadingStatus = null;
          _errorMessage = null; // 不显示错误，使用示例内容
          _showSampleContent = true; // 显示示例内容
          // 清空真实内容，确保显示示例内容
          _items.clear();
          _items['video'] = <SimpleMediaItem>[];
          _items['music'] = <SimpleMediaItem>[];
        });
        
        if (kDebugMode) {
          print('✅ 已切换到示例内容模式');
        }
        
        // 显示友好的提示信息（不阻止使用应用）
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('无法连接到服务器，显示示例内容。您可以继续使用其他功能。'),
              duration: const Duration(seconds: 4),
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
    // 增加超时时间，iOS设备可能需要更长时间
    final timeoutDuration = const Duration(seconds: 15);
    for (int i = 0; i < maxRetries; i++) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(timeoutDuration);
        
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
      } catch (e) {
        if (kDebugMode) {
          print('HTTP 请求异常详情: $e');
          print('错误类型: ${e.runtimeType}');
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
      // 国内版使用链接服务器（8082端口）
      final categoryId = Uri.encodeComponent('video'); // 链接服务器使用 'video' 作为分类ID
      final url = '${AppConfig.beijingLinkApiUrl}/api/list/$categoryId';
      if (kDebugMode) {
        print('请求视频列表（链接服务器）: $url');
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
      // 国内版使用链接服务器（8082端口）
      final categoryId = Uri.encodeComponent('music'); // 链接服务器使用 'music' 作为分类ID
      final url = '${AppConfig.beijingLinkApiUrl}/api/list/$categoryId';
      if (kDebugMode) {
        print('请求音乐列表（链接服务器）: $url');
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

  // Android版本：移除授权对话框功能（不再需要）

  // Android版本：移除添加链接功能（只读模式，只显示链接）

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
              leading: const Icon(Icons.info_outline, color: Colors.green),
              title: const Text('关于'),
              subtitle: const Text('查看备案信息'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (kDebugMode) {
                  print('ℹ️ 点击关于');
                }
                Navigator.of(context).pop();
                _showAboutDialog(context);
              },
            ),
            // Android版本：移除授权管理功能（不再需要添加链接）
            const Divider(),
            // 测试功能：清除同意状态（仅调试模式）
            if (kDebugMode)
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.orange),
                title: const Text('清除同意状态（测试）'),
                subtitle: const Text('清除后立即显示首次登录弹窗'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.of(context).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('清除同意状态'),
                      content: const Text('确定要清除同意状态吗？清除后下次启动应用会显示首次登录弹窗。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('取消'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await LegalAgreementDialog.setAgreed(false);
                    if (mounted) {
                      if (kDebugMode) {
                        print('✅ 已清除同意状态，准备显示弹窗');
                      }
                      // 延迟一下，确保设置对话框完全关闭
                      await Future.delayed(const Duration(milliseconds: 300));
                      
                      if (!mounted) return;
                      
                      if (kDebugMode) {
                        print('📋 开始显示协议弹窗');
                      }
                      
                      // 立即显示弹窗
                      try {
                        final result = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.black54,
                          builder: (context) {
                            if (kDebugMode) {
                              print('📋 弹窗 builder 被调用');
                            }
                            return const LegalAgreementDialog();
                          },
                        );
                        
                        if (kDebugMode) {
                          print('📋 弹窗返回结果: $result');
                        }
                        
                        if (mounted) {
                          if (result == true) {
                            // 用户同意了协议
                            await LegalAgreementDialog.setAgreed(true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已同意协议'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            // 用户选择退出应用
                            if (Platform.isIOS || Platform.isAndroid) {
                              exit(0);
                            }
                          }
                        }
                      } catch (e, stackTrace) {
                        if (kDebugMode) {
                          print('❌ 显示弹窗失败: $e');
                          print('📋 堆栈: $stackTrace');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('显示弹窗失败: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            if (kDebugMode)
              const Divider(),
            // 测试功能：直接显示弹窗（仅调试模式）
            if (kDebugMode)
              ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.purple),
                title: const Text('测试弹窗显示'),
                subtitle: const Text('直接显示协议弹窗（用于测试）'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.of(context).pop();
                  if (kDebugMode) {
                    print('🧪 测试：直接显示弹窗');
                  }
                  try {
                    final result = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.black54,
                      builder: (context) {
                        if (kDebugMode) {
                          print('🧪 测试弹窗 builder 被调用');
                        }
                        return const LegalAgreementDialog();
                      },
                    );
                    if (kDebugMode) {
                      print('🧪 测试弹窗返回结果: $result');
                    }
                    if (result == true && mounted) {
                      await LegalAgreementDialog.setAgreed(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已同意协议'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e, stackTrace) {
                    if (kDebugMode) {
                      print('❌ 测试弹窗失败: $e');
                      print('📋 堆栈: $stackTrace');
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('弹窗显示失败: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
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

  /// 打开链接（Android版本：跳转到外部浏览器）
  Future<void> _playItem(SimpleMediaItem item) async {
    if (item.url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('链接地址为空'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(item.url);
      if (await canLaunchUrl(uri)) {
        // Android版本：使用外部浏览器打开链接
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // 在外部浏览器中打开
        );
        if (kDebugMode) {
          print('✅ 已打开链接: ${item.url}');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法打开链接: ${item.url}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 打开链接失败: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('打开链接失败: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _shareItem(SimpleMediaItem item) async {
    if (_showSampleContent) return;
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
    if (_showSampleContent) return;
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

  // Android版本：移除删除功能（只读模式）

  /// 显示关于/备案信息对话框
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('关于小船'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '小船',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('版本：1.0.0'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                '备案信息',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('开发者：智慧令爱'),
              const SizedBox(height: 8),
              const Text('联系方式：zhihuilingai4@outlook.com'),
              const SizedBox(height: 16),
              const Text(
                '软件包名：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('com.xiaohui.videomusicapp.domestic'),
              const SizedBox(height: 16),
              const Text(
                '备案说明：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                '本应用已按照相关法律法规要求进行备案。'
                '如需了解更多信息，请联系开发者。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
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

  void _showItemMenu(SimpleMediaItem item) {
    if (_showSampleContent) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('示例内容无法操作'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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
            // Android版本：移除删除功能（只读模式）
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 确定要显示的视频和音乐列表
    final displayVideos = _showSampleContent
        ? _sampleVideos
        : (_items['video'] ?? []);
    final displayMusics = _showSampleContent
        ? _sampleMusics
        : (_items['music'] ?? []);
    
    // 调试信息（仅在需要时启用）
    // if (kDebugMode) {
    //   print('🎨 build 方法调用: _showSampleContent=$_showSampleContent');
    //   print('📹 显示视频数量: ${displayVideos.length}');
    //   print('🎵 显示音乐数量: ${displayMusics.length}');
    // }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('小船'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          // Android版本：只保留设置按钮，移除添加链接功能
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
                  showSampleContent: _showSampleContent,
                  enableActions: !_showSampleContent,
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
  final bool showSampleContent;
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
    this.showSampleContent = false,
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroCard(
                onRefresh: onRefresh,
                isConnected: isConnected,
                videoCount: videos.length,
                musicCount: musics.length,
                showSampleContent: showSampleContent,
              ),
              const SizedBox(height: 24),
              // 调试信息（仅在开发模式显示）
              if (kDebugMode && videos.isEmpty && musics.isEmpty && !showSampleContent)
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
                      Text('showSampleContent: $showSampleContent'),
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
                      showSampleContent
                          ? '精选链接 (${videos.length})'
                          : showAllVideos
                              ? '全部链接 (${videos.length})'
                              : videos.length > 5
                                  ? '最新链接'
                                  : '链接 (${videos.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!showSampleContent && videos.length > 5 && !showAllVideos)
                      TextButton.icon(
                        onPressed: () => onToggleVideos?.call(true),
                        icon: const Icon(Icons.expand_more, size: 20),
                        label: const Text('查看全部'),
                        style: TextButton.styleFrom(foregroundColor: Colors.blue),
                      ),
                    if (!showSampleContent && videos.length > 5 && showAllVideos)
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
                  showAll: showSampleContent || showAllVideos || videos.length <= 5,
                  onPlayItem: onPlayItem,
                  onShowMenu: onShowMenu,
                  enableActions: enableActions && !showSampleContent,
                  isVideo: true,
                  showSample: showSampleContent,
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
                      showSampleContent
                          ? '精选链接 (${musics.length})'
                          : showAllMusics
                              ? '全部链接 (${musics.length})'
                              : musics.length > 5
                                  ? '最新链接'
                                  : '链接 (${musics.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!showSampleContent && musics.length > 5 && !showAllMusics)
                      TextButton.icon(
                        onPressed: () => onToggleMusics?.call(true),
                        icon: const Icon(Icons.expand_more, size: 20),
                        label: const Text('查看全部'),
                        style: TextButton.styleFrom(foregroundColor: Colors.purple),
                      ),
                    if (!showSampleContent && musics.length > 5 && showAllMusics)
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
                  showAll: showSampleContent || showAllMusics || musics.length <= 5,
                  onPlayItem: onPlayItem,
                  onShowMenu: onShowMenu,
                  enableActions: enableActions && !showSampleContent,
                  isVideo: false,
                  showSample: showSampleContent,
                ),
              ],
              // 如果显示示例内容，不显示空状态提示
              if (videos.isEmpty && musics.isEmpty && !showSampleContent) ...[
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
                        isConnected ? '暂无内容' : '无法连接到服务器',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试连接'),
                      ),
                    ],
                  ),
                ),
              ],
              // 确保有足够的内容可以滚动
              SizedBox(height: 200), // 固定高度，避免使用 MediaQuery 导致编译错误
            ],
          ),
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
    required bool showSample,
  }) {
    final displayItems = showAll ? items : items.take(5).toList();
    final sampleSubtitle =
        showSample 
            ? (isVideo ? '示例链接（服务器连接失败）' : '示例链接（服务器连接失败）') 
            : '点击跳转到外部浏览器';

    return displayItems
        .map(
          (item) => _MediaCard(
            icon: isVideo ? Icons.link : Icons.link,
            title: item.title,
            subtitle: sampleSubtitle,
            onTap: showSample 
                ? null 
                : () {
                    // Android版本：点击链接跳转到外部浏览器
                    onPlayItem(item);
                  },
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
  final bool showSampleContent;
  const _HeroCard({
    required this.onRefresh,
    required this.isConnected,
    required this.videoCount,
    required this.musicCount,
    this.showSampleContent = false,
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
            showSampleContent
                ? '示例链接模式 · 无法连接到服务器'
                : isConnected
                    ? '已连接服务器 · 链接 $videoCount 个 · 链接 $musicCount 个'
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
          onTap: onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title 功能开发中')),
                );
              },
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


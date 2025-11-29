import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import 'models.dart';

class VideoPlayerPage extends StatefulWidget {
  final MediaItem item;

  const VideoPlayerPage({super.key, required this.item});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final path = widget.item.filePath;
    
    debugPrint('视频播放器初始化，路径: $path');
    
    // 判断是 URL 还是本地路径
    if (path.startsWith('http://') || path.startsWith('https://')) {
      // 网络 URL - 先对路径中可能的中文或特殊字符做编码
      final encodedUrl = _encodeUrl(path);
      debugPrint('使用网络URL播放: $encodedUrl');
      
      // 创建VideoPlayerController，添加HTTP头以支持Range请求
      // ExoPlayer需要完整的HTTP头配置，特别是User-Agent
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(encodedUrl),
        httpHeaders: {
          'Accept': '*/*',
          'Accept-Ranges': 'bytes',
          'Connection': 'keep-alive',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
          'Cache-Control': 'no-cache',
        },
      );
    } else {
      // 本地文件路径
      debugPrint('使用本地文件播放: $path');
      _controller = VideoPlayerController.file(File(path));
    }
    
    _controller.initialize().then((_) {
      debugPrint('✅ 视频初始化成功');
      debugPrint('视频信息:');
      debugPrint('  - 时长: ${_controller.value.duration}');
      debugPrint('  - 尺寸: ${_controller.value.size}');
      debugPrint('  - 宽高比: ${_controller.value.aspectRatio}');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        debugPrint('开始播放视频');
      }
    }).catchError((error, stackTrace) {
      debugPrint('❌ 视频初始化失败');
      debugPrint('错误详情: $error');
      debugPrint('错误类型: ${error.runtimeType}');
      debugPrint('原始路径: $path');
      debugPrint('错误堆栈: $stackTrace');
      
      // 如果是网络URL，测试是否可以访问
      if (path.startsWith('http://') || path.startsWith('https://')) {
        final encodedUrl = _encodeUrl(path);
        debugPrint('编码后的URL: $encodedUrl');
        debugPrint('尝试测试URL可访问性...');
        _testUrlAccess(encodedUrl);
        
        // 额外测试：尝试下载视频前1KB
        _testVideoDownload(encodedUrl);
      }
      
      if (mounted) {
        String errorDetail = '视频加载失败\n\n';
        errorDetail += '错误: $error\n';
        errorDetail += '路径: $path\n';
        if (path.startsWith('http')) {
          errorDetail += '\n提示: 请检查网络连接和服务器状态';
        }
        setState(() {
          _errorMessage = errorDetail;
        });
      }
    });
    
    // 监听播放器状态变化
    _controller.addListener(() {
      if (_controller.value.hasError) {
        debugPrint('播放器错误: ${_controller.value.errorDescription}');
        if (mounted) {
          setState(() {
            _errorMessage = '播放错误: ${_controller.value.errorDescription}\n\n路径: $path';
          });
        }
      }
    });
  }

  /// 测试URL是否可以访问
  Future<void> _testUrlAccess(String url) async {
    try {
      debugPrint('🔍 测试URL访问: $url');
      final uri = Uri.parse(url);
      debugPrint('解析后的URI:');
      debugPrint('  - Scheme: ${uri.scheme}');
      debugPrint('  - Host: ${uri.host}');
      debugPrint('  - Port: ${uri.port}');
      debugPrint('  - Path: ${uri.path}');
      debugPrint('  - Query: ${uri.query}');
      
      final response = await http.head(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('URL访问超时');
        },
      );
      
      debugPrint('📊 URL测试结果:');
      debugPrint('  - 状态码: ${response.statusCode}');
      debugPrint('  - Content-Type: ${response.headers['content-type']}');
      debugPrint('  - Content-Length: ${response.headers['content-length']}');
      debugPrint('  - Accept-Ranges: ${response.headers['accept-ranges']}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ URL可访问');
      } else if (response.statusCode == 404) {
        debugPrint('❌ 文件未找到 (404)');
        debugPrint('   请检查服务器上的文件路径是否正确');
      } else if (response.statusCode == 403) {
        debugPrint('❌ 访问被拒绝 (403)');
        debugPrint('   请检查服务器权限配置');
      } else {
        debugPrint('⚠️ URL返回错误状态码: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ URL测试失败: $e');
      debugPrint('错误类型: ${e.runtimeType}');
      if (e is TimeoutException) {
        debugPrint('   网络连接超时，请检查网络连接');
      } else if (e.toString().contains('SocketException')) {
        debugPrint('   无法连接到服务器，请检查服务器地址和网络');
      }
    }
  }

  /// 测试视频文件是否可以下载
  Future<void> _testVideoDownload(String url) async {
    try {
      debugPrint('🔍 测试视频文件下载...');
      final uri = Uri.parse(url);
      final response = await http.get(
        uri,
        headers: {'Range': 'bytes=0-1023'}, // 只下载前1KB
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('下载超时');
        },
      );
      
      debugPrint('📊 视频下载测试结果:');
      debugPrint('  - 状态码: ${response.statusCode}');
      debugPrint('  - Content-Type: ${response.headers['content-type']}');
      debugPrint('  - Content-Length: ${response.headers['content-length']}');
      debugPrint('  - Content-Range: ${response.headers['content-range']}');
      debugPrint('  - 下载数据大小: ${response.bodyBytes.length} 字节');
      
      if (response.statusCode == 200 || response.statusCode == 206) {
        debugPrint('✅ 视频文件可以下载');
        // 检查是否是有效的MP4文件（MP4文件通常以ftyp box开头）
        if (response.bodyBytes.length > 4) {
          final header = String.fromCharCodes(response.bodyBytes.take(4));
          debugPrint('  - 文件头: ${response.bodyBytes.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
          if (response.bodyBytes.length >= 8) {
            // MP4文件应该包含ftyp box
            final ftyp = String.fromCharCodes(response.bodyBytes.skip(4).take(4));
            debugPrint('  - Box类型: $ftyp');
          }
        }
      } else {
        debugPrint('❌ 视频文件下载失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 视频下载测试失败: $e');
    }
  }

  /// 对 URL 中的中文、空格、括号等特殊字符进行编码，避免服务端 404。
  /// 需要手动组装，防止 Uri.replace 再次对 `%` 进行编码。
  String _encodeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (!uri.hasAuthority) {
        return Uri.encodeFull(url);
      }
      final encodedPath = uri.pathSegments
          .map((segment) => Uri.encodeComponent(segment))
          .join('/');

      final buffer = StringBuffer()
        ..write(uri.scheme)
        ..write('://')
        ..write(uri.authority);

      if (encodedPath.isNotEmpty) {
        buffer
          ..write('/')
          ..write(encodedPath);
      }

      if (uri.hasQuery) {
        buffer
          ..write('?')
          ..write(uri.query);
      }

      if (uri.hasFragment) {
        buffer
          ..write('#')
          ..write(uri.fragment);
      }

      return buffer.toString();
    } catch (_) {
      return Uri.encodeFull(url);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.item.title),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('返回'),
                  ),
                ],
              )
            : _isInitialized
                ? _controller.value.hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              '播放错误: ${_controller.value.errorDescription ?? "未知错误"}\n\n路径: ${widget.item.filePath}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 添加使用外部播放器的选项
                          if (widget.item.filePath.startsWith('http://') || widget.item.filePath.startsWith('https://'))
                            Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final encodedUrl = _encodeUrl(widget.item.filePath);
                                    try {
                                      // 复制URL到剪贴板
                                      await Clipboard.setData(ClipboardData(text: encodedUrl));
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✅ 视频URL已复制到剪贴板\n\n可以在浏览器或其他播放器中打开'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint('复制URL失败: $e');
                                    }
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('复制视频链接'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final encodedUrl = _encodeUrl(widget.item.filePath);
                                    try {
                                      // 使用share_plus分享URL，用户可以选择用浏览器打开
                                      await Share.share(
                                        '${widget.item.title}\n\n$encodedUrl',
                                        subject: widget.item.title,
                                      );
                                    } catch (e) {
                                      debugPrint('分享失败: $e');
                                      // 如果分享失败，至少复制到剪贴板
                                      await Clipboard.setData(ClipboardData(text: encodedUrl));
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✅ URL已复制到剪贴板'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.share),
                                  label: const Text('分享链接（可用浏览器打开）'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('返回'),
                          ),
                        ],
                      )
                    : Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio > 0 
                              ? _controller.value.aspectRatio 
                              : 16 / 9,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 视频播放器（居中显示）
                              VideoPlayer(_controller),
                              // 控制按钮（居中覆盖）
                              _ControlsOverlay(controller: _controller),
                              // 进度条（底部）
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  child: VideoProgressIndicator(
                                    _controller,
                                    allowScrubbing: true,
                                    colors: const VideoProgressColors(
                                      playedColor: Colors.white,
                                      bufferedColor: Colors.grey,
                                      backgroundColor: Colors.white24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        '正在加载视频...\n${widget.item.filePath}',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Icon(
              controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white.withOpacity(0.8),
              size: 64,
            ),
          ),
        ],
      ),
    );
  }
}



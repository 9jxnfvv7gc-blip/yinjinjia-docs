import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

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
      _controller = VideoPlayerController.networkUrl(Uri.parse(encodedUrl));
    } else {
      // 本地文件路径
      debugPrint('使用本地文件播放: $path');
      _controller = VideoPlayerController.file(File(path));
    }
    
    _controller.initialize().then((_) {
      debugPrint('视频初始化成功');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        debugPrint('开始播放视频');
      }
    }).catchError((error) {
      debugPrint('视频初始化失败: $error');
      debugPrint('错误类型: ${error.runtimeType}');
      debugPrint('视频路径: $path');
      
      // 如果是网络URL，测试是否可以访问
      if (path.startsWith('http://') || path.startsWith('https://')) {
        debugPrint('尝试测试URL可访问性...');
        _testUrlAccess(_encodeUrl(path));
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
      debugPrint('测试URL访问: $url');
      final uri = Uri.parse(url);
      final response = await http.head(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('URL访问超时');
        },
      );
      debugPrint('URL测试结果: ${response.statusCode}');
      debugPrint('Content-Type: ${response.headers['content-type']}');
      if (response.statusCode != 200) {
        debugPrint('URL返回错误状态码: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('URL测试失败: $e');
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



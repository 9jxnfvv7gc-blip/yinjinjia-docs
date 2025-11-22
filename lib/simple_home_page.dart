import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'config.dart';
import 'video_player_page.dart';
import 'music_player_page.dart';
import 'models.dart';

/// 简化的主页 - 视频和音乐统一在一个页面
class SimpleHomePage extends StatefulWidget {
  const SimpleHomePage({super.key});

  @override
  State<SimpleHomePage> createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends State<SimpleHomePage> {
  final Map<String, List<SimpleMediaItem>> _items = {
    'video': [], // 原创视频
    'music': [], // 原创歌曲
  };
  
  final GlobalKey _videoListKey = GlobalKey();
  final GlobalKey _musicListKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;
  bool _showAllVideos = false; // 是否显示所有视频
  bool _showAllSongs = false; // 是否显示所有歌曲

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && AppConfig.autoConnectServer) {
      _loadContent();
    }
  }

  /// 加载所有内容（视频和音乐）
  Future<void> _loadContent() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 加载视频
      final videos = await _loadVideos();
      // 加载音乐
      final musics = await _loadMusics();

      setState(() {
        _items['video'] = videos;
        _items['music'] = musics;
        _isConnected = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isLoading = false;
        _errorMessage = '加载失败: $e';
      });
    }
  }

  /// 加载视频列表
  Future<List<SimpleMediaItem>> _loadVideos() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/list/原创视频'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) {
          final url = item['url'] as String;
          final fullUrl = url.startsWith('http') 
              ? url 
              : '${AppConfig.apiBaseUrl}$url';
          return SimpleMediaItem(
            id: item['id'] ?? fullUrl,
            title: item['title'] as String? ?? '未命名视频',
            url: fullUrl,
            type: 'video',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('加载视频失败: $e');
    }
    return [];
  }

  /// 加载音乐列表
  Future<List<SimpleMediaItem>> _loadMusics() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/list/原创歌曲'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) {
          final url = item['url'] as String;
          final fullUrl = url.startsWith('http') 
              ? url 
              : '${AppConfig.apiBaseUrl}$url';
          return SimpleMediaItem(
            id: item['id'] ?? fullUrl,
            title: item['title'] as String? ?? '未命名音乐',
            url: fullUrl,
            type: 'music',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('加载音乐失败: $e');
    }
    return [];
  }

  /// 上传内容
  Future<void> _uploadContent(String type) async {
    try {
      // 根据平台和类型选择文件选择器配置
      FilePickerResult? result;
      
      if (kIsWeb) {
        // Web平台
        result = await FilePicker.platform.pickFiles(
          type: type == 'video' ? FileType.video : FileType.audio,
          allowMultiple: false,
        );
      } else if (Platform.isIOS) {
        // iOS平台：使用any类型，让用户可以选择任何文件
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowedExtensions: type == 'video' 
              ? ['mp4', 'mov', 'avi', 'mkv', 'm4v'] 
              : ['mp3', 'm4a', 'wav', 'aac', 'flac'],
          allowMultiple: false,
        );
      } else {
        // macOS和其他平台：使用custom类型，明确指定扩展名
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: type == 'video' 
              ? ['mp4', 'mov', 'avi', 'mkv', 'm4v', 'wmv', 'flv', 'webm'] 
              : ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg', 'wma', 'opus'],
          allowMultiple: false,
        );
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

      final pickedFile = result.files.single;
      final filePath = pickedFile.path;
      
      if (filePath == null) {
        // iOS上可能需要使用bytes
        if (pickedFile.bytes != null) {
          // 使用bytes上传（临时方案）
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('iOS上请使用"文件"应用选择文件，或从相册选择'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('无法获取文件路径，请重试'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      final file = File(filePath);
      
      // 检查文件是否存在
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('文件不存在，请重新选择'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

        // 显示上传进度
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // 上传文件
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

        final streamedResponse = await request.send();
        
        if (mounted) {
          Navigator.of(context).pop(); // 关闭进度对话框
        }

        if (streamedResponse.statusCode == 200) {
          // 重新加载内容
          await _loadContent();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('上传成功！'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('上传失败: ${streamedResponse.statusCode}'),
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
        if (e.toString().contains('Permission denied') || e.toString().contains('权限')) {
          errorMessage = '没有文件访问权限，请在设置中允许应用访问文件';
        } else if (e.toString().contains('No such file') || e.toString().contains('文件不存在')) {
          errorMessage = '文件不存在或已被删除，请重新选择';
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

  /// 显示上传选择对话框
  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '上传新内容',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.blue, size: 32),
              title: const Text('上传视频', style: TextStyle(fontSize: 16)),
              subtitle: const Text('上传原创视频内容'),
              onTap: () {
                Navigator.pop(context);
                _uploadContent('video');
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.purple, size: 32),
              title: const Text('上传音乐', style: TextStyle(fontSize: 16)),
              subtitle: const Text('上传原创歌曲内容'),
              onTap: () {
                Navigator.pop(context);
                _uploadContent('music');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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

  /// 删除内容
  Future<void> _deleteItem(SimpleMediaItem item) async {
    // 确认对话框
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

    if (confirmed != true) return;

    // 显示删除进度
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 从URL中提取文件路径
      String filePath = item.url;
      if (filePath.startsWith('http')) {
        final uri = Uri.parse(filePath);
        filePath = uri.path;
      }

      // 调用删除API
      final response = await http.post(
        Uri.parse(AppConfig.deleteVideoUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'file_path': filePath,
        }),
      ).timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      if (mounted) {
        Navigator.of(context).pop(); // 关闭进度对话框
      }

      if (response.statusCode == 200) {
        // 重新加载内容
        await _loadContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('删除成功！'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('删除失败: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 关闭进度对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 分享内容
  Future<void> _shareItem(SimpleMediaItem item) async {
    try {
      // 生成分享链接
      final shareUrl = item.url;
      final shareText = '${item.type == 'video' ? '视频' : '音乐'}：${item.title}\n\n$shareUrl';

      // 使用share_plus分享
      await Share.share(
        shareText,
        subject: item.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 复制链接到剪贴板
  Future<void> _copyLink(SimpleMediaItem item) async {
    try {
      await Clipboard.setData(ClipboardData(text: item.url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('链接已复制到剪贴板'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('复制失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 显示操作菜单
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
            // 分享链接
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('分享链接'),
              subtitle: const Text('通过其他应用分享'),
              onTap: () {
                Navigator.pop(context);
                _shareItem(item);
              },
            ),
            // 复制链接
            ListTile(
              leading: const Icon(Icons.link, color: Colors.green),
              title: const Text('复制链接'),
              subtitle: const Text('复制到剪贴板'),
              onTap: () {
                Navigator.pop(context);
                _copyLink(item);
              },
            ),
            // 删除（仅管理员）
            if (AppConfig.enableAdminMode && AppConfig.isAdmin) ...[
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
    final videoCount = _items['video']?.length ?? 0;
    final musicCount = _items['music']?.length ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
              ],
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              '我的原创内容',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          if (_errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadContent,
              tooltip: '重新加载',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadContent,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 连接状态
                    if (!_isConnected && _errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 统计卡片
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.video_library,
                            title: '原创视频',
                            count: videoCount,
                            color: Colors.blue,
                            onTap: () {
                              // 切换显示所有视频（像文件夹一样）
                              if (_items['video']!.isNotEmpty) {
                                setState(() {
                                  _showAllVideos = !_showAllVideos;
                                });
                                // 滚动到视频列表
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  final context = _videoListKey.currentContext;
                                  if (context != null) {
                                    Scrollable.ensureVisible(
                                      context,
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                      alignment: 0.1,
                                    );
                                  }
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('还没有视频，请先上传'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.music_note,
                            title: '原创歌曲',
                            count: musicCount,
                            color: Colors.purple,
                            onTap: () {
                              // 切换显示所有歌曲（像文件夹一样）
                              if (_items['music']!.isNotEmpty) {
                                setState(() {
                                  _showAllSongs = !_showAllSongs;
                                });
                                // 滚动到歌曲列表
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  final context = _musicListKey.currentContext;
                                  if (context != null) {
                                    Scrollable.ensureVisible(
                                      context,
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                      alignment: 0.1,
                                    );
                                  }
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('还没有歌曲，请先上传'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 上传按钮（仅管理员可见）
                    if (AppConfig.enableAdminMode && AppConfig.isAdmin)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showUploadDialog,
                          icon: const Icon(Icons.add, size: 24),
                          label: const Text(
                            '上传新内容',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),

                    if (AppConfig.enableAdminMode && AppConfig.isAdmin)
                      const SizedBox(height: 32),

                    // 视频列表
                    if (videoCount > 0) ...[
                      Row(
                        key: _videoListKey,
                        children: [
                          Icon(
                            _showAllVideos ? Icons.folder_open : Icons.folder,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showAllVideos ? '全部视频 ($videoCount)' : '最新视频',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (!_showAllVideos && videoCount > 5)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showAllVideos = true;
                                });
                              },
                              icon: const Icon(Icons.expand_more, size: 20),
                              label: const Text('查看全部'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          if (_showAllVideos)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showAllVideos = false;
                                });
                              },
                              icon: const Icon(Icons.expand_less, size: 20),
                              label: const Text('收起'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(_showAllVideos 
                          ? _items['video']! 
                          : _items['video']!.take(5)).map((item) => _MediaItemCard(
                            item: item,
                            onTap: () => _playItem(item),
                            onLongPress: () => _showItemMenu(item),
                            onShare: () => _shareItem(item),
                          )),
                      const SizedBox(height: 32),
                    ],

                    // 歌曲列表
                    if (musicCount > 0) ...[
                      Row(
                        key: _musicListKey,
                        children: [
                          Icon(
                            _showAllSongs ? Icons.folder_open : Icons.folder,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showAllSongs ? '全部歌曲 ($musicCount)' : '最新歌曲',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (!_showAllSongs && musicCount > 5)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showAllSongs = true;
                                });
                              },
                              icon: const Icon(Icons.expand_more, size: 20),
                              label: const Text('查看全部'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.purple,
                              ),
                            ),
                          if (_showAllSongs)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showAllSongs = false;
                                });
                              },
                              icon: const Icon(Icons.expand_less, size: 20),
                              label: const Text('收起'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.purple,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(_showAllSongs 
                          ? _items['music']! 
                          : _items['music']!.take(5)).map((item) => _MediaItemCard(
                            item: item,
                            onTap: () => _playItem(item),
                            onLongPress: () => _showItemMenu(item),
                            onShare: () => _shareItem(item),
                          )),
                      const SizedBox(height: 32),
                    ],

                    // 空状态
                    if (videoCount == 0 && musicCount == 0)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                '还没有内容',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '点击上方"上传新内容"开始',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

/// 统计卡片
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.7),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count 个',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 媒体项卡片
class _MediaItemCard extends StatelessWidget {
  final SimpleMediaItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onShare;

  const _MediaItemCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onSecondaryTap: onLongPress, // macOS右键支持
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 图标或封面
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: item.type == 'video' 
                      ? Colors.blue.shade100 
                      : Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.type == 'video' ? Icons.video_library : Icons.music_note,
                  color: item.type == 'video' 
                      ? Colors.blue.shade700 
                      : Colors.purple.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              // 标题和信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          item.type == 'video' 
                              ? Icons.video_library_outlined 
                              : Icons.music_note_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.type == 'video' ? '视频' : '音乐',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 操作按钮组
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 分享按钮
                  if (onShare != null)
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      color: Colors.blue.shade600,
                      onPressed: onShare,
                      tooltip: '分享',
                      iconSize: 24,
                    ),
                  // 播放图标
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 简化的媒体项模型
class SimpleMediaItem {
  final String id;
  final String title;
  final String url;
  final String type; // 'video' 或 'music'

  const SimpleMediaItem({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
  });
}


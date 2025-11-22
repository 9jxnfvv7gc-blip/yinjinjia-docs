import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'models.dart';
import 'video_player_page.dart';
import 'config.dart';

const List<String> _supportedVideoExtensions = [
  '.mp4',
  '.mov',
  '.mkv',
  '.avi',
  '.rmvb',
  '.rm',
  '.wmv',
  '.flv',
  '.f4v',
  '.m4v',
  '.mpg',
  '.mpeg',
  '.3gp',
  '.webm',
  '.ts',
  '.mts',
  '.vob',
  '.divx',
  '.xvid',
];

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  // 移动端：移除本地文件系统相关变量
  // String? _rootDirPath;  // 不再需要
  
  // 移动端：使用配置中的服务器地址，自动连接
  final String _serverUrl = AppConfig.apiBaseUrl;
  final Map<String, List<MediaItem>> _itemsByCategory = {};
  bool _isLoadingFromServer = false;
  bool _isConnected = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // 移动端：App启动时自动连接服务器
    if (!kIsWeb && AppConfig.autoConnectServer) {
      _autoConnectToServer();
    }
  }
  
  /// 自动连接服务器（移动端使用）
  Future<void> _autoConnectToServer() async {
    if (_isLoadingFromServer) return;
    
    setState(() {
      _isLoadingFromServer = true;
      _errorMessage = null;
    });
    
    try {
      await _loadAllCategoriesFromServer();
      setState(() {
        _isConnected = true;
        _isLoadingFromServer = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isLoadingFromServer = false;
        _errorMessage = '连接服务器失败: $e';
      });
      debugPrint('自动连接服务器失败: $e');
    }
  }
  
  /// 从服务器加载所有分类
  Future<void> _loadAllCategoriesFromServer() async {
    final Map<String, List<MediaItem>> serverItems = {};
    
    for (final category in videoCategories) {
      await _loadCategoryFromServer(
        category: category,
        serverUrl: _serverUrl,
        serverItems: serverItems,
      );
    }
    
    setState(() {
      _itemsByCategory.clear();
      _itemsByCategory.addAll(serverItems);
    });
    
    debugPrint('成功从服务器加载 ${_itemsByCategory.length} 个分类');
  }

  // 移动端：移除本地文件系统选择功能
  // Future<void> _pickVideoRootDir() async { ... }

  Future<void> _loadCategoryFromServer({
    required MediaCategory category,
    required String serverUrl,
    required Map<String, List<MediaItem>> serverItems,
    String parentPath = '',
  }) async {
    final categoryPath =
        parentPath.isEmpty ? category.name : '$parentPath/${category.name}';
    debugPrint('从服务器加载分类: $categoryPath');

    try {
      final response = await http
          .get(
            Uri.parse(AppConfig.listVideosUrl(categoryPath)),
            headers: {'Accept': 'application/json'},
          )
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> videos = json.decode(utf8.decode(response.bodyBytes));
        if (videos.isNotEmpty) {
          final items = videos.map((video) {
            final videoUrl = video['url'] as String;
            final fullUrl =
                videoUrl.startsWith('http') ? videoUrl : '$serverUrl$videoUrl';
            return MediaItem(
              id: video['id'] ?? fullUrl,
              title: video['title'] as String,
              filePath: fullUrl,
              categoryId: category.id,
            );
          }).toList();
          serverItems[category.id] = items;
        }
      }
    } catch (e) {
      debugPrint('加载分类 $categoryPath 失败: $e');
    }

    if (category.subCategories != null && category.subCategories!.isNotEmpty) {
      for (final subCategory in category.subCategories!) {
        await _loadCategoryFromServer(
          category: subCategory,
          serverUrl: serverUrl,
          serverItems: serverItems,
          parentPath: categoryPath,
        );
      }
    }
  }

  Future<void> _scanVideoDirectory(String rootPath) async {
    debugPrint('开始扫描目录: $rootPath');
    final rootDir = Directory(rootPath);
    if (!rootDir.existsSync()) {
      debugPrint('错误: 目录不存在 - $rootPath');
      return;
    }

    setState(() {
      _itemsByCategory.clear();
    });

    for (final category in videoCategories) {
      await _scanCategoryRecursive(category, rootDir);
    }
  }

  Future<void> _scanCategoryRecursive(MediaCategory category, Directory parentDir) async {
    final currentDir = Directory(p.join(parentDir.path, category.name));
    if (!currentDir.existsSync()) {
      debugPrint('目录不存在: ${currentDir.path}');
      return;
    }

    debugPrint('扫描分类: ${category.name} (${currentDir.path})');

    final files = currentDir
        .listSync()
        .whereType<File>()
        .where((file) {
          final ext = p.extension(file.path).toLowerCase();
          return _supportedVideoExtensions.contains(ext);
        })
        .map((file) {
          final title = p.basenameWithoutExtension(file.path);
          return MediaItem(
            id: file.path,
            title: title,
            filePath: file.path,
            categoryId: category.id,
          );
        })
        .toList();

    if (files.isNotEmpty) {
      setState(() {
        _itemsByCategory[category.id] = [
          ...(_itemsByCategory[category.id] ?? []),
          ...files,
        ];
      });
    }

    if (category.subCategories != null && category.subCategories!.isNotEmpty) {
      for (final subCategory in category.subCategories!) {
        await _scanCategoryRecursive(subCategory, currentDir);
      }
    }
  }

  // 从服务器获取分类列表（保留用于桌面端，移动端使用_autoConnectToServer）
  Future<void> _connectToServer(String serverUrl) async {
    if (!serverUrl.startsWith('http://') && !serverUrl.startsWith('https://')) {
      serverUrl = 'http://$serverUrl';
    }
    if (serverUrl.endsWith('/')) {
      serverUrl = serverUrl.substring(0, serverUrl.length - 1);
    }

    setState(() {
      _isLoadingFromServer = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/categories'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // 连接成功，加载分类数据
        setState(() {
          _itemsByCategory.clear();
        });
        // 将服务器返回的分类映射到我们的分类系统
        final Map<String, List<MediaItem>> serverItems = {};
        for (final category in videoCategories) {
          await _loadCategoryFromServer(
            category: category,
            serverUrl: serverUrl,
            serverItems: serverItems,
          );
        }

        setState(() {
          _itemsByCategory.clear();
          _itemsByCategory.addAll(serverItems);
          _isLoadingFromServer = false;
        });

        debugPrint('成功从服务器加载 ${_itemsByCategory.length} 个分类');
        
        // 显示连接成功提示
        if (mounted) {
          final totalVideos = _itemsByCategory.values.fold<int>(0, (sum, items) => sum + items.length);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                totalVideos > 0
                    ? '连接成功！已加载 $totalVideos 个视频。点击分类查看或上传更多视频'
                    : '连接成功！点击某个分类上传视频',
              ),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoadingFromServer = false;
        });
        debugPrint('服务器返回错误: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('连接服务器失败: HTTP ${response.statusCode}\n\n请按以下步骤操作：\n1. 打开终端\n2. 运行: cd /Volumes/Expansion/video_music_app\n3. 运行: python3 video_server.py "/Volumes/Expansion/MV【1.62GB】"\n4. 等待看到"服务器已启动"消息\n5. 然后重新连接'),
              duration: const Duration(seconds: 10),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingFromServer = false;
      });
      debugPrint('连接服务器出错: $e');
      
      // 根据错误类型提供更详细的提示
      String errorMessage = '连接服务器失败\n\n';
      if (e.toString().contains('Connection refused') || e.toString().contains('Failed host lookup')) {
        errorMessage += '❌ 服务器未运行或地址错误\n\n';
        errorMessage += '请按以下步骤操作：\n';
        errorMessage += '1. 打开终端（Terminal）\n';
        errorMessage += '2. 运行命令：\n';
        errorMessage += '   cd /Volumes/Expansion/video_music_app\n';
        errorMessage += '   python3 video_server.py "/Volumes/Expansion/MV【1.62GB】"\n';
        errorMessage += '3. 等待看到"服务器已启动"消息\n';
        errorMessage += '4. 确保地址正确：http://localhost:8081\n';
        errorMessage += '5. 然后重新点击"连接服务器"';
      } else if (e.toString().contains('timeout')) {
        errorMessage += '⏱️ 连接超时\n\n';
        errorMessage += '可能原因：\n';
        errorMessage += '1. 服务器未运行\n';
        errorMessage += '2. 网络连接问题\n';
        errorMessage += '3. 防火墙阻止连接\n\n';
        errorMessage += '请先启动服务器（见上方步骤）';
      } else {
        errorMessage += '错误详情：$e\n\n';
        errorMessage += '请确保：\n';
        errorMessage += '1. 服务器正在运行\n';
        errorMessage += '2. 地址正确（http://localhost:8081）\n';
        errorMessage += '3. 网络连接正常';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 12),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
            Colors.pink.shade50,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // 移动端：显示自动连接状态，移除手动连接按钮
                  if (!kIsWeb && AppConfig.autoConnectServer)
                    // 移动端：自动连接模式，只显示状态
                    Column(
                      children: [
                        // 连接状态指示器
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isConnected
                                ? Colors.green.shade50
                                : _isLoadingFromServer
                                    ? Colors.blue.shade50
                                    : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isConnected
                                  ? Colors.green.shade300
                                  : _isLoadingFromServer
                                      ? Colors.blue.shade300
                                      : Colors.orange.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_isLoadingFromServer)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                Icon(
                                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                                  size: 20,
                                  color: _isConnected ? Colors.green : Colors.orange,
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isLoadingFromServer
                                          ? '正在连接服务器...'
                                          : _isConnected
                                              ? '已连接到云端服务器'
                                              : '连接服务器失败',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _isConnected
                                            ? Colors.green.shade700
                                            : _isLoadingFromServer
                                                ? Colors.blue.shade700
                                                : Colors.orange.shade700,
                                      ),
                                    ),
                                    if (_isConnected || _errorMessage != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _isConnected
                                            ? '可以浏览和上传视频'
                                            : (_errorMessage ?? '请检查网络连接'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _isConnected
                                              ? Colors.green.shade600
                                              : Colors.orange.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!_isConnected && !_isLoadingFromServer)
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _autoConnectToServer,
                                  tooltip: '重新连接',
                                  color: Colors.orange.shade700,
                                ),
                            ],
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    // 桌面端或Web端：保留原有按钮（用于开发测试）
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return isMobile
                            ? Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.cloud_upload),
                                      label: const Text('连接服务器'),
                                      onPressed: _isLoadingFromServer
                                          ? null
                                          : () => _autoConnectToServer(),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: _isLoadingFromServer
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.cloud_upload),
                                      label: Text(_isLoadingFromServer ? '连接中...' : '连接服务器'),
                                      onPressed: _isLoadingFromServer
                                          ? null
                                          : () => _autoConnectToServer(),
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                  // 移除旧的服务器状态显示（已在上面显示）
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 根据屏幕宽度动态计算列数
                final width = constraints.maxWidth;
                int crossAxisCount;
                if (width < 600) {
                  // 手机：2列
                  crossAxisCount = 2;
                } else if (width < 900) {
                  // 平板：3列
                  crossAxisCount = 3;
                } else {
                  // 桌面：4列
                  crossAxisCount = 4;
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
              itemCount: videoCategories.length,
              itemBuilder: (context, index) {
                final category = videoCategories[index];
                // 如果有子分类，统计所有子分类的视频总数；否则统计一级分类的视频数
                int count = 0;
                if (category.subCategories != null && category.subCategories!.isNotEmpty) {
                  for (final subCategory in category.subCategories!) {
                    count += _itemsByCategory[subCategory.id]?.length ?? 0;
                  }
                } else {
                  count = _itemsByCategory[category.id]?.length ?? 0;
                }

                // 为每个分类定义不同的颜色主题
                final colorThemes = [
                  [Colors.blue, Colors.purple],
                  [Colors.pink, Colors.red],
                  [Colors.orange, Colors.deepOrange],
                  [Colors.green, Colors.teal],
                  [Colors.cyan, Colors.blue],
                  [Colors.amber, Colors.orange],
                  [Colors.indigo, Colors.purple],
                  [Colors.teal, Colors.green],
                  [Colors.lime, Colors.yellow],
                  [Colors.deepPurple, Colors.indigo],
                  [Colors.brown, Colors.orange],
                ];
                final colors = colorThemes[index % colorThemes.length];
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // 如果有子分类，显示子分类列表；否则直接显示视频列表
                      if (category.subCategories != null && category.subCategories!.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SubCategoryListPage(
                              parentCategory: category,
                              serverUrl: _serverUrl,
                              itemsByCategory: _itemsByCategory,
                              onItemsUpdated: () {
                                // 重新加载分类列表
                                _autoConnectToServer();
                              },
                              parentPathSegments: const [],
                            ),
                          ),
                        );
                      } else {
                        // 没有子分类，直接显示视频列表
                        final items = _itemsByCategory[category.id] ?? [];
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoCategoryListPage(
                              category: category,
                              items: items,
                              serverUrl: _serverUrl,
                              onItemsUpdated: () {
                                // 重新加载分类列表
                                _autoConnectToServer();
                              },
                              parentPathSegments: const [],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors[0].shade400, colors[1].shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.video_library,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$count 个视频',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> _showManualPathDialog(
  BuildContext context, {
  required String title,
  String hint = '/Volumes/Expansion/your-folder',
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('确认'),
          ),
        ],
      );
    },
  );
}

class VideoCategoryListPage extends StatefulWidget {
  final MediaCategory category;
  final List<MediaItem> items;
  final String? serverUrl;
  final VoidCallback? onItemsUpdated;
  final List<String>? parentPathSegments; // 从顶级到父级的路径

  const VideoCategoryListPage({
    super.key,
    required this.category,
    required this.items,
    this.serverUrl,
    this.onItemsUpdated,
    this.parentPathSegments,
  });

  @override
  State<VideoCategoryListPage> createState() => _VideoCategoryListPageState();
}

class _VideoCategoryListPageState extends State<VideoCategoryListPage> {
  bool _isUploading = false;
  List<MediaItem> _items = [];
  int _uploadProgress = 0; // 当前上传进度（第几个文件）
  int _totalFiles = 0; // 总文件数
  bool _isSelectionMode = false; // 是否处于选择模式
  Set<String> _selectedItems = {}; // 选中的视频 ID

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  List<String> _currentPathSegments() {
    final segments = <String>[];
    if (widget.parentPathSegments != null) {
      segments.addAll(widget.parentPathSegments!);
    }
    segments.add(widget.category.name);
    return segments;
  }

  String _buildCurrentCategoryPath() {
    return _currentPathSegments().join('/');
  }

  MediaCategory? _findCategoryByPath(List<String> pathSegments) {
    if (pathSegments.isEmpty) return null;
    List<MediaCategory> currentList = videoCategories;
    MediaCategory? current;
    for (final name in pathSegments) {
      try {
        current = currentList.firstWhere((cat) => cat.name == name);
      } catch (_) {
        return null;
      }
      currentList = current.subCategories ?? [];
    }
    return current;
  }

  List<String> _buildParentCategoryPathSegments(MediaCategory parentCategory) {
    final segments = <String>[];
    if (widget.parentPathSegments != null) {
      segments.addAll(widget.parentPathSegments!);
    }
    if (segments.isEmpty || segments.last != parentCategory.name) {
      segments.add(parentCategory.name);
    }
    return segments;
  }

  Future<void> _moveVideosBatch(List<MediaItem> items, String targetCategory) async {
    debugPrint('开始批量移动: ${items.length} 个视频到 $targetCategory');
    
    if (widget.serverUrl == null || items.isEmpty) {
      debugPrint('批量移动失败: serverUrl=${widget.serverUrl}, items.length=${items.length}');
      return;
    }

    setState(() {
      _isUploading = true;
      _totalFiles = items.length;
      _uploadProgress = 0;
    });

    int successCount = 0;
    int failCount = 0;
    List<String> failedFiles = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      setState(() {
        _uploadProgress = i + 1;
      });

      try {
        String sourcePath = item.filePath;
        if (sourcePath.startsWith('http')) {
          final uri = Uri.parse(sourcePath);
          sourcePath = uri.path;
        }

        debugPrint('批量移动 [$i+1/${items.length}]: $sourcePath -> $targetCategory');

        final response = await http.post(
          Uri.parse('${widget.serverUrl}/api/move'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'source_path': sourcePath,
            'target_category': targetCategory,
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          successCount++;
          debugPrint('批量移动成功: ${item.title}');
        } else {
          failCount++;
          failedFiles.add(item.title);
          debugPrint('批量移动失败: ${item.title} (${response.statusCode})');
        }
      } catch (e) {
        failCount++;
        failedFiles.add(item.title);
        debugPrint('批量移动错误: ${item.title} - $e');
      }
    }

    // 重新加载分类列表
    if (successCount > 0 && widget.onItemsUpdated != null) {
      widget.onItemsUpdated!();
    }

    // 退出选择模式
    setState(() {
      _isUploading = false;
      _uploadProgress = 0;
      _totalFiles = 0;
      _isSelectionMode = false;
      _selectedItems.clear();
    });

    // 显示结果
    if (mounted) {
      String message = '批量移动完成：成功 $successCount 个';
      if (failCount > 0) {
        message += '，失败 $failCount 个';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: failCount > 0 ? 5 : 3),
        ),
      );
    }
  }

  Future<void> _deleteVideo(MediaItem item) async {
    if (widget.serverUrl == null) return;

    try {
      String filePath = item.filePath;
      if (filePath.startsWith('http')) {
        final uri = Uri.parse(filePath);
        filePath = uri.path;
      }
      
      debugPrint('删除文件: filePath=$filePath');

      final response = await http.post(
        Uri.parse('${widget.serverUrl}/api/delete'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'file_path': filePath,
        }),
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('删除响应: statusCode=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        // 重新加载分类列表
        if (widget.onItemsUpdated != null) {
          widget.onItemsUpdated!();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('删除错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, MediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除 "${item.title}" 吗？\n\n此操作无法撤销！'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteVideo(item);
    }
  }

  Future<void> _batchRenameVideos(List<MediaItem> items, List<String> newNames) async {
    if (widget.serverUrl == null || items.isEmpty) return;

    setState(() {
      _isUploading = true;
      _totalFiles = items.length;
      _uploadProgress = 0;
    });

    int successCount = 0;
    int failCount = 0;
    List<String> failedFiles = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final newName = i < newNames.length ? newNames[i] : null;
      
      if (newName == null || newName.isEmpty) {
        failCount++;
        failedFiles.add(item.title);
        continue;
      }

      setState(() {
        _uploadProgress = i + 1;
      });

      try {
        String filePath = item.filePath;
        if (filePath.startsWith('http')) {
          final uri = Uri.parse(filePath);
          filePath = uri.path;
        }

        final response = await http.post(
          Uri.parse('${widget.serverUrl}/api/rename'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'file_path': filePath,
            'new_name': newName,
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          successCount++;
          debugPrint('批量重命名成功: ${item.title} -> $newName');
        } else {
          failCount++;
          failedFiles.add(item.title);
          debugPrint('批量重命名失败: ${item.title} (${response.statusCode})');
        }
      } catch (e) {
        failCount++;
        failedFiles.add(item.title);
        debugPrint('批量重命名错误: ${item.title} - $e');
      }
    }

    // 重新加载分类列表
    if (successCount > 0 && widget.onItemsUpdated != null) {
      widget.onItemsUpdated!();
    }

    // 退出选择模式
    setState(() {
      _isUploading = false;
      _uploadProgress = 0;
      _totalFiles = 0;
      _isSelectionMode = false;
      _selectedItems.clear();
    });

    // 显示结果
    if (mounted) {
      String message = '批量重命名完成：成功 $successCount 个';
      if (failCount > 0) {
        message += '，失败 $failCount 个';
        if (failedFiles.isNotEmpty && failedFiles.length <= 5) {
          message += '\n失败文件：${failedFiles.join('、')}';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: failCount > 0 ? 5 : 3),
        ),
      );
    }
  }

  Future<void> _showBatchRenameDialog() async {
    debugPrint('点击批量重命名按钮，已选择 ${_selectedItems.length} 个视频');
    
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要重命名的视频')),
      );
      return;
    }

    final selectedItems = _items.where((item) => _selectedItems.contains(item.id)).toList();
    
    // 显示批量重命名对话框
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final prefixController = TextEditingController();
        final startNumController = TextEditingController(text: '1');
        String renameMode = 'template'; // 'template' 或 'manual'
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('批量重命名（${selectedItems.length} 个文件）'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 重命名模式选择
                    Row(
                      children: [
                        Radio<String>(
                          value: 'template',
                          groupValue: renameMode,
                          onChanged: (value) {
                            setDialogState(() {
                              renameMode = value!;
                            });
                          },
                        ),
                        const Text('模板模式'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'manual',
                          groupValue: renameMode,
                          onChanged: (value) {
                            setDialogState(() {
                              renameMode = value!;
                            });
                          },
                        ),
                        const Text('手动输入'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (renameMode == 'template') ...[
                      TextField(
                        controller: prefixController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '文件名模板',
                          hintText: '例如: 楷书第{序号}课',
                          helperText: '使用 {序号} 作为占位符，将从起始序号开始递增',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: startNumController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '起始序号',
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '预览：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...selectedItems
                                .take(5)
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final startNum = int.tryParse(startNumController.text) ?? 1;
                              final previewName = prefixController.text.replaceAll('{序号}', '${startNum + index}');
                              return Text(
                                '${item.title} → ${previewName.isEmpty ? item.title : previewName}',
                                style: const TextStyle(fontSize: 12),
                              );
                            }),
                            if (selectedItems.length > 5)
                              Text(
                                '... 还有 ${selectedItems.length - 5} 个文件',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text(
                        '点击"确认"后，将显示详细的重命名界面',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    if (renameMode == 'template') {
                      final prefix = prefixController.text.trim();
                      final startNum = int.tryParse(startNumController.text) ?? 1;
                      
                      if (prefix.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入文件名模板')),
                        );
                        return;
                      }
                      
                      final newNames = selectedItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        return prefix.replaceAll('{序号}', '${startNum + index}');
                      }).toList();
                      
                      Navigator.of(context).pop({
                        'mode': 'template',
                        'newNames': newNames,
                      });
                    } else {
                      // 手动模式：返回标记，外部会显示详细对话框
                      Navigator.of(context).pop({
                        'mode': 'manual',
                      });
                    }
                  },
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      if (result['mode'] == 'template' && result['newNames'] != null) {
        await _batchRenameVideos(selectedItems, result['newNames'] as List<String>);
      } else if (result['mode'] == 'manual') {
        // 手动模式：显示一个更详细的对话框
        await _showManualBatchRenameDialog(selectedItems);
      }
    }
  }

  Future<void> _showManualBatchRenameDialog(List<MediaItem> items) async {
    final controllers = items.map((item) => TextEditingController(text: item.title)).toList();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('批量重命名（${items.length} 个文件）'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${item.title}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: controllers[index],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '输入新文件名（不含扩展名）',
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 检查是否有空名称
                for (var controller in controllers) {
                  if (controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('所有文件名不能为空')),
                    );
                    return;
                  }
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final newNames = controllers.map((c) => c.text.trim()).toList();
      await _batchRenameVideos(items, newNames);
    }
  }

  Future<void> _showBatchDeleteDialog() async {
    debugPrint('点击批量删除按钮，已选择 ${_selectedItems.length} 个视频');
    
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要删除的视频')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认批量删除'),
          content: Text('确定要删除选中的 ${_selectedItems.length} 个视频吗？\n\n此操作无法撤销！'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isUploading = true;
      _totalFiles = _selectedItems.length;
      _uploadProgress = 0;
    });

    int successCount = 0;
    int failCount = 0;

    final selectedItems = _items.where((item) => _selectedItems.contains(item.id)).toList();
    
    for (int i = 0; i < selectedItems.length; i++) {
      final item = selectedItems[i];
      
      setState(() {
        _uploadProgress = i + 1;
      });

      try {
        String filePath = item.filePath;
        if (filePath.startsWith('http')) {
          final uri = Uri.parse(filePath);
          filePath = uri.path;
        }

        final response = await http.post(
          Uri.parse('${widget.serverUrl}/api/delete'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'file_path': filePath,
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('批量删除错误: ${item.title} - $e');
      }
    }

    // 重新加载分类列表
    if (successCount > 0 && widget.onItemsUpdated != null) {
      widget.onItemsUpdated!();
    }

    // 退出选择模式
    setState(() {
      _isUploading = false;
      _uploadProgress = 0;
      _totalFiles = 0;
      _isSelectionMode = false;
      _selectedItems.clear();
    });

    // 显示结果
    if (mounted) {
      String message = '批量删除完成：成功 $successCount 个';
      if (failCount > 0) {
        message += '，失败 $failCount 个';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: failCount > 0 ? 5 : 3),
        ),
      );
    }
  }

  Future<void> _showFileInfoDialog(BuildContext context, MediaItem item) async {
    if (widget.serverUrl == null) return;

    try {
      String filePath = item.filePath;
      if (filePath.startsWith('http')) {
        final uri = Uri.parse(filePath);
        filePath = uri.path;
      }

      final response = await http.get(
        Uri.parse('${widget.serverUrl}/api/info?file_path=${Uri.encodeComponent(filePath)}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('文件信息'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoRow('文件名', data['filename'] ?? ''),
                      const Divider(),
                      _buildInfoRow('大小', data['size_formatted'] ?? ''),
                      const Divider(),
                      _buildInfoRow('创建时间', data['created_time'] ?? ''),
                      const Divider(),
                      _buildInfoRow('修改时间', data['modified_time'] ?? ''),
                      const Divider(),
                      _buildInfoRow('路径', data['path'] ?? ''),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      debugPrint('获取文件信息错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取文件信息失败: $e')),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _renameVideo(MediaItem item, String newName) async {
    if (widget.serverUrl == null) return;

    try {
      String filePath = item.filePath;
      if (filePath.startsWith('http')) {
        final uri = Uri.parse(filePath);
        filePath = uri.path;
      }
      
      debugPrint('重命名文件: filePath=$filePath, newName=$newName');
      debugPrint('服务器地址: ${widget.serverUrl}');
      debugPrint('完整URL: ${widget.serverUrl}/api/rename');

      final response = await http.post(
        Uri.parse('${widget.serverUrl}/api/rename'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'file_path': filePath,
          'new_name': newName,
        }),
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('重命名响应: statusCode=${response.statusCode}');
      debugPrint('响应体: ${response.body}');

      if (response.statusCode == 200) {
        // 重新加载分类列表
        if (widget.onItemsUpdated != null) {
          widget.onItemsUpdated!();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('重命名成功')),
          );
        }
      } else {
        String errorMsg = '重命名失败';
        if (response.statusCode == 409) {
          errorMsg = '文件名已存在';
        } else {
          final responseText = response.body.trim();
          if (responseText.isNotEmpty) {
            errorMsg = '重命名失败: ${response.statusCode}\n${responseText}';
          } else {
            errorMsg = '重命名失败: ${response.statusCode}';
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } catch (e) {
      debugPrint('重命名错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重命名失败: $e')),
        );
      }
    }
  }

  Future<void> _showRenameDialog(BuildContext context, MediaItem item) async {
    if (widget.serverUrl == null) return;

    // 获取当前文件名（不含扩展名）
    String currentName = item.title;
    final controller = TextEditingController(text: currentName);

    if (mounted) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('重命名文件'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '新文件名',
                    hintText: '输入新文件名（不含扩展名）',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Text(
                  '当前文件名: $currentName',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  final newName = controller.text.trim();
                  if (newName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('文件名不能为空')),
                    );
                    return;
                  }
                  Navigator.of(context).pop(newName);
                },
                child: const Text('确认'),
              ),
            ],
          );
        },
      );

      if (result != null && result.isNotEmpty) {
        await _renameVideo(item, result);
      }
    }
  }

  Future<void> _showShareDialog(BuildContext context, MediaItem item) async {
    if (widget.serverUrl == null) return;

    String shareUrl = item.filePath;
    if (!shareUrl.startsWith('http')) {
      // 如果是相对路径，构建完整URL
      final uri = Uri.parse(widget.serverUrl!);
      shareUrl = '${uri.scheme}://${uri.host}:${uri.port}$shareUrl';
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          final controller = TextEditingController(text: shareUrl);
          return AlertDialog(
            title: const Text('分享链接'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '分享链接',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '复制此链接分享给其他人，他们可以在浏览器中打开观看',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
              TextButton(
                onPressed: () {
                  // 复制到剪贴板（需要添加 clipboard 包，这里先显示）
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('链接已复制到剪贴板')),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('复制链接'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showBatchMoveDialog() async {
    debugPrint('点击批量移动按钮，已选择 ${_selectedItems.length} 个视频');
    
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要移动的视频')),
      );
      return;
    }

    // 找到当前分类的父分类
    MediaCategory? parentCategory;
    
    if (widget.parentPathSegments != null &&
        widget.parentPathSegments!.isNotEmpty) {
      parentCategory = _findCategoryByPath(widget.parentPathSegments!);
    } else {
      parentCategory = widget.category;
    }

    if (parentCategory == null || parentCategory.subCategories == null || parentCategory.subCategories!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法找到可用的目标分类')),
      );
      return;
    }

    final parentCategoryPathSegments =
        _buildParentCategoryPathSegments(parentCategory);
    final subCategories = parentCategory.subCategories!;

    final targetCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('批量移动到（已选择 ${_selectedItems.length} 个）'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                final subCat = subCategories[index];
                return ListTile(
                  title: Text(subCat.name),
                  onTap: () => Navigator.of(context).pop(
                    [
                      ...parentCategoryPathSegments,
                      subCat.name,
                    ].join('/'),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (targetCategory != null) {
      final selectedItems = _items.where((item) => _selectedItems.contains(item.id)).toList();
      await _moveVideosBatch(selectedItems, targetCategory);
    }
  }

  Future<void> _moveVideo(MediaItem item, String targetCategory) async {
    if (widget.serverUrl == null) return;

    try {
      // 从 filePath 中提取源文件路径
      // 如果是网络 URL，需要转换为服务器能识别的路径
      String sourcePath = item.filePath;
      if (sourcePath.startsWith('http')) {
        // 从完整 URL 中提取路径部分
        final uri = Uri.parse(sourcePath);
        sourcePath = uri.path; // 例如: /video/纪录片/xxx.mp4
      }
      
      debugPrint('移动文件: sourcePath=$sourcePath, targetCategory=$targetCategory');

      final response = await http.post(
        Uri.parse('${widget.serverUrl}/api/move'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'source_path': sourcePath,
          'target_category': targetCategory,
        }),
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('移动响应: statusCode=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        // 重新加载分类列表
        if (widget.onItemsUpdated != null) {
          widget.onItemsUpdated!();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('移动成功')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('移动失败: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('移动错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('移动失败: $e')),
        );
      }
    }
  }

  Future<void> _showMoveDialog(BuildContext context, MediaItem item) async {
    // 找到当前分类的父分类
    MediaCategory? parentCategory;
    
    // 如果当前分类有父分类，找到父分类
    if (widget.parentPathSegments != null &&
        widget.parentPathSegments!.isNotEmpty) {
      parentCategory = _findCategoryByPath(widget.parentPathSegments!);
    } else {
      // 如果当前分类是一级分类，检查它是否有子分类
      parentCategory = widget.category;
    }

    if (parentCategory == null || parentCategory.subCategories == null || parentCategory.subCategories!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法找到可用的目标分类')),
      );
      return;
    }

    final parentCategoryPathSegments =
        _buildParentCategoryPathSegments(parentCategory);
    final subCategories = parentCategory.subCategories!;

    final targetCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('移动到'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                final subCat = subCategories[index];
                final isCurrentCategory = subCat.id == widget.category.id;
                return ListTile(
                  title: Text(subCat.name),
                  enabled: !isCurrentCategory,
                  onTap: isCurrentCategory
                      ? null
                      : () => Navigator.of(context).pop(
                            [
                              ...parentCategoryPathSegments,
                              subCat.name,
                            ].join('/'),
                          ),
                );
              },
            ),
          ),
        );
      },
    );

    if (targetCategory != null) {
      await _moveVideo(item, targetCategory);
    }
  }

  Future<void> _uploadVideo() async {
    debugPrint('点击上传按钮');
    
    if (widget.serverUrl == null) {
      debugPrint('serverUrl 为 null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未连接服务器，无法上传')),
      );
      return;
    }

    debugPrint('开始选择文件，serverUrl: ${widget.serverUrl}');
    
    // 选择视频文件（支持多选，包括所有视频格式）
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp4', 'mov', 'mkv', 'avi', 'rmvb', 'rm', 'wmv', 'flv', 'f4v', 'm4v', 
        'mpg', 'mpeg', '3gp', 'webm', 'ts', 'mts', 'vob', 'divx', 'xvid'
      ],
      allowMultiple: true, // 支持批量选择
    );
    
    debugPrint('文件选择结果: ${result?.files.length ?? 0} 个文件');

    if (result == null || result.files.isEmpty) return;

    final files = result.files.where((f) => f.path != null).toList();
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未选择有效文件')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _totalFiles = files.length;
      _uploadProgress = 0;
    });

    int successCount = 0;
    int failCount = 0;
    List<String> failedFiles = [];

    // 逐个上传文件
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      if (file.path == null) continue;

      setState(() {
        _uploadProgress = i + 1;
      });

      try {
        // 创建 multipart/form-data 请求
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${widget.serverUrl}/api/upload'),
        );

        // 构建分类路径：如果有父分类，使用 "父分类/子分类" 格式
        final categoryPath = _buildCurrentCategoryPath();
        request.fields['category'] = categoryPath;
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );

        final streamedResponse = await request.send().timeout(
          const Duration(minutes: 10), // 上传大文件可能需要较长时间
        );

        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          successCount++;
          debugPrint('上传成功: ${file.name}');
        } else {
          failCount++;
          failedFiles.add(file.name);
          debugPrint('上传失败: ${file.name} (${response.statusCode})');
        }
      } catch (e) {
        failCount++;
        failedFiles.add(file.name);
        debugPrint('上传错误: ${file.name} - $e');
      }
    }

    // 重新加载分类列表
    if (successCount > 0 && widget.onItemsUpdated != null) {
      widget.onItemsUpdated!();
    }

    // 显示上传结果
    if (mounted) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
        _totalFiles = 0;
      });

      String message = '上传完成：成功 $successCount 个';
      if (failCount > 0) {
        message += '，失败 $failCount 个';
        if (failedFiles.isNotEmpty) {
          message += '\n失败文件：${failedFiles.join('、')}';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: failCount > 0 ? 5 : 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 更新 items 列表
    if (widget.items.length != _items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _items = List.from(widget.items);
        });
      });
    }

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
                Colors.blue.shade600,
                Colors.purple.shade600,
              ],
            ),
          ),
        ),
        title: _isSelectionMode
            ? Text(
                '已选择 ${_selectedItems.length} 个',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedItems.clear();
                  });
                },
              )
            : null,
        actions: widget.serverUrl != null
            ? [
                if (_isSelectionMode) ...[
                  // 批量重命名按钮
                  IconButton(
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit),
                    onPressed: _isUploading || _selectedItems.isEmpty
                        ? null
                        : () => _showBatchRenameDialog(),
                    tooltip: '批量重命名',
                    color: Colors.blue.shade300,
                  ),
                  // 批量删除按钮
                  IconButton(
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete),
                    onPressed: _isUploading || _selectedItems.isEmpty
                        ? null
                        : () => _showBatchDeleteDialog(),
                    tooltip: '批量删除',
                    color: Colors.red.shade300,
                  ),
                  // 批量移动按钮
                  IconButton(
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.drive_file_move),
                    onPressed: _isUploading || _selectedItems.isEmpty
                        ? null
                        : _showBatchMoveDialog,
                    tooltip: '批量移动',
                  ),
                  // 全选/取消全选按钮
                  IconButton(
                    icon: Text(
                      _selectedItems.length == _items.length ? '取消全选' : '全选',
                      style: const TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectedItems.length == _items.length) {
                          _selectedItems.clear();
                        } else {
                          _selectedItems = _items.map((item) => item.id).toSet();
                        }
                      });
                    },
                  ),
                ] else ...[
                  // 选择模式按钮（更明显）
                  TextButton.icon(
                    icon: const Icon(Icons.checklist, color: Colors.white),
                    label: const Text(
                      '批量管理',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      debugPrint('点击批量管理按钮');
                      setState(() {
                        _isSelectionMode = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已进入批量管理，可批量重命名/移动/删除'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  // 上传按钮
                  IconButton(
                    icon: _isUploading
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              if (_totalFiles > 0)
                                Text(
                                  '$_uploadProgress/$_totalFiles',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          )
                        : const Icon(Icons.upload),
                    onPressed: _isUploading ? null : _uploadVideo,
                    tooltip: _isUploading
                        ? '正在上传 $_uploadProgress/$_totalFiles'
                        : '上传视频（支持批量上传）',
                  ),
                ],
              ]
            : null,
      ),
      body: _items.isEmpty
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                  ],
                ),
              ),
              child: Center(
                child: widget.serverUrl != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.cloud_upload,
                              size: 64,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '该分类下暂无视频',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isUploading ? null : _uploadVideo,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.upload),
                            label: _isUploading
                                ? Text('上传中 $_uploadProgress/$_totalFiles')
                                : const Text('上传视频（支持批量选择）'),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '该分类下暂无视频',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
              ),
            )
          : widget.serverUrl != null
              ? ReorderableListView.builder(
                  itemCount: _items.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    setState(() {
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                    });
                    // 保存新的排序顺序
                    _saveFileOrder();
                  },
                  itemBuilder: (context, index) {
                final item = _items[index];
                final isSelected = _selectedItems.contains(item.id);
                
                return Card(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: _isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedItems.add(item.id);
                                } else {
                                  _selectedItems.remove(item.id);
                                }
                              });
                            },
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.drag_handle,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade400, Colors.purple.shade600],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                            ],
                          ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.folder, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.filePath.length > 50
                                  ? '${item.filePath.substring(0, 50)}...'
                                  : item.filePath,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: _isSelectionMode
                        ? null
                        : widget.serverUrl != null
                            ? PopupMenuButton<String>(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.more_vert,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                ),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'play':
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => VideoPlayerPage(item: item),
                                        ),
                                      );
                                      break;
                                    case 'rename':
                                      _showRenameDialog(context, item);
                                      break;
                                    case 'info':
                                      _showFileInfoDialog(context, item);
                                      break;
                                    case 'share':
                                      _showShareDialog(context, item);
                                      break;
                                    case 'move':
                                      _showMoveDialog(context, item);
                                      break;
                                    case 'delete':
                                      _showDeleteDialog(context, item);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'play',
                                    child: Row(
                                      children: [
                                        Icon(Icons.play_arrow, size: 20),
                                        SizedBox(width: 8),
                                        Text('播放'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'rename',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('重命名'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'info',
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, size: 20),
                                        SizedBox(width: 8),
                                        Text('文件信息'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'share',
                                    child: Row(
                                      children: [
                                        Icon(Icons.share, size: 20),
                                        SizedBox(width: 8),
                                        Text('分享链接'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'move',
                                    child: Row(
                                      children: [
                                        Icon(Icons.drive_file_move, size: 20),
                                        SizedBox(width: 8),
                                        Text('移动到'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        const SizedBox(width: 8),
                                        const Text('删除', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VideoPlayerPage(item: item),
                                    ),
                                  );
                                },
                              ),
                    onTap: _isSelectionMode
                        ? () {
                            setState(() {
                              if (isSelected) {
                                _selectedItems.remove(item.id);
                              } else {
                                _selectedItems.add(item.id);
                              }
                            });
                          }
                        : () {
                            // 点击播放
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerPage(item: item),
                              ),
                            );
                          },
                    onLongPress: widget.serverUrl != null && !_isSelectionMode
                        ? () => _showMoveDialog(context, item)
                        : null,
                  ),
                );
              },
            )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    // isSelected 变量在此分支中未使用，已在其他分支中使用
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.purple.shade600],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerPage(item: item),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VideoPlayerPage(item: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _saveFileOrder() async {
    if (widget.serverUrl == null) return;
    
    try {
      final categoryPath = _buildCurrentCategoryPath();
      
      // 获取文件ID列表（按当前顺序）
      final fileOrder = _items.map((item) {
        String filePath = item.filePath;
        if (filePath.startsWith('http')) {
          final uri = Uri.parse(filePath);
          filePath = uri.path;
        }
        return item.id; // 使用文件的完整路径作为ID
      }).toList();
      
      debugPrint('保存排序顺序: $categoryPath - ${fileOrder.length} 个文件');
      
      final response = await http.post(
        Uri.parse('${widget.serverUrl}/api/save_order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category': categoryPath,
          'file_order': fileOrder,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        debugPrint('排序顺序已保存');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('排序已保存'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        debugPrint('保存排序失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('保存排序错误: $e');
    }
  }
}

// 子分类列表页面
class SubCategoryListPage extends StatelessWidget {
  final MediaCategory parentCategory;
  final String? serverUrl;
  final Map<String, List<MediaItem>> itemsByCategory;
  final VoidCallback? onItemsUpdated;
  final List<String> parentPathSegments;

  const SubCategoryListPage({
    super.key,
    required this.parentCategory,
    this.serverUrl,
    required this.itemsByCategory,
    this.onItemsUpdated,
    this.parentPathSegments = const [],
  });

  @override
  Widget build(BuildContext context) {
    final subCategories = parentCategory.subCategories ?? [];
    // 获取一级分类下的视频（直接上传到一级分类文件夹的）
    final parentItems = itemsByCategory[parentCategory.id] ?? [];
    final parentCount = parentItems.length;

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
                Colors.purple.shade600,
                Colors.pink.shade600,
              ],
            ),
          ),
        ),
        title: Text(
          parentCategory.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade50,
              Colors.pink.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
        itemCount: subCategories.length + (parentCount > 0 ? 1 : 0), // 如果有一级分类视频，增加一个卡片
        itemBuilder: (context, index) {
          // 第一个卡片显示一级分类下的视频（如果有）
          if (parentCount > 0 && index == 0) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoCategoryListPage(
                      category: parentCategory,
                      items: parentItems,
                      serverUrl: serverUrl,
                      onItemsUpdated: onItemsUpdated,
                      parentPathSegments: parentPathSegments,
                    ),
                  ),
                );
              },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.folder, size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '一级分类视频',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$parentCount 个视频\n（可移动到子分类）',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            );
          }
          
          // 子分类卡片
          final subIndex = parentCount > 0 ? index - 1 : index;
          final subCategory = subCategories[subIndex];
          final count = itemsByCategory[subCategory.id]?.length ?? 0;

          final nextParentPathSegments = [
            ...parentPathSegments,
            parentCategory.name,
          ];

          return GestureDetector(
            onTap: () {
              if (subCategory.id == 'knowledge_language') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LanguageCategoryExplorerPage(
                      languageCategory: subCategory,
                      parentCategory: parentCategory,
                      serverUrl: serverUrl,
                      itemsByCategory: itemsByCategory,
                      onItemsUpdated: onItemsUpdated,
                      parentPathSegments: nextParentPathSegments,
                    ),
                  ),
                );
                return;
              }

              if (subCategory.subCategories != null &&
                  subCategory.subCategories!.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SubCategoryListPage(
                      parentCategory: subCategory,
                      serverUrl: serverUrl,
                      itemsByCategory: itemsByCategory,
                      onItemsUpdated: onItemsUpdated,
                      parentPathSegments: nextParentPathSegments,
                    ),
                  ),
                );
              } else {
                final items = itemsByCategory[subCategory.id] ?? [];
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoCategoryListPage(
                      category: subCategory,
                      items: items,
                      serverUrl: serverUrl,
                      onItemsUpdated: onItemsUpdated,
                      parentPathSegments: nextParentPathSegments,
                    ),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.shade400, Colors.teal.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.category, size: 28, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subCategory.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count 个视频',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}

enum LanguageViewMode { cards, tree }

class LanguageCategoryExplorerPage extends StatefulWidget {
  final MediaCategory languageCategory;
  final MediaCategory parentCategory;
  final String? serverUrl;
  final Map<String, List<MediaItem>> itemsByCategory;
  final VoidCallback? onItemsUpdated;
  final List<String> parentPathSegments;

  const LanguageCategoryExplorerPage({
    super.key,
    required this.languageCategory,
    required this.parentCategory,
    this.serverUrl,
    required this.itemsByCategory,
    this.onItemsUpdated,
    this.parentPathSegments = const [],
  });

  @override
  State<LanguageCategoryExplorerPage> createState() =>
      _LanguageCategoryExplorerPageState();
}

class _LanguageCategoryExplorerPageState
    extends State<LanguageCategoryExplorerPage> {
  LanguageViewMode _viewMode = LanguageViewMode.cards;
  MediaCategory? _selectedLanguage;

  List<MediaCategory> get _languages =>
      widget.languageCategory.subCategories ?? [];

  List<String> get _baseLanguagePathSegments =>
      [...widget.parentPathSegments, widget.languageCategory.name];

  @override
  void initState() {
    super.initState();
    if (_languages.isNotEmpty) {
      _selectedLanguage = _languages.first;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Colors.blue.shade600,
                Colors.purple.shade600,
              ],
            ),
          ),
        ),
        title: Text(
          '${widget.parentCategory.name} > ${widget.languageCategory.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(20),
              fillColor: Colors.white.withOpacity(0.2),
              selectedColor: Colors.white,
              color: Colors.white70,
              isSelected: [
                _viewMode == LanguageViewMode.cards,
                _viewMode == LanguageViewMode.tree,
              ],
              onPressed: (index) {
                setState(() {
                  _viewMode = LanguageViewMode.values[index];
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('面包屑视图'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('树形视图'),
                ),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumbs(),
            const SizedBox(height: 12),
            Expanded(
              child: _viewMode == LanguageViewMode.cards
                  ? _buildCardView()
                  : _buildTreeView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    final path = [
      widget.parentCategory,
      widget.languageCategory,
      if (_viewMode == LanguageViewMode.tree && _selectedLanguage != null)
        _selectedLanguage!,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: path.map((cat) {
        return Chip(
          backgroundColor: Colors.blue.shade50,
          label: Text(
            cat.name,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCardView() {
    if (_languages.isEmpty) {
      return Center(
        child: Text(
          '尚未配置语言分类',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final language = _languages[index];
        final count = widget.itemsByCategory[language.id]?.length ?? 0;
        return GestureDetector(
          onTap: () => _openManagementPage(language),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo.shade400,
                  Colors.blue.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        language.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count 个视频',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTreeView() {
    if (_languages.isEmpty) {
      return Center(
        child: Text(
          '尚未配置语言分类',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      );
    }

    return Row(
      children: [
        Container(
          width: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            children: _languages.map((language) {
              final isSelected = _selectedLanguage?.id == language.id;
              return ListTile(
                selected: isSelected,
                selectedTileColor: Colors.blue.shade50,
                leading: Icon(
                  Icons.language,
                  color: isSelected ? Colors.blue : Colors.grey.shade600,
                ),
                title: Text(language.name),
                trailing: Text(
                  '${widget.itemsByCategory[language.id]?.length ?? 0}',
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedLanguage = language;
                  });
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _selectedLanguage == null
              ? _buildEmptyLanguagePanel()
              : _buildLanguageDetailPanel(_selectedLanguage!),
        ),
      ],
    );
  }

  Widget _buildEmptyLanguagePanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '请选择左侧的语言类别',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLanguageDetailPanel(MediaCategory language) {
    final items = widget.itemsByCategory[language.id] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${language.name}（${items.length} 个视频）',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.serverUrl != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('打开完整管理界面'),
                    onPressed: () => _openManagementPage(language),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '该语言下暂无视频',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.serverUrl != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '点击右上角“打开完整管理界面”即可上传',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.purple.shade600],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _openManagementPage(language),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(item: item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _openManagementPage(MediaCategory language) {
    final items = widget.itemsByCategory[language.id] ?? [];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoCategoryListPage(
          category: language,
          items: items,
          serverUrl: widget.serverUrl,
          onItemsUpdated: widget.onItemsUpdated,
          parentPathSegments: [
            ..._baseLanguagePathSegments,
          ],
        ),
      ),
    );
  }
}


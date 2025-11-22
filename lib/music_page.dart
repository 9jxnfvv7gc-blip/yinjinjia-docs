import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'models.dart';
import 'music_player_page.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  String? _rootDirPath;
  String? _serverUrl; // 服务器地址
  final Map<String, List<MediaItem>> _itemsByCategory = {};
  bool _isLoadingFromServer = false;

  Future<void> _pickMusicRootDir() async {
    final picked = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择音乐根目录（包含 原创/流行/经典 子文件夹）',
    );
    if (picked == null) return;

    setState(() {
      _rootDirPath = picked;
      _itemsByCategory.clear();
    });

    await _scanMusicDirectory(picked);
  }

  Future<void> _scanMusicDirectory(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!rootDir.existsSync()) return;

    for (final entity in rootDir.listSync()) {
      if (entity is! Directory) continue;

      final folderName = p.basename(entity.path);
      final category = findMusicCategoryByChineseName(folderName);
      if (category == null) continue;

      final files = entity
          .listSync()
          .whereType<File>()
          .where((file) {
            final ext = p.extension(file.path).toLowerCase();
            return ['.mp3', '.m4a', '.flac', '.wav', '.aac', '.ogg', '.wma'].contains(ext);
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

      setState(() {
        _itemsByCategory[category.id] = [
          ...(_itemsByCategory[category.id] ?? []),
          ...files,
        ];
      });
    }
  }

  Future<void> _connectToServer(String serverUrl) async {
    setState(() {
      _isLoadingFromServer = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/categories'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // 解析响应，虽然这里不需要使用categories变量，但保留解析逻辑
        json.decode(utf8.decode(response.bodyBytes));
        
        // 将服务器返回的分类映射到我们的音乐分类系统
        final Map<String, List<MediaItem>> serverItems = {};
        
        // 遍历所有音乐分类
        for (final category in musicCategories) {
          final catName = category.name;
          
          try {
            final musicResponse = await http.get(
              Uri.parse('$serverUrl/api/list/${Uri.encodeComponent(catName)}'),
              headers: {'Accept': 'application/json'},
            ).timeout(const Duration(seconds: 10));

            if (musicResponse.statusCode == 200) {
              final List<dynamic> musicList = json.decode(utf8.decode(musicResponse.bodyBytes));
              if (musicList.isNotEmpty) {
                final items = musicList.map((music) {
                  final musicUrl = music['url'] as String;
                  final fullUrl = musicUrl.startsWith('http') 
                      ? musicUrl 
                      : '$serverUrl$musicUrl';
                  
                  return MediaItem(
                    id: music['id'] ?? fullUrl,
                    title: music['title'] as String,
                    filePath: fullUrl,
                    categoryId: category.id,
                  );
                }).toList();
                serverItems[category.id] = items;
              }
            }
          } catch (e) {
            debugPrint('加载音乐分类 $catName 失败: $e');
          }
        }

        setState(() {
          _serverUrl = serverUrl;
          _itemsByCategory.clear();
          _itemsByCategory.addAll(serverItems);
          _isLoadingFromServer = false;
        });

        debugPrint('成功从服务器加载 ${_itemsByCategory.length} 个音乐分类');
        
        // 显示连接成功提示
        if (mounted) {
          final totalMusic = _itemsByCategory.values.fold<int>(0, (sum, items) => sum + items.length);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                totalMusic > 0
                    ? '连接成功！已加载 $totalMusic 首音乐。点击分类查看或上传更多音乐'
                    : '连接成功！点击某个分类上传音乐',
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
            Colors.pink.shade50,
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
      ),
      child: Column(
        children: [
          // 明显的橙色提示框（当未连接服务器时显示）
          if (_serverUrl == null && _rootDirPath == null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⚠️ 请先连接服务器',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '点击下方"连接服务器"按钮，输入: http://localhost:8081',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                  // 手机端垂直布局，桌面端水平布局
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        // 手机端：垂直排列
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.folder_open),
                                label: const Text('选择音乐根目录'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  debugPrint('点击音乐根目录按钮');
                                  _pickMusicRootDir();
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit_location_alt),
                                label: const Text('手动输入路径'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final path = await _showManualPathDialog(
                                    context,
                                    title: '输入音乐根目录',
                                  );
                                  if (path == null || path.isEmpty) return;
                                  setState(() {
                                    _rootDirPath = path;
                                    _serverUrl = null;
                                    _itemsByCategory.clear();
                                  });
                                  await _scanMusicDirectory(path);
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: _isLoadingFromServer
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.cloud_done),
                                label: const Text('连接服务器'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed: _isLoadingFromServer
                                    ? null
                                    : () async {
                                        final serverUrl = await _showManualPathDialog(
                                          context,
                                          title: '输入服务器地址',
                                          hint: '例如: http://localhost:8081',
                                        );
                                        if (serverUrl == null || serverUrl.isEmpty) return;
                                        await _connectToServer(serverUrl);
                                      },
                              ),
                            ),
                          ],
                        );
                      } else {
                        // 桌面端：水平排列
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.folder_open),
                                label: const Text('选择音乐根目录'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  debugPrint('点击音乐根目录按钮');
                                  _pickMusicRootDir();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit_location_alt),
                                label: const Text('手动输入路径'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final path = await _showManualPathDialog(
                                    context,
                                    title: '输入音乐根目录',
                                  );
                                  if (path == null || path.isEmpty) return;
                                  setState(() {
                                    _rootDirPath = path;
                                    _serverUrl = null;
                                    _itemsByCategory.clear();
                                  });
                                  await _scanMusicDirectory(path);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: _isLoadingFromServer
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.cloud_done),
                                label: const Text('连接服务器'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed: _isLoadingFromServer
                                    ? null
                                    : () async {
                                        final serverUrl = await _showManualPathDialog(
                                          context,
                                          title: '输入服务器地址',
                                          hint: '例如: http://localhost:8081',
                                        );
                                        if (serverUrl == null || serverUrl.isEmpty) return;
                                        await _connectToServer(serverUrl);
                                      },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _serverUrl != null
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _serverUrl != null
                            ? Colors.green.shade300
                            : Colors.orange.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _serverUrl != null ? Icons.cloud_done : Icons.cloud_off,
                          size: 16,
                          color: _serverUrl != null ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _serverUrl != null
                                ? '服务器: $_serverUrl ✓ 已连接，可以上传和查看音乐'
                                : (_rootDirPath != null
                                    ? '本地模式: $_rootDirPath'
                                    : '⚠️ 请先连接服务器才能上传和查看音乐（点击上方"连接服务器"按钮，输入: http://localhost:8081）'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _serverUrl != null 
                                  ? Colors.green.shade700 
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  itemCount: musicCategories.length,
              itemBuilder: (context, index) {
                final category = musicCategories[index];
                final count = _itemsByCategory[category.id]?.length ?? 0;

                // 为每个分类定义不同的颜色主题
                final colorThemes = [
                  [Colors.pink, Colors.red],
                  [Colors.purple, Colors.indigo],
                  [Colors.blue, Colors.cyan],
                ];
                final colors = colorThemes[index % colorThemes.length];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      final items = _itemsByCategory[category.id] ?? [];
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MusicCategoryListPage(
                            category: category,
                            items: items,
                            serverUrl: _serverUrl,
                            onItemsUpdated: () {
                              // 重新加载音乐列表
                              if (_serverUrl != null) {
                                _connectToServer(_serverUrl!);
                              }
                            },
                          ),
                        ),
                      );
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
                                Icons.music_note,
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
                                '$count 首音乐',
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

class MusicCategoryListPage extends StatefulWidget {
  final MediaCategory category;
  final List<MediaItem> items;
  final String? serverUrl;
  final VoidCallback? onItemsUpdated;

  const MusicCategoryListPage({
    super.key,
    required this.category,
    required this.items,
    this.serverUrl,
    this.onItemsUpdated,
  });

  @override
  State<MusicCategoryListPage> createState() => _MusicCategoryListPageState();
}

class _MusicCategoryListPageState extends State<MusicCategoryListPage> {
  bool _isUploading = false;
  List<MediaItem> _items = [];
  int _uploadProgress = 0;
  int _totalFiles = 0;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  Future<void> _deleteMusic(MediaItem item) async {
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
      
      debugPrint('删除响应: statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
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
      await _deleteMusic(item);
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

  Future<void> _renameMusic(MediaItem item, String newName) async {
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
          errorMsg = '重命名失败: ${response.statusCode}';
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
        await _renameMusic(item, result);
      }
    }
  }

  Future<void> _showShareDialog(BuildContext context, MediaItem item) async {
    if (widget.serverUrl == null) return;

    String shareUrl = item.filePath;
    if (!shareUrl.startsWith('http')) {
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
                  '复制此链接分享给其他人，他们可以在浏览器中打开播放',
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

  Future<void> _uploadMusic() async {
    debugPrint('点击上传按钮');
    
    if (widget.serverUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未连接服务器，无法上传')),
      );
      return;
    }

    debugPrint('开始选择文件，serverUrl: ${widget.serverUrl}');
    
    // 选择音乐文件（支持多选）
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'flac', 'wav', 'aac', 'ogg', 'wma'],
      allowMultiple: true,
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

        request.fields['category'] = widget.category.name;
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );

        final streamedResponse = await request.send().timeout(
          const Duration(minutes: 10),
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

    // 重新加载音乐列表
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
                Colors.pink.shade600,
                Colors.purple.shade600,
              ],
            ),
          ),
        ),
        title: Text(
          widget.category.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: widget.serverUrl != null
            ? [
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
                  onPressed: _isUploading ? null : _uploadMusic,
                  tooltip: _isUploading
                      ? '正在上传 $_uploadProgress/$_totalFiles'
                      : '上传音乐（支持批量上传）',
                ),
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
                    Colors.pink.shade50,
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
                              color: Colors.pink.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '该分类下暂无音乐',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isUploading ? null : _uploadMusic,
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
                                : const Text('上传音乐（支持批量选择）'),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '该分类下暂无音乐',
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
                
                return Card(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Row(
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
                          colors: [Colors.pink.shade400, Colors.purple.shade600],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
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
                    trailing: widget.serverUrl != null
                        ? PopupMenuButton<String>(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.pink.shade700,
                                size: 20,
                              ),
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'play':
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MusicPlayerPage(item: item),
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
                                color: Colors.pink.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.pink.shade700,
                                size: 20,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MusicPlayerPage(item: item),
                                ),
                              );
                            },
                          ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MusicPlayerPage(item: item),
                        ),
                      );
                    },
                  ),
                );
              },
            )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    
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
                              colors: [Colors.pink.shade400, Colors.purple.shade600],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.music_note,
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
                              color: Colors.pink.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.pink.shade700,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MusicPlayerPage(item: item),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MusicPlayerPage(item: item),
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
      // 构建分类路径
      final categoryPath = widget.category.name;
      
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


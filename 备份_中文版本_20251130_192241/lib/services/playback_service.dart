import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

/// 播放历史和播放列表服务
class PlaybackService {
  static const String _historyKey = 'playback_history';
  static const String _playlistsKey = 'playlists';
  static const int _maxHistoryItems = 100; // 最多保存100条历史记录

  /// 获取播放历史
  static Future<List<PlaybackHistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      return historyJson
          .map((json) => PlaybackHistoryItem.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 添加播放历史
  static Future<void> addToHistory(SimpleMediaItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      
      // 移除重复项（如果存在）
      history.removeWhere((h) => h.item.id == item.id);
      
      // 添加到开头
      history.insert(0, PlaybackHistoryItem(
        item: item,
        playedAt: DateTime.now(),
      ));
      
      // 限制历史记录数量
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }
      
      // 保存
      final historyJson = history
          .map((h) => jsonEncode(h.toJson()))
          .toList();
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 清除播放历史
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 获取所有播放列表
  static Future<List<Playlist>> getPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString(_playlistsKey);
      if (playlistsJson == null) return [];
      
      final List<dynamic> data = jsonDecode(playlistsJson);
      return data.map((json) => Playlist.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 创建播放列表
  static Future<Playlist> createPlaylist(String name) async {
    final playlists = await getPlaylists();
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      items: [],
      createdAt: DateTime.now(),
    );
    playlists.add(playlist);
    await _savePlaylists(playlists);
    return playlist;
  }

  /// 删除播放列表
  static Future<void> deletePlaylist(String playlistId) async {
    final playlists = await getPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists(playlists);
  }

  /// 向播放列表添加项目
  static Future<void> addToPlaylist(String playlistId, SimpleMediaItem item) async {
    final playlists = await getPlaylists();
    final playlist = playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => throw Exception('Playlist not found'),
    );
    
    // 检查是否已存在
    if (!playlist.items.any((i) => i.id == item.id)) {
      playlist.items.add(item);
      await _savePlaylists(playlists);
    }
  }

  /// 从播放列表移除项目
  static Future<void> removeFromPlaylist(String playlistId, String itemId) async {
    final playlists = await getPlaylists();
    final playlist = playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => throw Exception('Playlist not found'),
    );
    
    playlist.items.removeWhere((i) => i.id == itemId);
    await _savePlaylists(playlists);
  }

  /// 保存播放列表
  static Future<void> _savePlaylists(List<Playlist> playlists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = jsonEncode(
        playlists.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_playlistsKey, playlistsJson);
    } catch (e) {
      // 忽略错误
    }
  }
}

/// 播放历史项
class PlaybackHistoryItem {
  final SimpleMediaItem item;
  final DateTime playedAt;

  PlaybackHistoryItem({
    required this.item,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
    'item': {
      'id': item.id,
      'title': item.title,
      'url': item.url,
      'type': item.type,
    },
    'playedAt': playedAt.toIso8601String(),
  };

  factory PlaybackHistoryItem.fromJson(Map<String, dynamic> json) {
    final itemData = json['item'] as Map<String, dynamic>;
    return PlaybackHistoryItem(
      item: SimpleMediaItem(
        id: itemData['id'] as String,
        title: itemData['title'] as String,
        url: itemData['url'] as String,
        type: itemData['type'] as String,
      ),
      playedAt: DateTime.parse(json['playedAt'] as String),
    );
  }
}

/// 播放列表
class Playlist {
  final String id;
  final String name;
  final List<SimpleMediaItem> items;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((i) => {
      'id': i.id,
      'title': i.title,
      'url': i.url,
      'type': i.type,
    }).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List)
          .map((i) => SimpleMediaItem(
                id: i['id'] as String,
                title: i['title'] as String,
                url: i['url'] as String,
                type: i['type'] as String,
              ))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}


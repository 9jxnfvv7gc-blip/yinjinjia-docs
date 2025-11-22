import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'models.dart';

class MusicPlayerPage extends StatefulWidget {
  final MediaItem item;

  const MusicPlayerPage({super.key, required this.item});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late AudioPlayer _player;
  bool _isReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      // 判断是本地文件还是网络URL
      if (widget.item.filePath.startsWith('http://') || widget.item.filePath.startsWith('https://')) {
        // 网络URL
        await _player.setUrl(widget.item.filePath);
      } else {
        // 本地文件
        await _player.setFilePath(widget.item.filePath);
      }
      setState(() {
        _isReady = true;
      });
      _player.play();
    } catch (e) {
      setState(() {
        _error = '音频初始化失败: $e';
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
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
            : !_isReady
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 音乐图标（居中）
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 歌曲标题（居中）
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          widget.item.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 播放/暂停按钮（居中）
                      StreamBuilder<PlayerState>(
                        stream: _player.playerStateStream,
                        builder: (context, snapshot) {
                          final playing = snapshot.data?.playing ?? false;
                          return IconButton(
                            iconSize: 80,
                            icon: Icon(
                              playing ? Icons.pause_circle : Icons.play_circle,
                              color: Colors.purple.shade700,
                            ),
                            onPressed: () {
                              if (playing) {
                                _player.pause();
                              } else {
                                _player.play();
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // 进度条（居中，宽度限制）
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: StreamBuilder<Duration>(
                          stream: _player.positionStream,
                          builder: (context, positionSnapshot) {
                            final position = positionSnapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration?>(
                              stream: _player.durationStream,
                              builder: (context, durationSnapshot) {
                                final duration = durationSnapshot.data ?? Duration.zero;
                                return Column(
                                  children: [
                                    // 进度条
                                    Slider(
                                      value: position.inMilliseconds.toDouble(),
                                      min: 0,
                                      max: duration.inMilliseconds > 0
                                          ? duration.inMilliseconds.toDouble()
                                          : 100,
                                      onChanged: (value) {
                                        _player.seek(Duration(milliseconds: value.toInt()));
                                      },
                                      activeColor: Colors.purple.shade700,
                                    ),
                                    // 时间显示（居中）
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(position),
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(duration),
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}



#!/usr/bin/env python3
"""
测试API逻辑，检查为什么返回空数组
"""
import os
import json

VIDEO_ROOT = '/root/videos'
category = '原创视频'
category_path = os.path.join(VIDEO_ROOT, category)

print(f"category_path: {category_path}")
print(f"路径存在: {os.path.exists(category_path)}")

videos = []
file_list = []

if os.path.exists(category_path):
    print("目录存在，开始扫描文件...")
    
    # 视频扩展名
    video_extensions = ['.mp4', '.mov', '.mkv', '.avi', '.flv', '.wmv', '.webm']
    # 音频扩展名
    audio_extensions = ['.mp3', '.wav', '.flac', '.aac', '.m4a', '.ogg', '.wma']
    # 所有媒体扩展名
    all_media_extensions = video_extensions + audio_extensions
    
    files = os.listdir(category_path)
    print(f"文件数量: {len(files)}")
    
    for f in files:
        file_path = os.path.join(category_path, f)
        if os.path.isfile(file_path):
            ext = os.path.splitext(f)[1].lower()
            print(f"文件: {f}, 扩展名: {ext}, 在列表中: {ext in all_media_extensions}")
            
            if ext in all_media_extensions:
                # 构建URL
                relative_path = os.path.relpath(file_path, VIDEO_ROOT)
                url = f"http://47.243.177.166:8081/{relative_path.replace(os.sep, '/')}"
                
                file_list.append({
                    'title': f,
                    'url': url,
                    'id': f
                })
                print(f"  添加到file_list: {f}")
    
    print(f"file_list长度: {len(file_list)}")
    print(f"file_list内容: {file_list}")
    
    # 构建返回结果
    for item in file_list:
        videos.append({
            'title': item['title'],
            'url': item['url'],
            'id': item['id']
        })
    
    print(f"videos长度: {len(videos)}")
    print(f"videos内容: {videos}")
    
    # 返回JSON
    result = json.dumps(videos, ensure_ascii=False)
    print(f"JSON结果: {result}")
else:
    print(f"目录不存在: {category_path}")

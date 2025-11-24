#!/usr/bin/env python3
"""
简单的视频服务器
在你的电脑上运行这个脚本，把你的视频目录分享到网络上
其他人就可以通过你的 IP 地址访问这些视频
"""

import http.server
import socketserver
import os
import json
import cgi
import shutil
import socket
import re
from urllib.parse import unquote, parse_qs
import tempfile

PORT = 8081
VIDEO_ROOT = os.environ.get("VIDEO_ROOT", "/root/videos")  # 默认 /root/videos，亦可用环境变量覆盖

class VideoHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # 允许跨域访问，这样 Flutter App 可以从任何地方访问
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.send_header('Access-Control-Max-Age', '3600')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_POST(self):
        if self.path == '/api/upload':
            # 处理文件上传
            try:
                # 解析 multipart/form-data
                form = cgi.FieldStorage(
                    fp=self.rfile,
                    headers=self.headers,
                    environ={'REQUEST_METHOD': 'POST',
                            'CONTENT_TYPE': self.headers['Content-Type']}
                )
                
                # 获取分类名称
                if 'category' not in form:
                    self.send_error(400, "Missing category parameter")
                    return
                
                category_name = form['category'].value
                
                # 获取上传的文件
                if 'file' not in form:
                    self.send_error(400, "Missing file parameter")
                    return
                
                file_item = form['file']
                if not file_item.filename:
                    self.send_error(400, "No file selected")
                    return
                
                filename = os.path.basename(file_item.filename)
                
                # 确保分类文件夹存在（支持二级分类：父分类/子分类）
                # 如果 category_name 包含 "/"，说明是二级分类
                if '/' in category_name:
                    # 二级分类：父分类/子分类
                    category_path = os.path.join(VIDEO_ROOT, category_name)
                else:
                    # 一级分类
                    category_path = os.path.join(VIDEO_ROOT, category_name)
                
                if not os.path.exists(category_path):
                    os.makedirs(category_path, exist_ok=True)
                    print(f"创建分类文件夹: {category_path}")
                
                # 保存文件
                file_path = os.path.join(category_path, filename)
                with open(file_path, 'wb') as f:
                    file_data = file_item.file.read()
                    f.write(file_data)
                
                file_size = os.path.getsize(file_path)
                print(f"成功上传文件: {file_path} ({file_size} 字节)")
                
                # 返回成功响应
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {
                    'success': True,
                    'message': '文件上传成功',
                    'filename': filename,
                    'category': category_name,
                    'size': file_size
                }
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
                
            except Exception as e:
                import traceback
                print(f"上传错误: {e}")
                traceback.print_exc()
                self.send_error(500, f"Upload failed: {str(e)}")
        elif self.path == '/api/move':
            # 处理文件移动
            try:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                source_path = data.get('source_path')
                target_category = data.get('target_category')
                
                if not source_path or not target_category:
                    self.send_error(400, "Missing source_path or target_category")
                    return
                
                # 解析源文件路径（可能是相对路径或绝对路径）
                print(f"收到移动请求: source_path={source_path}, target_category={target_category}")
                
                if source_path.startswith('/video/'):
                    # 从 URL 路径转换为文件系统路径
                    relative_path = source_path.replace('/video/', '')
                    source_file = os.path.join(VIDEO_ROOT, unquote(relative_path))
                elif source_path.startswith(VIDEO_ROOT):
                    source_file = source_path
                else:
                    # 假设是相对路径（去掉开头的 /）
                    if source_path.startswith('/'):
                        source_path = source_path[1:]
                    source_file = os.path.join(VIDEO_ROOT, unquote(source_path))
                
                # 标准化路径（处理 .. 和 .）
                source_file = os.path.normpath(source_file)
                print(f"解析后的源文件路径: {source_file}")
                
                if not os.path.exists(source_file) or not os.path.isfile(source_file):
                    print(f"源文件不存在: {source_file}")
                    self.send_error(404, f"Source file not found: {source_file}")
                    return
                
                # 构建目标路径
                if '/' in target_category:
                    target_path = os.path.join(VIDEO_ROOT, target_category)
                else:
                    target_path = os.path.join(VIDEO_ROOT, target_category)
                
                if not os.path.exists(target_path):
                    os.makedirs(target_path, exist_ok=True)
                    print(f"创建目标分类文件夹: {target_path}")
                
                # 移动文件
                filename = os.path.basename(source_file)
                target_file = os.path.join(target_path, filename)
                
                # 如果目标文件已存在，添加序号
                counter = 1
                original_target = target_file
                while os.path.exists(target_file):
                    name, ext = os.path.splitext(filename)
                    target_file = os.path.join(target_path, f"{name}_{counter}{ext}")
                    counter += 1
                
                shutil.move(source_file, target_file)
                print(f"成功移动文件: {source_file} -> {target_file}")
                
                # 返回成功响应
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {
                    'success': True,
                    'message': '文件移动成功',
                    'new_path': os.path.relpath(target_file, VIDEO_ROOT)
                }
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
                
            except Exception as e:
                import traceback
                print(f"移动文件错误: {e}")
                traceback.print_exc()
                self.send_error(500, f"Move failed: {str(e)}")
        elif self.path == '/api/delete':
            # 处理文件删除
            try:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                file_path = data.get('file_path')
                
                if not file_path:
                    self.send_error(400, "Missing file_path")
                    return
                
                # 解析文件路径（可能是相对路径或绝对路径）
                print(f"收到删除请求: file_path={file_path}")
                
                if file_path.startswith('/video/') or file_path.startswith('/music/'):
                    # 从 URL 路径转换为文件系统路径
                    relative_path = file_path.replace('/video/', '').replace('/music/', '')
                    target_file = os.path.join(VIDEO_ROOT, unquote(relative_path))
                elif file_path.startswith(VIDEO_ROOT):
                    target_file = file_path
                else:
                    # 假设是相对路径（去掉开头的 /）
                    if file_path.startswith('/'):
                        file_path = file_path[1:]
                    target_file = os.path.join(VIDEO_ROOT, unquote(file_path))
                
                # 标准化路径（处理 .. 和 .）
                target_file = os.path.normpath(target_file)
                
                # 安全检查：确保文件在 VIDEO_ROOT 目录下
                if not target_file.startswith(os.path.abspath(VIDEO_ROOT)):
                    print(f"安全错误：尝试删除 VIDEO_ROOT 外的文件: {target_file}")
                    self.send_error(403, "Access denied")
                    return
                
                print(f"解析后的文件路径: {target_file}")
                
                if not os.path.exists(target_file) or not os.path.isfile(target_file):
                    print(f"文件不存在: {target_file}")
                    self.send_error(404, f"File not found: {target_file}")
                    return
                
                # 删除文件
                os.remove(target_file)
                print(f"成功删除文件: {target_file}")
                
                # 返回成功响应
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {
                    'success': True,
                    'message': '文件删除成功'
                }
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
                
            except Exception as e:
                import traceback
                print(f"删除文件错误: {e}")
                traceback.print_exc()
                self.send_error(500, f"Delete failed: {str(e)}")
        elif self.path == '/api/info':
            # 获取文件信息
            try:
                query_params = parse_qs(self.path.split('?')[1] if '?' in self.path else '')
                file_path = query_params.get('file_path', [None])[0]
                
                if not file_path:
                    self.send_error(400, "Missing file_path parameter")
                    return
                
                # 解析文件路径
                if file_path.startswith('/video/') or file_path.startswith('/music/'):
                    relative_path = file_path.replace('/video/', '').replace('/music/', '')
                    target_file = os.path.join(VIDEO_ROOT, unquote(relative_path))
                elif file_path.startswith(VIDEO_ROOT):
                    target_file = file_path
                else:
                    if file_path.startswith('/'):
                        file_path = file_path[1:]
                    target_file = os.path.join(VIDEO_ROOT, unquote(file_path))
                
                target_file = os.path.normpath(target_file)
                
                if not os.path.exists(target_file) or not os.path.isfile(target_file):
                    self.send_error(404, "File not found")
                    return
                
                # 获取文件信息
                file_size = os.path.getsize(target_file)
                file_stat = os.stat(target_file)
                
                import datetime
                created_time = datetime.datetime.fromtimestamp(file_stat.st_ctime).strftime('%Y-%m-%d %H:%M:%S')
                modified_time = datetime.datetime.fromtimestamp(file_stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
                
                # 格式化文件大小
                def format_size(size):
                    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
                        if size < 1024.0:
                            return f"{size:.2f} {unit}"
                        size /= 1024.0
                    return f"{size:.2f} PB"
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {
                    'success': True,
                    'filename': os.path.basename(target_file),
                    'size': file_size,
                    'size_formatted': format_size(file_size),
                    'created_time': created_time,
                    'modified_time': modified_time,
                    'path': os.path.relpath(target_file, VIDEO_ROOT)
                }
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
                
            except Exception as e:
                import traceback
                print(f"获取文件信息错误: {e}")
                traceback.print_exc()
                self.send_error(500, f"Get info failed: {str(e)}")
        elif self.path == '/api/rename':
            # 处理文件重命名
            try:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                file_path = data.get('file_path')
                new_name = data.get('new_name')
                
                if not file_path or not new_name:
                    self.send_error(400, "Missing file_path or new_name")
                    return
                
                # 解析文件路径
                print(f"收到重命名请求: file_path={file_path}, new_name={new_name}")
                
                # 尝试多种路径格式
                target_file = None
                
                # 方法1: URL路径格式 (/video/... 或 /music/...)
                if file_path.startswith('/video/') or file_path.startswith('/music/'):
                    relative_path = file_path.replace('/video/', '').replace('/music/', '')
                    target_file = os.path.join(VIDEO_ROOT, unquote(relative_path))
                    print(f"方法1解析: {target_file}")
                
                # 方法2: 绝对路径
                elif file_path.startswith(VIDEO_ROOT):
                    target_file = file_path
                    print(f"方法2解析: {target_file}")
                
                # 方法3: 相对路径
                else:
                    if file_path.startswith('/'):
                        file_path = file_path[1:]
                    target_file = os.path.join(VIDEO_ROOT, unquote(file_path))
                    print(f"方法3解析: {target_file}")
                
                target_file = os.path.normpath(target_file)
                print(f"标准化后路径: {target_file}")
                print(f"VIDEO_ROOT: {os.path.abspath(VIDEO_ROOT)}")
                
                # 安全检查
                abs_video_root = os.path.abspath(VIDEO_ROOT)
                abs_target_file = os.path.abspath(target_file)
                
                if not abs_target_file.startswith(abs_video_root):
                    print(f"安全错误：尝试重命名 VIDEO_ROOT 外的文件")
                    print(f"  VIDEO_ROOT: {abs_video_root}")
                    print(f"  target_file: {abs_target_file}")
                    self.send_error(403, "Access denied")
                    return
                
                if not os.path.exists(target_file):
                    print(f"文件不存在: {target_file}")
                    print(f"目录是否存在: {os.path.exists(os.path.dirname(target_file))}")
                    if os.path.exists(os.path.dirname(target_file)):
                        print(f"目录内容: {os.listdir(os.path.dirname(target_file))}")
                    self.send_error(404, f"File not found: {target_file}")
                    return
                
                if not os.path.isfile(target_file):
                    print(f"不是文件: {target_file}")
                    self.send_error(404, "Not a file")
                    return
                
                # 获取原文件扩展名
                _, ext = os.path.splitext(target_file)
                # 确保新文件名包含扩展名
                if not new_name.endswith(ext):
                    new_name = new_name + ext
                
                # 构建新文件路径
                new_file = os.path.join(os.path.dirname(target_file), new_name)
                
                # 检查新文件名是否已存在
                if os.path.exists(new_file):
                    self.send_error(409, "File with this name already exists")
                    return
                
                # 重命名文件
                os.rename(target_file, new_file)
                print(f"成功重命名文件: {target_file} -> {new_file}")
                
                # 返回成功响应
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {
                    'success': True,
                    'message': '文件重命名成功',
                    'new_path': os.path.relpath(new_file, VIDEO_ROOT),
                    'new_name': new_name
                }
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
                
            except Exception as e:
                import traceback
                print(f"重命名文件错误: {e}")
                traceback.print_exc()
                self.send_error(500, f"Rename failed: {str(e)}")
        elif self.path == '/api/batch_rename':
            # 处理批量重命名
            try:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                rename_list = data.get('rename_list', [])
                
                if not rename_list:
                    self.send_error(400, "Missing rename_list")
                    return
                
                results = []
                success_count = 0
                fail_count = 0
                
                for item in rename_list:
                    file_path = item.get('file_path')
                    new_name = item.get('new_name')
                    
                    if not file_path or not new_name:
                        results.append({
                            'file_path': file_path,
                            'success': False,
                            'error': 'Missing file_path or new_name'
                        })
                        fail_count += 1
                        continue
                    
                    try:
                        # 解析文件路径（使用与单个重命名相同的逻辑）
                        target_file = None
                        
                        if file_path.startswith('/video/') or file_path.startswith('/music/'):
                            relative_path = file_path.replace('/video/', '').replace('/music/', '')
                            target_file = os.path.join(VIDEO_ROOT, unquote(relative_path))
                        elif file_path.startswith(VIDEO_ROOT):
                            target_file = file_path
                        else:
                            if file_path.startswith('/'):
                                file_path = file_path[1:]
                            target_file = os.path.join(VIDEO_ROOT, unquote(file_path))
                        
                        target_file = os.path.normpath(target_file)
                        
                        # 安全检查
                        if not os.path.abspath(target_file).startswith(os.path.abspath(VIDEO_ROOT)):
                            results.append({
                                'file_path': file_path,
                                'success': False,
                                'error': 'Access denied'
                            })
                            fail_count += 1
                            continue
                        
                        if not os.path.exists(target_file) or not os.path.isfile(target_file):
                            results.append({
                                'file_path': file_path,
                                'success': False,
                                'error': 'File not found'
                            })
                            fail_count += 1
                            continue
                        
                        # 获取原文件扩展名
                        _, ext = os.path.splitext(target_file)
                        if not new_name.endswith(ext):
                            new_name = new_name + ext
                        
                        # 构建新文件路径
                        new_file = os.path.join(os.path.dirname(target_file), new_name)
                        
                        # 检查新文件名是否已存在
                        if os.path.exists(new_file):
                            results.append({
                                'file_path': file_path,
                                'success': False,
                                'error': 'File with this name already exists'
                            })
                            fail_count += 1
                            continue
                        
                        # 重命名文件
                        os.rename(target_file, new_file)
                        print(f"成功重命名文件: {target_file} -> {new_file}")
                        
                        results.append({
                            'file_path': file_path,
                            'success': True,
                            'new_path': os.path.relpath(new_file, VIDEO_ROOT),
                            'new_name': new_name
                        })
                        success_count += 1
                        
                    except Exception as e:
                        print(f"批量重命名单个文件错误: {file_path} - {e}")
                        results.append({
                            'file_path': file_path,
                            'success': False,
                            'error': str(e)
                        })
                        fail_count += 1
                
                # 返回结果
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {
                    'success': True,
                    'message': f'批量重命名完成：成功 {success_count} 个，失败 {fail_count} 个',
                    'success_count': success_count,
                    'fail_count': fail_count,
                    'results': results
                }
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
                
            except Exception as e:
                import traceback
                print(f"批量重命名错误: {e}")
                traceback.print_exc()
                self.send_error(500, f"Batch rename failed: {str(e)}")
        elif self.path == '/api/save_order':
            # 保存文件排序顺序
            try:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                category = data.get('category')
                file_order = data.get('file_order', [])  # 文件ID列表，按顺序
                
                if not category:
                    self.send_error(400, "Missing category")
                    return
                
                # 保存排序到JSON文件
                order_file = os.path.join(VIDEO_ROOT, '.file_orders.json')
                orders = {}
                if os.path.exists(order_file):
                    try:
                        with open(order_file, 'r', encoding='utf-8') as f:
                            orders = json.load(f)
                    except:
                        orders = {}
                
                orders[category] = file_order
                
                with open(order_file, 'w', encoding='utf-8') as f:
                    json.dump(orders, f, ensure_ascii=False, indent=2)
                
                print(f"保存排序顺序: {category} - {len(file_order)} 个文件")
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {'success': True, 'message': '排序已保存'}
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
                
            except Exception as e:
                import traceback
                print(f"保存排序错误: {e}")
                traceback.print_exc()
                self.send_error(500, f"Save order failed: {str(e)}")
        else:
            self.send_error(404, "Not found")

    def do_GET(self):
        if self.path == '/api/categories':
            # 返回分类列表（即使文件夹不存在也返回所有分类）
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            # 定义所有分类（视频+音乐）
            all_categories = ['纪录片', '科技', '音乐', '少儿', '电影', '学堂', '生活', '艺术', '育儿', '知识', '时尚',
                            '原创', '流行', '经典']  # 音乐分类
            
            categories = []
            # 获取实际存在的文件夹
            existing_folders = set()
            if os.path.exists(VIDEO_ROOT):
                for item in os.listdir(VIDEO_ROOT):
                    item_path = os.path.join(VIDEO_ROOT, item)
                    if os.path.isdir(item_path):
                        existing_folders.add(item)
            
            # 为每个分类创建条目
            for cat_name in all_categories:
                if cat_name in existing_folders:
                    # 统计该分类下的媒体文件数（视频+音乐）
                    cat_path = os.path.join(VIDEO_ROOT, cat_name)
                    video_extensions = ['.mp4', '.mov', '.mkv', '.avi', '.rmvb', '.rm', '.wmv', '.flv', '.f4v', '.m4v', 
                                       '.mpg', '.mpeg', '.3gp', '.webm', '.ts', '.mts', '.vob', '.divx', '.xvid']
                    music_extensions = ['.mp3', '.m4a', '.flac', '.wav', '.aac', '.ogg', '.wma']
                    all_media_extensions = video_extensions + music_extensions
                    count = sum(1 for f in os.listdir(cat_path) 
                              if os.path.isfile(os.path.join(cat_path, f)) 
                              and os.path.splitext(f)[1].lower() in all_media_extensions)
                else:
                    # 文件夹不存在，视频数为 0
                    count = 0
                
                categories.append({
                    'name': cat_name,
                    'id': cat_name,
                    'count': count
                })
            
            self.wfile.write(json.dumps(categories, ensure_ascii=False).encode('utf-8'))
            
        elif self.path.startswith('/api/list/'):
            # 返回某个分类下的视频列表（支持二级分类：父分类/子分类）
            import sys
            # 获取原始路径
            raw_category = self.path.replace('/api/list/', '')
            # 尝试解码（可能已经编码，也可能没有）
            try:
                # 先尝试解码（如果已经编码）
                category = unquote(raw_category)
                # 如果解码后和原始相同，说明没有编码，直接使用
                if category == raw_category:
                    category = raw_category
            except:
                # 如果解码失败，直接使用原始值
                category = raw_category
            
            # 支持二级分类路径（包含 "/"）
            category_path = os.path.join(VIDEO_ROOT, category)
            
            # 调试信息（使用sys.stderr确保输出到日志）
            sys.stderr.write(f"原始路径: {self.path}\n")
            sys.stderr.write(f"原始category: {raw_category}\n")
            sys.stderr.write(f"解码后category: {category}\n")
            sys.stderr.write(f"API列表请求: category={category}, category_path={category_path}\n")
            sys.stderr.write(f"VIDEO_ROOT: {VIDEO_ROOT}\n")
            sys.stderr.write(f"路径存在: {os.path.exists(category_path)}\n")
            sys.stderr.flush()
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            videos = []
            video_extensions = ['.mp4', '.mov', '.mkv', '.avi', '.rmvb', '.rm', '.wmv', '.flv', '.f4v', '.m4v', 
                               '.mpg', '.mpeg', '.3gp', '.webm', '.ts', '.mts', '.vob', '.divx', '.xvid']
            music_extensions = ['.mp3', '.flac', '.wav', '.aac', '.ogg', '.wma']  # 移除m4a，因为无法播放
            all_media_extensions = video_extensions + music_extensions
            
            if os.path.exists(category_path):
                sys.stderr.write(f"目录存在，开始扫描文件...\n")
                sys.stderr.flush()
                file_list = []
                for f in os.listdir(category_path):
                    file_path = os.path.join(category_path, f)
                    if os.path.isfile(file_path):
                        ext = os.path.splitext(f)[1].lower()
                        sys.stderr.write(f"文件: {f}, 扩展名: {ext}, 在列表中: {ext in all_media_extensions}\n")
                        sys.stderr.flush()
                        if ext in all_media_extensions:
                            # 获取文件修改时间（上传时间）
                            file_stat = os.stat(file_path)
                            modified_time = file_stat.st_mtime
                            
                            # 生成媒体文件的 URL（相对于服务器根目录）
                            relative_path = os.path.relpath(file_path, VIDEO_ROOT)
                            # 根据文件类型选择 URL 前缀
                            url_prefix = '/music/' if ext in music_extensions else '/video/'
                            
                            # 使用完整文件名作为title
                            title = f
                            
                            # 构建完整的URL（使用服务器IP）
                            # 获取服务器IP（从请求头或使用默认值）
                            server_host = self.headers.get('Host', '47.243.177.166:8081')
                            # 如果Host是localhost，使用服务器IP
                            if 'localhost' in server_host or '127.0.0.1' in server_host:
                                server_host = '47.243.177.166:8081'
                            if ':' not in server_host:
                                server_host = f"{server_host}:8081"
                            # 使用url_prefix构建完整URL
                            full_url = f"http://{server_host}{url_prefix}{relative_path.replace(os.sep, '/')}"
                            
                            file_list.append({
                                'title': title,
                                'url': full_url,
                                'id': f,  # 使用文件名作为id
                                'filename': f,
                                'modified_time': modified_time
                            })
                
                sys.stderr.write(f"找到 {len(file_list)} 个文件\n")
                sys.stderr.write(f"file_list内容: {file_list}\n")
                sys.stderr.write(f"videos长度（添加前）: {len(videos)}\n")
                sys.stderr.flush()
                
                # 尝试加载保存的排序顺序
                order_file = os.path.join(VIDEO_ROOT, '.file_orders.json')
                saved_order = None
                if os.path.exists(order_file):
                    try:
                        with open(order_file, 'r', encoding='utf-8') as f:
                            orders = json.load(f)
                            saved_order = orders.get(category)
                    except:
                        pass
                
                if saved_order:
                    # 使用保存的排序顺序
                    file_dict = {item['id']: item for item in file_list}
                    ordered_list = []
                    for file_id in saved_order:
                        if file_id in file_dict:
                            ordered_list.append(file_dict[file_id])
                    # 添加不在排序列表中的新文件（按修改时间排序）
                    remaining = [item for item in file_list if item['id'] not in saved_order]
                    remaining.sort(key=lambda x: x['modified_time'])
                    ordered_list.extend(remaining)
                    file_list = ordered_list
                else:
                    # 使用智能排序
                    def smart_sort_key(item):
                        title = item['title']
                        modified_time = item['modified_time']
                        
                        # 提取文件名中的数字序号（支持中文和阿拉伯数字）
                        
                        # 先尝试提取中文数字（一、二、三... 或 第一、第二...）
                        chinese_nums = {'一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, 
                                       '七': 7, '八': 8, '九': 9, '十': 10, '百': 100, '千': 1000}
                        primary_num = None
                        
                        # 查找"第X"或"第XX"模式
                        match = re.search(r'第([一二三四五六七八九十百千万\d]+)', title)
                        if match:
                            num_str = match.group(1)
                            # 如果是中文数字，转换
                            if num_str in chinese_nums:
                                primary_num = chinese_nums[num_str]
                            elif num_str.isdigit():
                                primary_num = int(num_str)
                            else:
                                # 尝试解析中文数字（如"十二"）
                                num = 0
                                for char in num_str:
                                    if char in chinese_nums:
                                        if char == '十':
                                            num = 10 if num == 0 else num * 10
                                        else:
                                            num += chinese_nums[char]
                                primary_num = num if num > 0 else None
                        
                        # 如果没有找到"第X"模式，查找所有数字
                        if primary_num is None:
                            numbers = re.findall(r'\d+', title)
                            primary_num = int(numbers[0]) if numbers else 999999
                        else:
                            # 确保 primary_num 是整数
                            primary_num = int(primary_num) if primary_num is not None else 999999
                        
                        # 课程类型排序：楷书 < 行书 < 绘画 < 其他
                        # 检查关键字（按优先级）
                        if '楷书' in title or '楷' in title or '楷体' in title:
                            course_type = 1
                        elif '行书' in title or '行' in title or '行体' in title:
                            course_type = 2
                        elif '绘画' in title or '画' in title or '美术' in title:
                            course_type = 3
                        else:
                            course_type = 4
                        
                        # 排序键：(课程类型, 序号, 修改时间)
                        # 修改时间小的（早的）排在前面，新上传的排在后面
                        return (course_type, primary_num, modified_time)
                    
                    # 对文件列表进行排序
                    file_list.sort(key=smart_sort_key)
                
                # 构建返回结果（去掉临时字段）
                for item in file_list:
                    videos.append({
                        'title': item['title'],
                        'url': item['url'],
                        'id': item['id']
                    })
                sys.stderr.write(f"videos长度（添加后）: {len(videos)}\n")
                sys.stderr.write(f"videos内容: {videos}\n")
                sys.stderr.flush()
            else:
                sys.stderr.write(f"目录不存在: {category_path}\n")
                sys.stderr.flush()
            
            sys.stderr.write(f"最终返回videos长度: {len(videos)}\n")
            sys.stderr.flush()
            self.wfile.write(json.dumps(videos, ensure_ascii=False).encode('utf-8'))
            
        elif self.path.startswith('/video/') or self.path.startswith('/music/'):
            # 提供视频或音乐文件流
            media_path = self.path.replace('/video/', '').replace('/music/', '')
            full_path = os.path.join(VIDEO_ROOT, unquote(media_path))
            
            if os.path.exists(full_path) and os.path.isfile(full_path):
                self.send_response(200)
                # 支持媒体文件流式传输
                ext = os.path.splitext(full_path)[1].lower()
                content_type = {
                    # 视频格式
                    '.mp4': 'video/mp4',
                    '.mov': 'video/quicktime',
                    '.mkv': 'video/x-matroska',
                    '.avi': 'video/x-msvideo',
                    '.rmvb': 'video/vnd.rn-realvideo',
                    '.rm': 'video/vnd.rn-realvideo',
                    '.wmv': 'video/x-ms-wmv',
                    '.flv': 'video/x-flv',
                    '.f4v': 'video/x-f4v',
                    '.m4v': 'video/x-m4v',
                    '.mpg': 'video/mpeg',
                    '.mpeg': 'video/mpeg',
                    '.3gp': 'video/3gpp',
                    '.webm': 'video/webm',
                    '.ts': 'video/mp2t',
                    '.mts': 'video/mp2t',
                    '.vob': 'video/dvd',
                    '.divx': 'video/x-divx',
                    '.xvid': 'video/x-divx',
                    # 音乐格式
                    '.mp3': 'audio/mpeg',
                    '.m4a': 'audio/mp4',
                    '.flac': 'audio/flac',
                    '.wav': 'audio/wav',
                    '.aac': 'audio/aac',
                    '.ogg': 'audio/ogg',
                    '.wma': 'audio/x-ms-wma',
                }.get(ext, 'application/octet-stream')
                self.send_header('Content-type', content_type)
                self.send_header('Accept-Ranges', 'bytes')
                
                # 支持范围请求（视频/音频拖动）
                range_header = self.headers.get('Range', '')
                file_size = os.path.getsize(full_path)
                
                if range_header:
                    # 解析范围请求
                    range_match = range_header.replace('bytes=', '').split('-')
                    start = int(range_match[0]) if range_match[0] else 0
                    end = int(range_match[1]) if range_match[1] else file_size - 1
                    
                    self.send_response(206)  # Partial Content
                    self.send_header('Content-Range', f'bytes {start}-{end}/{file_size}')
                    self.send_header('Content-Length', str(end - start + 1))
                    self.end_headers()
                    
                    with open(full_path, 'rb') as f:
                        f.seek(start)
                        self.wfile.write(f.read(end - start + 1))
                else:
                    # 完整文件
                    self.send_header('Content-Length', str(file_size))
                    self.end_headers()
                    with open(full_path, 'rb') as f:
                        self.wfile.write(f.read())
            else:
                self.send_error(404, "File not found")
        else:
            # 返回简单的 HTML 说明页面
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            html = f"""
            <html>
            <head><title>视频服务器</title></head>
            <body>
                <h1>视频服务器运行中</h1>
                <p>服务器端口: {PORT}</p>
                <p>视频根目录: {VIDEO_ROOT}</p>
                <p>API 端点:</p>
                <ul>
                    <li><a href="/api/categories">/api/categories</a> - 获取分类列表</li>
                    <li>/api/list/分类名 - 获取某个分类下的视频列表</li>
                </ul>
            </body>
            </html>
            """
            self.wfile.write(html.encode('utf-8'))


if __name__ == "__main__":
    # 修改这里的路径为你实际的视频根目录
    if len(os.sys.argv) > 1:
        VIDEO_ROOT = os.sys.argv[1]
    
    # 获取本机 IP 地址
    import socket
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
    except:
        local_ip = "192.168.1.100"  # 默认IP
    
    print(f"启动视频服务器...")
    print(f"端口: {PORT}")
    print(f"视频根目录: {VIDEO_ROOT}")
    print(f"\n访问 http://localhost:{PORT} 查看服务器状态")
    print(f"在 Flutter App 中输入服务器地址: http://{local_ip}:{PORT}")
    print(f"\n按 Ctrl+C 停止服务器")
    
    with socketserver.TCPServer(("", PORT), VideoHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n服务器已停止")


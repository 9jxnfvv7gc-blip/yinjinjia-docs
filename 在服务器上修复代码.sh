#!/bin/bash
# 在服务器上修复video_server.py的返回格式

# 备份文件
cp /root/video_server/video_server.py /root/video_server/video_server.py.bak10

# 修改第680-688行：修复title和url格式
sed -i '680,688c\
                            # 使用完整文件名作为title\
                            title = f\
                            \
                            # 构建完整的URL（使用服务器IP）\
                            # 获取服务器IP（从请求头或使用默认值）\
                            server_host = self.headers.get("Host", "47.243.177.166:8081")\
                            if ":" not in server_host:\
                                server_host = f"{server_host}:8081"\
                            full_url = f"http://{server_host}/{relative_path.replace(os.sep, "/")}"' /root/video_server/video_server.py

# 修改第690-694行：修复file_list.append
sed -i '690,694c\
                            file_list.append({\
                                "title": title,\
                                "url": full_url,\
                                "id": f,  # 使用文件名作为id\
                                "filename": f,\
                                "modified_time": modified_time\
                            })' /root/video_server/video_server.py

# 检查语法
python3 -m py_compile /root/video_server/video_server.py && echo "✅ 语法检查通过" || echo "❌ 语法错误"

echo "✅ 代码修改完成！"


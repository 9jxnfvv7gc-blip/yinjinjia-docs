# 部署HTML文件说明

## 📄 文件位置

- `terms-of-service.html` - 用户协议页面
- `privacy-policy.html` - 隐私政策页面

## 🚀 部署方案

### 方案1：部署到香港服务器（推荐）

**服务器地址**: `47.243.177.166`

#### 步骤1：上传文件到服务器

在本地Mac终端执行：

```bash
# 上传用户协议
scp terms-of-service.html root@47.243.177.166:/var/www/html/

# 上传隐私政策
scp privacy-policy.html root@47.243.177.166:/var/www/html/
```

#### 步骤2：配置Web服务器（如果还没有）

如果服务器上还没有Web服务器，可以：

**选项A：使用Python简单HTTP服务器（快速）**

```bash
# 在服务器上执行
cd /var/www/html
python3 -m http.server 80
```

**选项B：安装Nginx（推荐，更专业）**

```bash
# 在服务器上执行
apt-get update
apt-get install nginx -y
systemctl start nginx
systemctl enable nginx
```

#### 步骤3：访问URL

上传后，可以通过以下URL访问：

- 用户协议: `http://47.243.177.166/terms-of-service.html`
- 隐私政策: `http://47.243.177.166/privacy-policy.html`

---

### 方案2：使用GitHub Pages（免费，推荐用于测试）

#### 步骤1：创建GitHub仓库

1. 在GitHub上创建一个新仓库（例如：`xiaochuan-legal-pages`）
2. 设置为公开（Public）

#### 步骤2：上传文件

```bash
# 创建临时目录
mkdir -p /tmp/legal-pages
cd /tmp/legal-pages

# 复制HTML文件
cp /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/terms-of-service.html .
cp /Volumes/Expansion/FlutterProjects/桌面影音播放器_安装包_20251121_165905/privacy-policy.html .

# 初始化Git仓库
git init
git add .
git commit -m "Add legal pages"

# 添加远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/你的用户名/xiaochuan-legal-pages.git
git push -u origin main
```

#### 步骤3：启用GitHub Pages

1. 在GitHub仓库设置中
2. 找到 "Pages" 选项
3. 选择 "main" 分支
4. 保存

#### 步骤4：访问URL

上传后，可以通过以下URL访问：

- 用户协议: `https://你的用户名.github.io/xiaochuan-legal-pages/terms-of-service.html`
- 隐私政策: `https://你的用户名.github.io/xiaochuan-legal-pages/privacy-policy.html`

---

## 📝 在App Store Connect中使用

上传后，在App Store Connect中填写：

- **隐私政策URL**: 填写你部署的隐私政策URL
- **用户协议URL**: 填写你部署的用户协议URL（如果需要）

---

## ✅ 推荐方案

**推荐使用方案1（香港服务器）**，因为：
- 你已经有了服务器
- 不需要额外配置
- 访问速度快
- 更专业


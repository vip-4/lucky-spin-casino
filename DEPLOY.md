# Lucky Spin Casino 部署指南

## 🚀 已部署生产环境

| 项目 | 值 |
|------|-----|
| **生产 URL** | https://luckyspin.vip01.cc.cd/ |
| **源站托管** | Cloudflare Pages 项目 `lucky-spin-casino` |
| **Pages 生产别名** | https://lucky-spin-casino-6kd.pages.dev |
| **入口路由** | `luckyspin.vip01.cc.cd/*` → Worker `luckyspin-pages-proxy`（反代到 Pages） |
| **DNS** | `luckyspin.vip01.cc.cd` CNAME → `lucky-spin-casino-6kd.pages.dev`（代理开启） |
| **自动部署** | GitHub Actions：推送 `main` 分支自动构建 `dist/` 并发布到 Pages |
| **GitHub 仓库** | https://github.com/vip-4/lucky-spin-casino |
| **Zone** | `vip01.cc.cd` (`2754848880ff90a8cc6657b82accbf2a`) |
| **Account ID** | 见本地环境变量 `CLOUDFLARE_ACCOUNT_ID` |

> 说明：该 Zone 存在 `*.vip01.cc.cd/*` 通配 Worker 路由（`h5-game-geo-router`），会先于 Pages 自定义域名接管请求。因此使用专用反代 Worker `luckyspin-pages-proxy` 将流量转发到 Pages 生产别名，既保留 Pages 托管与自动部署，又不影响其他子域。

### 已验证的生产指标

- ✅ 首页：HTTP 200，约 17KB
- ✅ CSS/JS/图片/图标：HTTP 200
- ✅ 404 页面：正确返回 HTTP 404
- ✅ 安全头：CSP、HSTS、X-Frame-Options、X-Content-Type-Options、Referrer-Policy、Permissions-Policy
- ✅ JSON-LD：WebApplication + Organization + FAQPage 三个结构化数据块
- ✅ Canonical、Open Graph、Twitter Card 域名均为生产域名
- ✅ robots.txt：Cloudflare 托管内容 + 自定义规则合并（允许搜索引用，禁止训练）
- ✅ PWA：manifest.json + 全套图标

### 自动部署（推荐）

推送到 GitHub `main` 分支即自动部署，工作流文件：`.github/workflows/deploy-pages.yml`

```powershell
# 1. 修改本地文件
# 2. 通过 GitHub Contents API 或 git push 推送到 main
# 3. GitHub Actions 自动执行：
#    node scripts/build-dist.js
#    npx wrangler pages deploy dist --project-name lucky-spin-casino --branch=main
```

仓库已配置 Actions Secrets：`CLOUDFLARE_API_TOKEN`、`CLOUDFLARE_ACCOUNT_ID`。

### 本地手动部署

```powershell
# 环境变量
$env:CLOUDFLARE_API_TOKEN = "<你的 API Token>"
$env:CLOUDFLARE_ACCOUNT_ID = "<你的 Account ID>"

# 构建 dist 并部署
node scripts/build-dist.js
npx wrangler pages deploy dist --project-name lucky-spin-casino --branch=main
```

### 更新反代 Worker（仅当路由方案变更时）

```powershell
curl.exe -s -X PUT "https://api.cloudflare.com/client/v4/accounts/$env:CLOUDFLARE_ACCOUNT_ID/workers/scripts/luckyspin-pages-proxy" `
  -H "Authorization: Bearer $env:CLOUDFLARE_API_TOKEN" `
  -H "Content-Type: application/javascript" `
  --data-binary "@proxy-worker.js"
```

### 重新生成图片

```powershell
powershell -ExecutionPolicy Bypass -File .\generate-images.ps1
```

---

## 项目概述

轻量级静态 HTML5 老虎机 Casino 游戏，集成完整 SEO 与 GEO 优化，适配所有主流静态托管平台。

## 项目结构

```
casino-game/
├── index.html            # 主页（语义化 HTML + 完整 meta 标签 + JSON-LD 结构化数据）
├── 404.html              # 404 页面
├── robots.txt            # 爬虫指引
├── sitemap.xml           # 站点地图
├── manifest.json         # PWA 清单
├── netlify.toml          # Netlify 部署配置
├── _headers              # Netlify/Vercel 响应头
├── vercel.json           # Vercel 部署配置
├── css/
│   └── style.css         # 主样式表（CSS 变量、响应式、减少动画支持）
├── js/
│   └── game.js           # 老虎机游戏逻辑（零外部依赖）
└── img/                  # 图片资源（需自行添加）
    ├── favicon-16.png
    ├── favicon-32.png
    ├── apple-touch-icon.png
    ├── icon-72.png
    ├── icon-96.png
    ├── icon-128.png
    ├── icon-192.png
    ├── icon-512.png
    └── og-image.png      # Open Graph / Twitter Card 预览图 (1200x630)
```

## SEO 优化特性

- 语义化 HTML5：`<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>`
- 完整 meta 标签：title、description、keywords、author、robots、viewport、charset
- Open Graph：og:title、og:description、og:image、og:url、og:type、og:site_name、og:locale
- Twitter Card：summary_large_image 卡片
- 规范 URL (canonical)
- 跳转主内容链接（无障碍）
- 图片 alt 文本与 aria-label
- JSON-LD 结构化数据：WebApplication、Organization、FAQPage

## GEO (生成式引擎优化) 特性

- 清晰的 Q&A 常见问题部分（FAQPage 结构化数据）
- 实体丰富内容：游戏名称、开发者、类型、特色功能
- 作者与出版者信息
- 发布日期与修改日期
- 分步骤游戏说明（how-to 步骤）
- 赔付表（结构化表格）
- 无障碍友好：支持屏幕阅读器、键盘导航、减少动画模式

## 性能优化

- 资源预加载 (preload)
- CSS/JS 缓存头（1 年不可变缓存）
- 响应式设计，移动端优先
- 零外部依赖，无第三方脚本
- 内联关键 CSS，减少渲染阻塞
- Content-Security-Policy 安全头

## 部署方式

### Netlify
1. 将代码推送到 GitHub 仓库
2. 在 Netlify 中连接仓库
3. 构建命令留空，发布目录设为 `.`
4. 自动部署完成

### Vercel
1. 将代码推送到 GitHub 仓库
2. 在 Vercel 中导入仓库
3. 框架预设：其他 (Other)
4. 自动部署完成

### GitHub Pages
1. 将代码推送到 `gh-pages` 分支或主分支的 `/docs` 文件夹
2. 在仓库 Settings > Pages 中启用
3. 选择对应分支/文件夹

### Cloudflare Pages（推荐：静态站点托管）

本项目包含 `wrangler.toml`，可直接部署到 Cloudflare Pages。

#### 方式 A：通过 GitHub 仓库自动部署
1. 将代码推送到 GitHub 仓库
2. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/) → Workers & Pages → 创建 Pages 项目
3. 连接 GitHub 仓库，选择本仓库
4. 构建命令：`node scripts/build-dist.js`；输出目录：`dist`；框架预设：无
5. 部署完成后，在 Pages 设置中绑定自定义域名（如 `luckyspin.vip01.cc.cd`）

> 本仓库已配置 GitHub Actions（`.github/workflows/deploy-pages.yml`），无需在 Cloudflare 端连接 Git 即可自动部署。

#### 方式 B：通过 Wrangler CLI 手动部署
```bash
# 安装 Wrangler
npm install -g wrangler

# 登录 Cloudflare
wrangler login

# 构建并部署
node scripts/build-dist.js
wrangler pages deploy dist --project-name lucky-spin-casino
```

#### 方式 C：上传到 R2 存储桶（静态文件直接托管）

若你希望将静态资源存储在 **Cloudflare R2** 并通过自定义域或 `*.r2.dev` 访问，使用本项目提供的 R2 上传脚本。

**前置准备：**
1. 在 Cloudflare 控制台 → R2 → 创建存储桶（例如 `lucky-spin-casino`）
2. 在 R2 存储桶设置中启用 **Public Bucket Access**（公共读取）
3. 获取 S3 兼容凭证（Access Key ID / Secret Access Key / Endpoint）

**配置环境变量：**
```bash
cp .env.example .env
# 编辑 .env，填入你的 R2 凭证（参考下方“账户凭示例”）
```

**安装依赖并上传：**
```bash
npm install
npm run deploy:r2
```

上传完成后，在 Cloudflare 控制台为 R2 存储桶绑定自定义域名，并将 `index.html` 设为索引文件（Index Document）。

#### 账户凭示例（按你提供的信息填入 `.env`）

| 环境变量 | 值 |
|----------|-----|
| `R2_ACCESS_KEY_ID` | `<从 Cloudflare 控制台获取>` |
| `R2_SECRET_ACCESS_KEY` | `<从 Cloudflare 控制台获取>` |
| `R2_ENDPOINT` | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` |
| `R2_BUCKET_NAME` | `lucky-spin-casino`（需先在控制台创建） |
| `R2_PUBLIC_URL` | 你的 R2 自定义域或 `https://<bucket>.<account>.r2.cloudflarestorage.com` |

> ⚠️ 安全提示：`.env` 含有敏感凭证，**不要提交到 Git**。请将 `.env` 加入 `.gitignore`。

### Cloudflare 安全与缓存头（已内置）

本项目已内置 `_headers`（Pages/_headers 兼容）与 `wrangler.toml` 中的规则，部署后自动生效：
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`
- `Content-Security-Policy`: 限制脚本、样式、图片仅来自同源
- CSS/JS/图片：`Cache-Control: public, max-age=31536000, immutable`
- HTML：`Cache-Control: public, max-age=0, must-revalidate`

## 图片资源

`img/` 目录下已包含完整的图片资源：
- `og-image.png`：1200×630 px，用于社交分享预览
- `favicon-16.png` / `favicon-32.png`：网站图标
- `apple-touch-icon.png`：180×180 px，iOS 触控图标
- `icon-72.png` 到 `icon-512.png`：PWA 图标

如需重新生成，运行 `powershell -ExecutionPolicy Bypass -File .\generate-images.ps1`。
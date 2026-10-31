# 🎰 Lucky Spin Casino

轻量级静态 HTML5 老虎机 Casino 游戏，集成完整 **SEO** 与 **GEO（生成式引擎优化）**，适配 Cloudflare、Netlify、Vercel、GitHub Pages 等静态托管平台。

## 🌐 在线演示

**生产环境：** [https://luckyspin.vip01.cc.cd/](https://luckyspin.vip01.cc.cd/)

## ✨ 功能特性

- 🎰 **经典 3 滚轮老虎机**：7 种图案、加权随机、赔付表
- 🆓 **完全免费**：无需下载、无需注册、使用虚拟金币
- 📱 **响应式设计**：完美适配桌面、平板和手机
- ⚡ **零外部依赖**：纯原生 HTML/CSS/JS，加载迅速
- ♿ **无障碍友好**：语义化 HTML、屏幕阅读器支持、键盘导航、`prefers-reduced-motion`
- 🔍 **SEO 优化**：完整 Meta 标签、Open Graph、Twitter Card、canonical、JSON-LD 结构化数据
- 🤖 **GEO 优化**：FAQ 问答结构、HowTo 步骤、赔付表、作者/出版者信息，便于 AI 摘要与引用
- 🛡️ **安全头**：CSP、HSTS、X-Frame-Options、X-Content-Type-Options、Referrer-Policy
- 📦 **PWA 支持**：manifest.json + 全套图标

## 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/vip-4/lucky-spin-casino.git
cd lucky-spin-casino

# 直接打开（无需构建）
start index.html

# 或启动本地静态服务器（Python）
python -m http.server 8080
```

## 📁 项目结构

```
lucky-spin-casino/
├── index.html              # 主页（语义化 HTML + SEO/GEO meta + JSON-LD）
├── 404.html                # 404 页面
├── manifest.json           # PWA 清单
├── robots.txt              # 爬虫指引
├── sitemap.xml             # 站点地图
├── css/
│   └── style.css           # 样式表（响应式、可访问性）
├── js/
│   └── game.js             # 老虎机游戏逻辑
├── img/                    # OG 图片、favicon、PWA 图标
├── netlify.toml            # Netlify 配置
├── vercel.json             # Vercel 配置
├── wrangler.toml           # Cloudflare Pages 配置
├── _headers                # Cloudflare Pages / Netlify 响应头
├── proxy-worker.js         # 入口域名反代 Worker（Pages 前置）
├── DEPLOY.md               # 详细部署文档
├── build-worker.ps1        # 生成内嵌静态站点的 Worker（备用方案）
└── generate-images.ps1     # 生成 OG 图片和图标
```

## 🔍 SEO 优化清单

- [x] `<title>`、`description`、`keywords`、`author`、`robots`
- [x] Open Graph（`og:title/description/image/url/type/site_name/locale`）
- [x] Twitter Card（`summary_large_image`）
- [x] Canonical URL
- [x] 语义化 HTML5：`header` / `nav` / `main` / `section` / `article` / `footer`
- [x] 标题层级 `h1` → `h3`
- [x] 图片 `alt` 文本
- [x] `robots.txt` + `sitemap.xml`
- [x] JSON-LD：`WebApplication`、`Organization`、`FAQPage`

## 🤖 GEO（生成式引擎优化）清单

- [x] FAQ 问答结构（含 `FAQPage` 结构化数据）
- [x] 分步骤 HowTo 游戏说明
- [x] 赔付表（结构化表格，便于 AI 提取）
- [x] 实体丰富：游戏名称、开发者、类型、特色、发布日期
- [x] 作者与出版者信息（`Organization` schema）
- [x] 清晰的内容层级与可读性
- [x] 允许 AI 搜索引用（`Content-signal: search=yes, use=reference`）

## ☁️ 部署

### Cloudflare Pages + GitHub Actions（当前生产方案）

生产 URL：**https://luckyspin.vip01.cc.cd/**（Pages 源站 + 专用反代 Worker）

推送 `main` 分支后，GitHub Actions 会自动执行 `.github/workflows/deploy-pages.yml`：

```bash
node scripts/build-dist.js
npx wrangler pages deploy dist --project-name lucky-spin-casino --branch=main
```

手动部署：

```bash
# 构建纯静态输出目录
node scripts/build-dist.js

# 部署到 Pages
npx wrangler pages deploy dist --project-name lucky-spin-casino
```

> 入口域名由 Worker `luckyspin-pages-proxy` 反向代理到 Pages 生产别名 `lucky-spin-casino-6kd.pages.dev`，用于绕开 Zone 内 `*.vip01.cc.cd/*` 通配路由。

### Netlify

1. 连接 GitHub 仓库
2. 构建命令留空，发布目录设为 `.`
3. 自动部署

### Vercel

1. 导入 GitHub 仓库
2. 框架预设：Other
3. 自动部署

### GitHub Pages

1. 在仓库 Settings → Pages 中选择分支 `main`，目录 `/ (root)`
2. 自动部署

更多细节见 [DEPLOY.md](DEPLOY.md)。

## 🎮 游戏规则

| 图案 | 名称 | 赔付（×下注） |
|------|------|--------------|
| 🍒 | 樱桃 | ×5 |
| 🍋 | 柠檬 | ×10 |
| 🍊 | 橙子 | ×15 |
| 🍇 | 葡萄 | ×20 |
| 🔔 | 铃铛 | ×50 |
| 💎 | 钻石 | ×100 |
| 7️⃣ | 幸运 7 | ×500 |

三个滚轮停止后，若出现相同图案即中奖。初始余额 1000 虚拟金币。

## 🛠️ 技术栈

- 原生 HTML5 / CSS3 / JavaScript（ES2020+）
- 无构建步骤、无框架、无外部依赖
- CSS 变量、Grid/Flexbox 布局
- Web APIs：`classList`、`aria-live`、Promise/async

## 📄 许可证

MIT License — 仅供娱乐，不涉及真实金钱赌博。

---

**免责声明：** 本游戏仅使用虚拟金币，不涉及真实金钱赌博，仅供娱乐。

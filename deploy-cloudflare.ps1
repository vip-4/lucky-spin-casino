# Lucky Spin Casino - Cloudflare Pages 一键部署脚本 (PowerShell)
# 前提：已安装 Node.js (https://nodejs.org/)
#
# 用法：
#   右键点击此文件 -> "使用 PowerShell 运行"
#   或在 PowerShell 中执行：.\deploy-cloudflare.ps1

$ErrorActionPreference = "Stop"

# 从环境变量读取凭证（切勿将真实凭证写死在脚本中）
$acctId   = $env:CLOUDFLARE_ACCOUNT_ID
$apiToken = $env:CLOUDFLARE_API_TOKEN
if (-not $acctId -or -not $apiToken) {
    Write-Host "请先设置环境变量 CLOUDFLARE_ACCOUNT_ID 与 CLOUDFLARE_API_TOKEN" -ForegroundColor Red
    exit 1
}
$project  = "lucky-spin-casino"
$branch   = "main"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Lucky Spin Casino - Cloudflare Pages 部署" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. 检查 Node.js
Write-Host "`n[1/5] 检查 Node.js ..." -ForegroundColor Yellow
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 未找到 Node.js，请先安装：https://nodejs.org/ (LTS 版本)" -ForegroundColor Red
    Write-Host "安装完成后重新运行本脚本。" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Node.js 已安装: $(node --version)" -ForegroundColor Green

# 2. 安装 wrangler
Write-Host "`n[2/5] 安装 Wrangler (Cloudflare CLI) ..." -ForegroundColor Yellow
npm install -g wrangler
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Wrangler 安装失败" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Wrangler 安装完成: $(wrangler --version)" -ForegroundColor Green

# 3. 使用 API Token 登录（非交互式）
Write-Host "`n[3/5] 使用 API Token 登录 Cloudflare ..." -ForegroundColor Yellow
$env:CLOUDFLARE_API_TOKEN = $apiToken
wrangler login --api-token="$apiToken" | Out-Null
$whoami = wrangler whoami --format json | ConvertFrom-Json
if ($whoami.success -eq $true -or $whoami.result -ne $null) {
    Write-Host "✅ 登录成功，账户: $($whoami.result.name) ($acctId)" -ForegroundColor Green
} else {
    Write-Host "⚠️  无法确认登录状态，将继续尝试部署..." -ForegroundColor Yellow
}

# 4. 部署到 Cloudflare Pages
Write-Host "`n[4/5] 部署到 Cloudflare Pages ..." -ForegroundColor Yellow
wrangler pages deploy . `
    --project-name $project `
    --branch $branch `
    --commit-dirty `
    --commit-message "Deploy Lucky Spin Casino ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 部署失败" -ForegroundColor Red
    exit 1
}

# 5. 完成
Write-Host "`n[5/5] 部署完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  项目名称: $project" -ForegroundColor Cyan
Write-Host "  分支: $branch" -ForegroundColor Cyan
Write-Host "  账户 ID: $acctId" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "`n接下来在 Cloudflare 控制台执行：" -ForegroundColor Yellow
Write-Host "  1. 进入 Pages 项目: lucky-spin-casino" -ForegroundColor White
Write-Host "  2. 在「域名」中绑定你的自定义域名 (如 lucky-spin-casino.example.com)" -ForegroundColor White
Write-Host "  3. 确保 SSL/TLS 设置为「完全」或「灵活」" -ForegroundColor White
Write-Host "`n网站将通过全球边缘节点缓存，自动启用 HTTPS。" -ForegroundColor Green

Read-Host "`n按 Enter 键退出"
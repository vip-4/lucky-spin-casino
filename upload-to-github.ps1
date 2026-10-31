# 通过 GitHub Contents API 批量上传项目文件
# 无需本地 git 工具
# 用法：$env:GITHUB_TOKEN = "<你的 GitHub Token>"; .\upload-to-github.ps1

$ErrorActionPreference = "Stop"

$token = $env:GITHUB_TOKEN
if (-not $token) {
    Write-Host "请先设置环境变量 GITHUB_TOKEN（不要将 Token 写入脚本）" -ForegroundColor Red
    exit 1
}
$owner = "vip-4"
$repo = "lucky-spin-casino"
$branch = "main"
$localRoot = (Get-Location).Path

# 需要上传的文件（相对路径）。敏感脚本与构建产物不入库。
$files = @(
    "README.md",
    "index.html",
    "404.html",
    "manifest.json",
    "robots.txt",
    "sitemap.xml",
    "css/style.css",
    "js/game.js",
    "img/og-image.png",
    "img/favicon-16.png",
    "img/favicon-32.png",
    "img/apple-touch-icon.png",
    "img/icon-72.png",
    "img/icon-96.png",
    "img/icon-128.png",
    "img/icon-192.png",
    "img/icon-512.png",
    "DEPLOY.md",
    ".gitignore",
    ".env.example",
    "package.json",
    "wrangler.toml",
    "netlify.toml",
    "vercel.json",
    "_headers",
    "scripts/deploy-r2.js",
    "build-worker.ps1",
    "generate-images.ps1",
    "deploy-r2.ps1",
    "deploy-cloudflare.ps1"
)

$headers = @{
    Authorization = "Bearer $token"
    Accept = "application/vnd.github+json"
    "User-Agent" = "lucky-spin-deploy"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$success = 0
$failed = 0
$skipped = 0

foreach ($rel in $files) {
    $fullPath = Join-Path $localRoot $rel
    if (-not (Test-Path $fullPath)) {
        Write-Host "SKIP (missing): $rel" -ForegroundColor Yellow
        $skipped++
        continue
    }

    $bytes = [IO.File]::ReadAllBytes($fullPath)
    $b64 = [Convert]::ToBase64String($bytes)
    $apiPath = $rel.Replace('\', '/')
    $url = "https://api.github.com/repos/$owner/$repo/contents/$apiPath"

    $body = @{
        message = "Add $apiPath"
        content = $b64
        branch = $branch
    } | ConvertTo-Json -Compress

    try {
        $resp = Invoke-RestMethod -Method PUT -Uri $url -Headers $headers -ContentType "application/json; charset=utf-8" -Body $body -ErrorAction Stop
        Write-Host "OK: $apiPath" -ForegroundColor Green
        $success++
    } catch {
        $msg = $_.Exception.Message
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errBody = $reader.ReadToEnd()
            $errJson = $errBody | ConvertFrom-Json
            $msg = $errJson.message
        } catch {}
        Write-Host "FAIL: $apiPath -> $msg" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "Upload complete: $success success, $failed failed, $skipped skipped" -ForegroundColor Cyan
Write-Host "Repository: https://github.com/$owner/$repo" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

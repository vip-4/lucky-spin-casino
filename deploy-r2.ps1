# Lucky Spin Casino - R2 批量上传脚本 (PowerShell)
# 使用 Cloudflare R2 REST API 上传静态文件
# 无需 Node.js / AWS CLI

$ErrorActionPreference = "Stop"

# ===== 配置 =====
$apiToken  = $env:CLOUDFLARE_API_TOKEN
$accountId = $env:CLOUDFLARE_ACCOUNT_ID
if (-not $apiToken -or -not $accountId) {
    Write-Host "请先设置环境变量 CLOUDFLARE_API_TOKEN 与 CLOUDFLARE_ACCOUNT_ID" -ForegroundColor Red
    exit 1
}
$bucket = "h5-game-assets"
$prefix = "lucky-spin"   # 上传到桶内的路径前缀
$localRoot = (Get-Location).Path

# 排除的目录/文件（不部署到生产）
$excludeDirs = @("node_modules", ".git", "scripts")
$excludeFiles = @("deploy-cloudflare.ps1", "deploy-r2.ps1", "package.json", "package-lock.json",
                  "DEPLOY.md", ".env", ".env.example", ".gitignore", "wrangler.toml")

# Content-Type 映射
function Get-ContentType($ext) {
    switch ($ext.ToLower()) {
        ".html" { "text/html; charset=utf-8" }
        ".css"  { "text/css; charset=utf-8" }
        ".js"   { "application/javascript; charset=utf-8" }
        ".json" { "application/json" }
        ".xml"  { "application/xml" }
        ".txt"  { "text/plain; charset=utf-8" }
        ".png"  { "image/png" }
        ".jpg"  { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".svg"  { "image/svg+xml" }
        ".ico"  { "image/x-icon" }
        ".webp" { "image/webp" }
        ".woff2"{ "font/woff2" }
        ".woff" { "font/woff" }
        default { "application/octet-stream" }
    }
}

# 缓存策略
function Get-CacheControl($ext) {
    switch ($ext.ToLower()) {
        ".html" { "public, max-age=0, must-revalidate" }
        ".css"  { "public, max-age=31536000, immutable" }
        ".js"   { "public, max-age=31536000, immutable" }
        ".png"  { "public, max-age=31536000, immutable" }
        ".jpg"  { "public, max-age=31536000, immutable" }
        ".jpeg" { "public, max-age=31536000, immutable" }
        ".svg"  { "public, max-age=31536000, immutable" }
        ".ico"  { "public, max-age=31536000, immutable" }
        ".webp" { "public, max-age=31536000, immutable" }
        default { "public, max-age=3600, must-revalidate" }
    }
}

# 收集文件
$files = Get-ChildItem -Recurse -File | Where-Object {
    $rel = $_.FullName.Substring($localRoot.Length + 1)
    $parts = $rel.Split([IO.Path]::DirectorySeparatorChar)
    $skip = $false
    foreach ($d in $excludeDirs) { if ($parts -contains $d) { $skip = $true } }
    if ($excludeFiles -contains $_.Name) { $skip = $true }
    return -not $skip
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Lucky Spin Casino - R2 上传" -ForegroundColor Cyan
Write-Host "  存储桶: $bucket" -ForegroundColor Cyan
Write-Host "  前缀: $prefix/" -ForegroundColor Cyan
Write-Host "  文件数: $($files.Count)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$success = 0
$failed = 0

foreach ($file in $files) {
    $rel = $file.FullName.Substring($localRoot.Length + 1).Replace('\', '/')
    $key = "$prefix/$rel"
    $ext = [IO.Path]::GetExtension($file.FullName)
    $contentType = Get-ContentType $ext
    $cacheControl = Get-CacheControl $ext

    $encodedKey = $key -replace ' ', '%20'
    $url = "https://api.cloudflare.com/client/v4/accounts/$accountId/r2/buckets/$bucket/objects/$encodedKey"

    try {
        $bytes = [IO.File]::ReadAllBytes($file.FullName)
        $headers = @{
            "Authorization" = "Bearer $apiToken"
            "Content-Type"  = $contentType
            "Cache-Control" = $cacheControl
        }
        $response = Invoke-RestMethod -Method PUT -Uri $url -Headers $headers -Body $bytes -ErrorAction Stop
        Write-Host "✅ $rel  ($($file.Length) bytes)" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "❌ $rel  -> $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  上传完成: 成功 $success, 失败 $failed" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

if ($failed -eq 0) {
    Write-Host "`n🌐 访问地址:" -ForegroundColor Yellow
    Write-Host "   https://pub-d84f228f085248c48d136e6279ea2000.r2.dev/$prefix/index.html" -ForegroundColor White
    Write-Host "   (自定义域名: https://cdn-h5.vip01.cc.cd/$prefix/index.html)" -ForegroundColor White
}
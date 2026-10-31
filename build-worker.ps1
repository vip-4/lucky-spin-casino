# 生成内嵌静态站点的 Cloudflare Worker 代码
# 将 casino-game 所有静态文件嵌入 Worker，输出 worker.js

$ErrorActionPreference = "Stop"

$localRoot = (Get-Location).Path
$outputFile = Join-Path $localRoot "worker.js"

# 需要嵌入的文件（相对路径）
$filePaths = @(
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
    "img/icon-512.png"
)

# Content-Type 映射
function Get-ContentType($ext) {
    switch ($ext.ToLower()) {
        ".html" { "text/html; charset=utf-8" }
        ".css"  { "text/css; charset=utf-8" }
        ".js"   { "application/javascript; charset=utf-8" }
        ".json" { "application/json" }
        ".xml"  { "application/xml; charset=utf-8" }
        ".txt"  { "text/plain; charset=utf-8" }
        ".png"  { "image/png" }
        ".svg"  { "image/svg+xml" }
        default { "application/octet-stream" }
    }
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("// Lucky Spin Casino - Static Site Worker")
[void]$sb.AppendLine("// Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine("const FILES = {")

$entries = @()
foreach ($rel in $filePaths) {
    $fullPath = Join-Path $localRoot $rel
    if (-not (Test-Path $fullPath)) {
        Write-Warning "Missing file: $rel"
        continue
    }
    $bytes = [IO.File]::ReadAllBytes($fullPath)
    $b64 = [Convert]::ToBase64String($bytes)
    $ext = [IO.Path]::GetExtension($rel)
    $ct = Get-ContentType $ext
    $key = "/" + $rel.Replace('\', '/')
    $entries += "  `"$key`": {`"t`":`"$ct`",`"b`":`"$b64`"}"
}

[void]$sb.AppendLine(($entries -join ",`n"))
[void]$sb.AppendLine("};")
[void]$sb.AppendLine(@'
function b64Bytes(b64){const bin=atob(b64);const a=new Uint8Array(bin.length);for(let i=0;i<bin.length;i++)a[i]=bin.charCodeAt(i);return a;}
function serve(p){
  const f=FILES[p]; if(f) return f;
  if(!p.includes('.')){const a=FILES[p+'.html']; if(a) return a; const b=FILES[p+'/index.html']; if(b) return b;}
  return null;
}
addEventListener('fetch', (e)=>e.respondWith((async()=>{
  let p=new URL(e.request.url).pathname;
  if(p==='/') p='/index.html';
  else if(p.length>1 && p.endsWith('/')) p+='index.html';
  let f=serve(p);
  if(!f){
    const nf=FILES['/404.html'];
    return new Response(nf? b64Bytes(nf.b):'404 Not Found', {status:404,
      headers:{'content-type':'text/html; charset=utf-8','cache-control':'public, max-age=0, must-revalidate'}});
  }
  const body=b64Bytes(f.b);
  const isHTML = (f.t||'').includes('text/html');
  const cache = isHTML ? 'public, max-age=0, must-revalidate' : 'public, max-age=31536000, immutable';
  return new Response(body, {headers:{
    'content-type': f.t || 'application/octet-stream',
    'cache-control': cache,
    'x-content-type-options': 'nosniff',
    'x-frame-options': 'DENY',
    'referrer-policy': 'strict-origin-when-cross-origin',
    'permissions-policy': 'camera=(), microphone=(), geolocation=()',
    'content-security-policy': "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self'; img-src 'self' data:; base-uri 'self'; frame-ancestors 'none';",
    'strict-transport-security': 'max-age=31536000; includeSubDomains'
  }});
})()));
'@)

[IO.File]::WriteAllText($outputFile, $sb.ToString(), [Text.UTF8Encoding]::new($false))
$size = (Get-Item $outputFile).Length
Write-Host "Worker generated: $outputFile ($size bytes)" -ForegroundColor Green
Write-Host "Embedded files: $($entries.Count)" -ForegroundColor Green
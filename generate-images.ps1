# Generate OG image and icons for Lucky Spin Casino
# Uses System.Drawing (PowerShell 5.1 compatible)

Add-Type -AssemblyName System.Drawing

$imgDir = Join-Path (Get-Location) "img"
if (-not (Test-Path $imgDir)) { New-Item -ItemType Directory -Path $imgDir | Out-Null }

$bgColor     = [System.Drawing.Color]::FromArgb(15, 23, 42)
$surfaceColor= [System.Drawing.Color]::FromArgb(30, 41, 59)
$accentColor = [System.Drawing.Color]::FromArgb(245, 158, 11)
$textColor   = [System.Drawing.Color]::FromArgb(248, 250, 252)
$mutedColor  = [System.Drawing.Color]::FromArgb(203, 213, 225)

function Save-Image($bmp, $path) {
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Generated: $path" -ForegroundColor Green
}

# ===== OG image 1200x630 =====
$bmp = [System.Drawing.Bitmap]::new(1200, 630)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Background gradient
$rect = [System.Drawing.Rectangle]::new(0, 0, 1200, 630)
$grad = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, $bgColor, $surfaceColor, 45.0)
$g.FillRectangle($grad, $rect)

# Gold glow
$glow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(28, 245, 158, 11))
$g.FillEllipse($glow, 780, 60, 560, 560)

# Top accent bar
$accent = [System.Drawing.SolidBrush]::new($accentColor)
$g.FillRectangle($accent, 0, 0, 1200, 8)

# Title
$fontTitle = [System.Drawing.Font]::new("Arial", 72, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$textBrush = [System.Drawing.SolidBrush]::new($textColor)
$g.DrawString("Lucky Spin Casino", $fontTitle, $textBrush, 80, 190)

# Subtitle
$fontSub = [System.Drawing.Font]::new("Arial", 34, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$accentText = [System.Drawing.SolidBrush]::new($accentColor)
$g.DrawString("Free Online HTML5 Slots", $fontSub, $accentText, 80, 290)

# Description
$fontDesc = [System.Drawing.Font]::new("Arial", 24, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$mutedBrush = [System.Drawing.SolidBrush]::new($mutedColor)
$g.DrawString("No download  |  No signup  |  Desktop & mobile", $fontDesc, $mutedBrush, 80, 360)

# Slot emoji / icon
$fontIcon = [System.Drawing.Font]::new("Segoe UI Emoji", 200, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString([char]::ConvertFromUtf32(0x1F3B0), $fontIcon, $textBrush, 800, 200)

# URL
$fontUrl = [System.Drawing.Font]::new("Consolas", 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("luckyspin.vip01.cc.cd", $fontUrl, $mutedBrush, 80, 520)

$g.Dispose()
Save-Image $bmp (Join-Path $imgDir "og-image.png")

# ===== favicon 16x16 =====
$bmp = [System.Drawing.Bitmap]::new(16, 16)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear($bgColor)
$brush = [System.Drawing.SolidBrush]::new($accentColor)
$g.FillEllipse($brush, 2, 2, 12, 12)
$font = [System.Drawing.Font]::new("Arial", 10, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("7", $font, [System.Drawing.SolidBrush]::new($bgColor), 4, 2)
$g.Dispose()
Save-Image $bmp (Join-Path $imgDir "favicon-16.png")

# ===== favicon 32x32 =====
$bmp = [System.Drawing.Bitmap]::new(32, 32)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear($bgColor)
$brush = [System.Drawing.SolidBrush]::new($accentColor)
$g.FillEllipse($brush, 4, 4, 24, 24)
$font = [System.Drawing.Font]::new("Arial", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("7", $font, [System.Drawing.SolidBrush]::new($bgColor), 8, 4)
$g.Dispose()
Save-Image $bmp (Join-Path $imgDir "favicon-32.png")

# ===== apple-touch-icon 180x180 =====
$bmp = [System.Drawing.Bitmap]::new(180, 180)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear($bgColor)
$brush = [System.Drawing.SolidBrush]::new($accentColor)
$g.FillEllipse($brush, 20, 20, 140, 140)
$font = [System.Drawing.Font]::new("Arial", 110, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("7", $font, [System.Drawing.SolidBrush]::new($bgColor), 50, 22)
$g.Dispose()
Save-Image $bmp (Join-Path $imgDir "apple-touch-icon.png")

# ===== PWA icons =====
foreach ($size in @(72, 96, 128, 192, 512)) {
    $bmp = [System.Drawing.Bitmap]::new($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear($bgColor)

    $rectSize = [int]($size * 0.92)
    $offset = [int](($size - $rectSize) / 2)
    $bgBrush = [System.Drawing.SolidBrush]::new($surfaceColor)
    $g.FillEllipse($bgBrush, $offset, $offset, $rectSize, $rectSize)

    $circleSize = [int]($size * 0.55)
    $circleOffset = [int](($size - $circleSize) / 2)
    $goldBrush = [System.Drawing.SolidBrush]::new($accentColor)
    $g.FillEllipse($goldBrush, $circleOffset, $circleOffset, $circleSize, $circleSize)

    $fontSize = [int]($size * 0.44)
    $font = [System.Drawing.Font]::new("Arial", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $textBrush = [System.Drawing.SolidBrush]::new($bgColor)
    $textSize = $g.MeasureString("7", $font)
    $x = ($size - $textSize.Width) / 2
    $y = ($size - $textSize.Height) / 2 + ($size * 0.02)
    $g.DrawString("7", $font, $textBrush, $x, $y)

    $g.Dispose()
    Save-Image $bmp (Join-Path $imgDir "icon-$size.png")
}

Write-Host "`nAll images generated." -ForegroundColor Cyan
Get-ChildItem $imgDir -File | Select-Object Name, Length | Format-Table -AutoSize
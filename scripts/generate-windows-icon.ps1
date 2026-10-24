param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\Windows\Tipoff.App\Tipoff.ico'),
    [string]$SourcePath = (Join-Path $PSScriptRoot '..\img\Tipoff-transparent.png')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function New-BasketballPng([int]$Size, [System.Drawing.Image]$Source) {
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $stream = [System.IO.MemoryStream]::new()
    try {
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear([System.Drawing.Color]::Transparent)

        # The source artwork includes transparent presentation padding. Crop that padding,
        # then keep a small optical margin so the ball reads clearly at 16px in the tray.
        $sourceInset = [single]([Math]::Min($Source.Width, $Source.Height) * 0.105)
        $sourceRect = [System.Drawing.RectangleF]::new(
            $sourceInset,
            $sourceInset,
            [single]($Source.Width - 2 * $sourceInset),
            [single]($Source.Height - 2 * $sourceInset)
        )
        $padding = [single]([Math]::Max(1, [Math]::Round($Size * 0.055)))
        $destination = [System.Drawing.RectangleF]::new($padding, $padding, $Size - 2 * $padding, $Size - 2 * $padding)
        $clip = [System.Drawing.Drawing2D.GraphicsPath]::new()
        try {
            $clip.AddEllipse($destination)
            $graphics.SetClip($clip)
            $graphics.DrawImage($Source, $destination, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)
        } finally { $clip.Dispose() }

        $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
        return $stream.ToArray()
    } finally {
        $stream.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$sizes = @(16, 20, 24, 32, 40, 48, 64, 128, 256)
$source = [System.Drawing.Image]::FromFile([System.IO.Path]::GetFullPath($SourcePath))
try {
    $images = @($sizes | ForEach-Object { ,(New-BasketballPng $_ $source) })
} finally { $source.Dispose() }
$output = [System.IO.Path]::GetFullPath($OutputPath)
$directory = [System.IO.Path]::GetDirectoryName($output)
[System.IO.Directory]::CreateDirectory($directory) | Out-Null
$file = [System.IO.File]::Create($output)
$writer = [System.IO.BinaryWriter]::new($file)
try {
    $writer.Write([uint16]0)
    $writer.Write([uint16]1)
    $writer.Write([uint16]$sizes.Count)
    $offset = 6 + 16 * $sizes.Count
    for ($index = 0; $index -lt $sizes.Count; $index++) {
        $size = $sizes[$index]
        $writer.Write([byte]($(if ($size -eq 256) { 0 } else { $size })))
        $writer.Write([byte]($(if ($size -eq 256) { 0 } else { $size })))
        $writer.Write([byte]0)
        $writer.Write([byte]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]32)
        $writer.Write([uint32]$images[$index].Length)
        $writer.Write([uint32]$offset)
        $offset += $images[$index].Length
    }
    foreach ($image in $images) { $writer.Write([byte[]]$image) }
} finally {
    $writer.Dispose()
    $file.Dispose()
}

Write-Output "Generated $output"

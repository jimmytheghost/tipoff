param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\Windows\Tipoff.App\Tipoff.ico')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function New-BasketballPng([int]$Size) {
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $stream = [System.IO.MemoryStream]::new()
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $dark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 32, 37, 38))
        try { $graphics.FillEllipse($dark, 0, 0, $Size - 1, $Size - 1) } finally { $dark.Dispose() }

        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $seamWidth = [Math]::Max(1.0, $Size * 0.055)
        $seam = [System.Drawing.Pen]::new([System.Drawing.Color]::Transparent, $seamWidth)
        try {
            $seam.StartCap = $seam.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
            $p = [single]$Size
            $graphics.DrawLine($seam, $p * 0.50, 0, $p * 0.50, $p)
            $graphics.DrawBezier($seam, $p * 0.08, 0, $p * 0.06, $p * 0.25, $p * 0.33, $p * 0.49, $p, $p * 0.59)
            $graphics.DrawBezier($seam, $p * 0.92, 0, $p * 0.94, $p * 0.25, $p * 0.67, $p * 0.49, 0, $p * 0.59)
            $graphics.DrawLine($seam, $p * 0.06, $p * 0.18, $p * 0.94, $p * 0.82)
        } finally { $seam.Dispose() }

        $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
        return $stream.ToArray()
    } finally {
        $stream.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$sizes = @(16, 20, 24, 32, 40, 48, 64, 128, 256)
$images = @($sizes | ForEach-Object { ,(New-BasketballPng $_) })
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
